import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart' as order_models;

class OrderService {
  final String _ordersCollection = 'orders';
  final String _productsCollection = 'products';

  SupabaseClient get _db => Supabase.instance.client;

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
      final now = DateTime.now().toIso8601String();
      final itemsJson = items.map((i) => i.toMap()).toList();

      final orderData = {
        'buyer_id': buyerId,
        'buyer_name': buyerName,
        'buyer_email': buyerEmail,
        'buyer_phone': buyerPhone,
        'items': itemsJson, // JSONB
        'total_amount': totalAmount,
        'status': 'pending',
        'delivery_address': deliveryAddress,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'payment_method': paymentMethod,
        'payment_status': paymentMethod == 'cod' ? 'pending' : 'pending',
        'created_at': now,
      };

      // Insert order
      final res = await _db.from(_ordersCollection).insert(orderData).select().single();

      final orderId = res['id']?.toString() ?? '';

      // Atomically update product quantities
      for (final item in items) {
        await _db.from(_productsCollection)
            .update({'available_quantity': 'available_quantity - ${item.quantity}'})
            .eq('id', item.productId);
      }

      // Return the created order
      return order_models.Order.fromMap(orderId, Map<String, dynamic>.from(res));
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get order by ID
  Future<order_models.Order?> getOrderById(String orderId) async {
    try {
      final res = await _db.from(_ordersCollection).select().eq('id', orderId).single();
      return order_models.Order.fromMap(orderId, Map<String, dynamic>.from(res));
    } catch (e) {
      return null; // Not found
    }
  }

  /// Get all orders for a buyer
  Stream<List<order_models.Order>> getBuyerOrders(String buyerId) {
    final realtime = _db.from(_ordersCollection).stream(primaryKey: ['id']);
    return realtime.map((payload) {
      try {
        List<dynamic> rows;
        try {
          rows = List<dynamic>.from(payload as List);
        } catch (_) {
          if (payload is Map) {
            rows = [payload];
          } else {
            rows = [];
          }
        }
        return rows
            .map((r) {
              final row = Map<String, dynamic>.from(r as Map);
              final id = row['id']?.toString() ?? '';
              return order_models.Order.fromMap(id, row);
            })
            .where((order) => order.buyerId == buyerId)
            .toList();
      } catch (e) {
        print('Error parsing buyer orders: $e');
        return [];
      }
    });
  }

  /// Get all orders for a seller (by product seller ID)
  Stream<List<order_models.Order>> getSellerOrders(String sellerId) {
    final realtime = _db.from(_ordersCollection).stream(primaryKey: ['id']);
    return realtime.map((payload) {
      try {
        List<dynamic> rows;
        try {
          rows = List<dynamic>.from(payload as List);
        } catch (_) {
          if (payload is Map) {
            rows = [payload];
          } else {
            rows = [];
          }
        }
        return rows
            .map((r) {
              final row = Map<String, dynamic>.from(r as Map);
              final id = row['id']?.toString() ?? '';
              return order_models.Order.fromMap(id, row);
            })
            .where((order) => order.items.any((item) => item.sellerId == sellerId))
            .toList();
      } catch (e) {
        print('Error parsing seller orders: $e');
        return [];
      }
    });
  }

  /// Get seller's orders with a specific seller ID in items
  Future<List<order_models.Order>> getSellerOrdersAdvanced(String sellerId) async {
    try {
      final rows = await _db.from(_ordersCollection).select();
      final orders = (rows as List)
          .map((row) {
            final id = row['id']?.toString() ?? '';
            return order_models.Order.fromMap(id, Map<String, dynamic>.from(row));
          })
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
      final now = DateTime.now().toIso8601String();
      final updateData = <String, dynamic>{'status': newStatus};

      // Add timestamp based on status
      if (newStatus == 'confirmed') {
        updateData['confirmed_at'] = now;
      } else if (newStatus == 'shipped') {
        updateData['shipped_at'] = now;
      } else if (newStatus == 'delivered') {
        updateData['delivered_at'] = now;
      } else if (newStatus == 'cancelled') {
        updateData['cancelled_at'] = now;

        // Restore product quantities
        final orderToCancel = await getOrderById(orderId);
        if (orderToCancel != null) {
          for (final item in orderToCancel.items) {
            await _db.from(_productsCollection)
                .update({'available_quantity': 'available_quantity + ${item.quantity}'})
                .eq('id', item.productId);
          }
        }
      }

      await _db.from(_ordersCollection).update(updateData).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Update payment status
  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      await _db.from(_ordersCollection).update({
        'payment_status': paymentStatus,
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Add tracking number
  Future<void> addTrackingNumber(String orderId, String trackingNumber) async {
    try {
      final now = DateTime.now().toIso8601String();
      await _db.from(_ordersCollection).update({
        'tracking_number': trackingNumber,
        'shipped_at': now,
        'status': 'shipped',
      }).eq('id', orderId);
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
}
