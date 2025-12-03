import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as order_models;
import 'supabase_service.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'orders';
  final String _productsCollection = 'products';

  /// Create a new order
  Future<order_models.Order> createOrder({
    required String buyerId,
    required String buyerName,
    required String buyerEmail,
    required String buyerPhone,
    required List<order_models.OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    required String city,
    required String state,
    required String zipCode,
    required String paymentMethod,
  }) async {
    try {
      final orderRef = _db.collection(_collection).doc();

      final order = order_models.Order(
        id: orderRef.id,
        buyerId: buyerId,
        buyerName: buyerName,
        buyerEmail: buyerEmail,
        buyerPhone: buyerPhone,
        items: items,
        totalAmount: totalAmount,
        status: 'pending',
        deliveryAddress: deliveryAddress,
        city: city,
        state: state,
        zipCode: zipCode,
        paymentMethod: paymentMethod,
        paymentStatus: paymentMethod == 'cod' ? 'pending' : 'pending',
        createdAt: Timestamp.now(),
      );

      // Save order to Firestore
      await orderRef.set(order.toMap());

      // Update product quantities
      for (final item in items) {
        await _db.collection(_productsCollection).doc(item.productId).update({
          'availableQuantity': FieldValue.increment(-item.quantity),
        });
      }

      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get order by ID
  Future<order_models.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _db.collection(_collection).doc(orderId).get();
      if (!doc.exists) return null;
      return order_models.Order.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  /// Get all orders for a buyer
  Stream<List<order_models.Order>> getBuyerOrders(String buyerId) {
    return _db
        .collection(_collection)
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => order_models.Order.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Get all orders for a seller (by product seller ID)
  Stream<List<order_models.Order>> getSellerOrders(String sellerId) {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => order_models.Order.fromMap(doc.id, doc.data()))
            .toList()
            .where((order) => order.items.any((item) => item.sellerId == sellerId))
            .toList());
  }

  /// Get seller's orders with a specific seller ID in items
  Future<List<order_models.Order>> getSellerOrdersAdvanced(String sellerId) async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs
          .map((doc) => order_models.Order.fromMap(doc.id, doc.data()))
          .toList();

      // Filter orders that contain items from this seller
      return orders.where((order) => order.items.any((item) => item.sellerId == sellerId)).toList();
    } catch (e) {
      throw Exception('Failed to fetch seller orders: $e');
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final updateData = <String, dynamic>{'status': newStatus};

      // Add timestamp based on status
      if (newStatus == 'confirmed') {
        updateData['confirmedAt'] = Timestamp.now();
      } else if (newStatus == 'shipped') {
        updateData['shippedAt'] = Timestamp.now();
      } else if (newStatus == 'delivered') {
        updateData['deliveredAt'] = Timestamp.now();
      } else if (newStatus == 'cancelled') {
        updateData['cancelledAt'] = Timestamp.now();

        // Restore product quantities
        final orderToCancel = await getOrderById(orderId);
        if (orderToCancel != null) {
          for (final item in orderToCancel.items) {
            await _db.collection(_productsCollection).doc(item.productId).update({
              'availableQuantity': FieldValue.increment(item.quantity),
            });
          }
        }
      }

      await _db.collection(_collection).doc(orderId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Update payment status
  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      await _db.collection(_collection).doc(orderId).update({
        'paymentStatus': paymentStatus,
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Add tracking number
  Future<void> addTrackingNumber(String orderId, String trackingNumber) async {
    try {
      await _db.collection(_collection).doc(orderId).update({
        'trackingNumber': trackingNumber,
        'shippedAt': Timestamp.now(),
        'status': 'shipped',
      });
    } catch (e) {
      throw Exception('Failed to add tracking number: $e');
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, 'cancelled');
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  /// Get order statistics for seller
  Future<Map<String, int>> getSellerOrderStats(String sellerId) async {
    try {
      final orders = await getSellerOrdersAdvanced(sellerId);

      return {
        'total': orders.length,
        'pending': orders.where((o) => o.status == 'pending').length,
        'confirmed': orders.where((o) => o.status == 'confirmed').length,
        'shipped': orders.where((o) => o.status == 'shipped').length,
        'delivered': orders.where((o) => o.status == 'delivered').length,
        'cancelled': orders.where((o) => o.status == 'cancelled').length,
      };
    } catch (e) {
      throw Exception('Failed to fetch order stats: $e');
    }
  }

  /* ----------------- Supabase variants (incremental migration) ----------------- */

  /// Create a new order in Supabase (Postgres). Assumes a `orders` table
  /// with appropriate columns and an `items` jsonb column.
  Future<order_models.Order> createOrderSupabase({
    required String buyerId,
    required String buyerName,
    required String buyerEmail,
    required String buyerPhone,
    required List<order_models.OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    required String city,
    required String state,
    required String zipCode,
    required String paymentMethod,
  }) async {
    try {
      final sb = SupabaseService().client;
      final itemsMap = items.map((i) => i.toMap()).toList();

      final insert = await sb.from('orders').insert({
        'buyerId': buyerId,
        'buyerName': buyerName,
        'buyerEmail': buyerEmail,
        'buyerPhone': buyerPhone,
        'items': itemsMap,
        'totalAmount': totalAmount,
        'status': 'pending',
        'deliveryAddress': deliveryAddress,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentMethod == 'cod' ? 'pending' : 'pending',
      }).select().maybeSingle();

      final row = insert as dynamic;
      if (row == null) throw Exception('Supabase insert returned null');
      final id = (row['id'] ?? '').toString();

      // Decrement product quantities in Supabase as well (if products table exists)
      for (final item in items) {
        try {
          final prod = await sb.from('products').select('availableQuantity').eq('id', item.productId).maybeSingle();
          final current = (prod != null && prod['availableQuantity'] != null) ? (prod['availableQuantity'] as int) : 0;
          await sb.from('products').update({
            'availableQuantity': current - item.quantity,
          }).eq('id', item.productId);
        } catch (_) {
          // best-effort; ignore
        }
      }

      return order_models.Order.fromSupabase(id, Map<String, dynamic>.from(row));
    } catch (e) {
      throw Exception('Failed to create Supabase order: $e');
    }
  }

  /// Supabase variant
  Future<order_models.Order?> getOrderByIdSupabase(String orderId) async {
    try {
      final sb = SupabaseService().client;
      final resp = await sb.from('orders').select().eq('id', orderId).maybeSingle();
      final row = resp as dynamic;
      if (row == null) return null;
      return order_models.Order.fromSupabase(row['id'].toString(), Map<String, dynamic>.from(row));
    } catch (e) {
      throw Exception('Failed to fetch order from Supabase: $e');
    }
  }

  /// Supabase variant (returns Future list instead of stream)
  Future<List<order_models.Order>> getBuyerOrdersSupabase(String buyerId) async {
    try {
      final sb = SupabaseService().client;
      final resp = await sb.from('orders').select().eq('buyerId', buyerId).order('created_at', ascending: false);
      final rows = resp as List<dynamic>;
      return rows.map((r) => order_models.Order.fromSupabase(r['id'].toString(), Map<String, dynamic>.from(r))).toList();
    } catch (e) {
      throw Exception('Failed to fetch buyer orders from Supabase: $e');
    }
  }

  /// Supabase variant for updating status
  Future<void> updateOrderStatusSupabase(String orderId, String newStatus) async {
    try {
      final sb = SupabaseService().client;
      final updateData = <String, dynamic>{'status': newStatus};

      if (newStatus == 'confirmed') {
        updateData['confirmedAt'] = DateTime.now().toIso8601String();
      } else if (newStatus == 'shipped') {
        updateData['shippedAt'] = DateTime.now().toIso8601String();
      } else if (newStatus == 'delivered') {
        updateData['deliveredAt'] = DateTime.now().toIso8601String();
      } else if (newStatus == 'cancelled') {
        updateData['cancelledAt'] = DateTime.now().toIso8601String();

        final orderToCancel = await getOrderByIdSupabase(orderId);
        if (orderToCancel != null) {
          for (final item in orderToCancel.items) {
            try {
              final prod = await sb.from('products').select('availableQuantity').eq('id', item.productId).maybeSingle();
              final current = (prod != null && prod['availableQuantity'] != null) ? (prod['availableQuantity'] as int) : 0;
              await sb.from('products').update({
                'availableQuantity': current + item.quantity,
              }).eq('id', item.productId);
            } catch (_) {}
          }
        }
      }

      await sb.from('orders').update(updateData).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update Supabase order status: $e');
    }
  }
}
