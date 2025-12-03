import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _zipCtrl;

  String _paymentMethod = 'cod'; // 'cod' or 'online'
  bool _agreeToTerms = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _zipCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and conditions')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final cart = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      
      final user = auth.user;
      if (user == null) {
        throw Exception('Please sign in to place an order');
      }

      if (cart.items.isEmpty) {
        throw Exception('Your cart is empty');
      }

      // Create OrderItem list from cart
      final orderItems = cart.items.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          price: cartItem.product.price,
          quantity: cartItem.quantity,
          sellerId: cartItem.product.sellerId,
          sellerName: '', // Could be fetched from seller collection if needed
          productImage: cartItem.product.images.isNotEmpty 
              ? cartItem.product.images.first 
              : '',
        );
      }).toList();

      // Create order through order provider
      final order = await orderProvider.createOrder(
        buyerId: user.uid,
        buyerName: _nameCtrl.text,
        buyerEmail: _emailCtrl.text,
        buyerPhone: _phoneCtrl.text,
        items: orderItems,
        totalAmount: cart.total,
        deliveryAddress: _addressCtrl.text,
        city: _cityCtrl.text,
        state: _stateCtrl.text,
        zipCode: _zipCtrl.text,
        paymentMethod: _paymentMethod,
      );

      if (order != null) {
        // Clear cart after successful order
        cart.clear();

        if (!mounted) return;

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF8BC34A), size: 32),
                SizedBox(width: 12),
                Text('Order Placed!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your order #${order.id.substring(0, 8).toUpperCase()} has been placed successfully!'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BC34A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Items: ${order.totalItems}',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Status: ${order.status.toUpperCase()}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF8BC34A))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('You will receive a confirmation email shortly.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: const Text('Continue Shopping'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC34A),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushNamed('/my-orders');
                },
                child: const Text('Track Order', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF617A2E),
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_checkout, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF617A2E)),
                    onPressed: () => Navigator.of(context).pushNamed('/marketplace'),
                    child: const Text('Continue Shopping', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Summary
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Order Summary',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cart.items.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, i) {
                                  final item = cart.items[i];
                                  return Row(
                                    children: [
                                      if (item.product.images.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            item.product.images.first,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.image),
                                        ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.product.name,
                                                style: const TextStyle(fontWeight: FontWeight.w600)),
                                            Text('₹${item.product.price} x ${item.quantity}',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Text('₹${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Amount',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('₹${cart.total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8BC34A))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Delivery Address Section
                      const Text('Delivery Address',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D5016))),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person, color: Color(0xFF617A2E)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (v) => (v?.isEmpty ?? true) ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email, color: Color(0xFF617A2E)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Enter email';
                          if (!v!.contains('@')) return 'Enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone, color: Color(0xFF617A2E)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Enter phone' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.location_on, color: Color(0xFF617A2E)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        maxLines: 2,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Enter address' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityCtrl,
                              decoration: InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              validator: (v) => (v?.isEmpty ?? true) ? 'Enter city' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _stateCtrl,
                              decoration: InputDecoration(
                                labelText: 'State',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              validator: (v) => (v?.isEmpty ?? true) ? 'Enter state' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _zipCtrl,
                        decoration: InputDecoration(
                          labelText: 'Zip Code',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (v) => (v?.isEmpty ?? true) ? 'Enter zip code' : null,
                      ),
                      const SizedBox(height: 24),

                      // Payment Method Section
                      const Text('Payment Method',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D5016))),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        title: const Text('Cash on Delivery (COD)'),
                        subtitle: const Text('Pay when you receive the order'),
                        value: 'cod',
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v ?? 'cod'),
                        activeColor: const Color(0xFF8BC34A),
                      ),
                      RadioListTile<String>(
                        title: const Text('Online Payment'),
                        subtitle: const Text('Pay using card, UPI, or net banking'),
                        value: 'online',
                        groupValue: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v ?? 'cod'),
                        activeColor: const Color(0xFF8BC34A),
                      ),
                      const SizedBox(height: 24),

                      // Terms and Conditions
                      CheckboxListTile(
                        title: const Text('I agree to the terms and conditions'),
                        value: _agreeToTerms,
                        onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                        activeColor: const Color(0xFF8BC34A),
                      ),
                      const SizedBox(height: 24),

                      // Place Order Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8BC34A),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isProcessing ? null : _placeOrder,
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : const Text('Place Order',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
