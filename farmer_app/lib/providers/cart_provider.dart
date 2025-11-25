import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  void add(Product p) {
    if (_items.containsKey(p.id)) {
      _items[p.id]!.quantity += 1;
    } else {
      _items[p.id] = CartItem(product: p, quantity: 1);
    }
    notifyListeners();
  }

  void remove(Product p) {
    if (!_items.containsKey(p.id)) return;
    _items[p.id]!.quantity -= 1;
    if (_items[p.id]!.quantity <= 0) _items.remove(p.id);
    notifyListeners();
  }

  double get total => _items.values.fold(0.0, (sum, it) => sum + it.product.price * it.quantity);

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
