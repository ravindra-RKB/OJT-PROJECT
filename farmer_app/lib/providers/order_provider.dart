import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _service = OrderService();

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  Order? _selectedOrder;
  Order? get selectedOrder => _selectedOrder;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  /// Load orders for a buyer
  Future<void> loadBuyerOrders(String buyerId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      // Listen to real-time updates
      _service.getBuyerOrders(buyerId).listen((orders) {
        _orders = orders;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Load orders for a seller
  Future<void> loadSellerOrders(String sellerId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      // Listen to real-time updates
      _service.getSellerOrders(sellerId).listen((orders) {
        _orders = orders;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Get a single order
  Future<Order?> getOrder(String orderId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final order = await _service.getOrderById(orderId);
      _selectedOrder = order;
      return order;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Create a new order
  Future<Order?> createOrder({
    required String buyerId,
    required String buyerName,
    required String buyerEmail,
    required String buyerPhone,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    required String city,
    required String state,
    required String zipCode,
    required String paymentMethod,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final order = await _service.createOrder(
        buyerId: buyerId,
        buyerName: buyerName,
        buyerEmail: buyerEmail,
        buyerPhone: buyerPhone,
        items: items,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        city: city,
        state: state,
        zipCode: zipCode,
        paymentMethod: paymentMethod,
      );

      _selectedOrder = order;
      return order;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Update order status (seller)
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _service.updateOrderStatus(orderId, newStatus);

      // Update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
      }

      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder?.copyWith(status: newStatus);
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _service.updatePaymentStatus(orderId, paymentStatus);

      // Update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(paymentStatus: paymentStatus);
      }

      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder?.copyWith(paymentStatus: paymentStatus);
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Add tracking number (seller)
  Future<bool> addTrackingNumber(String orderId, String trackingNumber) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _service.addTrackingNumber(orderId, trackingNumber);

      // Update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          trackingNumber: trackingNumber,
          status: 'shipped',
        );
      }

      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder?.copyWith(
          trackingNumber: trackingNumber,
          status: 'shipped',
        );
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Cancel order (buyer)
  Future<bool> cancelOrder(String orderId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _service.cancelOrder(orderId);

      // Update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: 'cancelled');
      }

      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder?.copyWith(status: 'cancelled');
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Get order count by status
  Map<String, int> getOrderStats() {
    return {
      'total': _orders.length,
      'pending': _orders.where((o) => o.status == 'pending').length,
      'confirmed': _orders.where((o) => o.status == 'confirmed').length,
      'shipped': _orders.where((o) => o.status == 'shipped').length,
      'delivered': _orders.where((o) => o.status == 'delivered').length,
      'cancelled': _orders.where((o) => o.status == 'cancelled').length,
    };
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedOrder = null;
    notifyListeners();
  }
}
