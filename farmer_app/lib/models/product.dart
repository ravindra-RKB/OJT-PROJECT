import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final double price;
  final String unit;
  final List<String> images;
  final double latitude;
  final double longitude;
  final String address;
  final int availableQuantity;
  final String category;
  final Timestamp createdAt;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.images,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.availableQuantity,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'availableQuantity': availableQuantity,
      'category': category,
      'createdAt': createdAt,
    };
  }

  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      address: data['address'] ?? '',
      availableQuantity: (data['availableQuantity'] ?? 0).toInt(),
      category: data['category'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
