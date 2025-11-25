import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.images.first,
                        fit: BoxFit.cover,
                        placeholder: (c, s) => Container(color: Colors.grey[200]),
                        errorWidget: (c, s, e) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                      )
                    : Image.asset('assets/farm.jpg', fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(children: [
                  Text('₹${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${product.unit} • ${product.address}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
