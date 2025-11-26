import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _qty = 1;
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: Stack(children: [
              PageView.builder(
                controller: _pageController,
                itemCount: p.images.isNotEmpty ? p.images.length : 1,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemBuilder: (context, i) {
                  if (p.images.isNotEmpty) {
                    return CachedNetworkImage(imageUrl: p.images[i], fit: BoxFit.cover);
                  }
                  return Image.asset('assets/farm.jpg', fit: BoxFit.cover);
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
                  p.images.isNotEmpty ? p.images.length : 1,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _pageIndex == i ? 10 : 8,
                    height: _pageIndex == i ? 10 : 8,
                    decoration: BoxDecoration(color: _pageIndex == i ? Colors.white : Colors.white54, shape: BoxShape.circle),
                  ),
                )),
              )
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('₹${p.price.toStringAsFixed(2)} / ${p.unit}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(p.description),
                  const SizedBox(height: 12),
                  Text('Available: ${p.availableQuantity}'),
                  const SizedBox(height: 12),
                  Text('Seller location: ${p.address}'),
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(children: [
              IconButton(onPressed: () => setState(() => _qty = (_qty - 1).clamp(1, 999)), icon: const Icon(Icons.remove)),
              Text('$_qty'),
              IconButton(onPressed: () => setState(() => _qty = (_qty + 1).clamp(1, 999)), icon: const Icon(Icons.add)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  final cart = Provider.of<CartProvider>(context, listen: false);
                  for (int i = 0; i < _qty; i++) cart.add(p);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to cart'),
              )
            ]),
          )
        ],
      ),
    );
  }
}
