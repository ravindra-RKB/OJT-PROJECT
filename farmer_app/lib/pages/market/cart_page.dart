import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _checkout(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = auth.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to checkout')));
      return;
    }
    
    final orderItems = cart.items
        .map((c) => OrderItem(
              productId: c.product.id,
              productName: c.product.name,
              price: c.product.price,
              quantity: c.quantity,
              sellerId: c.product.sellerId,
              sellerName: '',
              productImage: c.product.images.isNotEmpty ? c.product.images.first : '',
            ))
        .toList();
    final total = cart.total;
    
    try {
      final orderService = OrderService();
      await orderService.createOrder(
        buyerId: user.id,
        buyerName: user.email?.split('@').first ?? 'User',
        buyerEmail: user.email ?? '',
        buyerPhone: '',
        items: orderItems,
        totalAmount: total,
        deliveryAddress: '',
        city: '',
        state: '',
        zipCode: '',
        paymentMethod: 'cod',
      );
      cart.clear();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed')));
      Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : Column(children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, i) {
                    final c = cart.items[i];
                    return ListTile(
                      leading: c.product.images.isNotEmpty ? Image.network(c.product.images.first, width: 56, height: 56, fit: BoxFit.cover) : null,
                      title: Text(c.product.name),
                      subtitle: Text('₹${c.product.price} x ${c.quantity}'),
                      trailing: IconButton(onPressed: () => cart.remove(c.product), icon: const Icon(Icons.remove_circle)),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(children: [
                  Row(children: [Text('Total:', style: Theme.of(context).textTheme.titleLarge), const Spacer(), Text('₹${cart.total.toStringAsFixed(2)}')]),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => _checkout(context), child: const Text('Checkout')),
                ]),
              )
            ]),
    );
  }
}
