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

  /// Construct from a plain map (e.g., returned by Supabase). Expects
  /// timestamps under `created_at` (ISO string) or `createdAt`.
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    dynamic created = map['created_at'] ?? map['createdAt'];
    Timestamp ts;
    try {
      if (created == null) {
        ts = Timestamp.now();
      } else if (created is String) {
        ts = Timestamp.fromDate(DateTime.parse(created));
      } else if (created is DateTime) {
        ts = Timestamp.fromDate(created);
      } else {
        // Fallback
        ts = Timestamp.now();
      }
    } catch (_) {
      ts = Timestamp.now();
    }

    return Product(
      id: id,
      sellerId: map['sellerId'] ?? map['seller_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      address: map['address'] ?? '',
      availableQuantity: (map['availableQuantity'] ?? map['available_quantity'] ?? 0).toInt(),
      category: map['category'] ?? '',
      createdAt: ts,
    );
  }
}
