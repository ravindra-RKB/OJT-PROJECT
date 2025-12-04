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
  final DateTime createdAt;

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
      'id': id,
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'available_quantity': availableQuantity,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      sellerId: map['seller_id'] ?? map['sellerId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      latitude: (map['latitude'] ?? map['lat'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? map['lng'] ?? 0).toDouble(),
      address: map['address'] ?? '',
      availableQuantity: (map['available_quantity'] ?? map['availableQuantity'] ?? 0).toInt(),
      category: map['category'] ?? '',
      createdAt: map['created_at'] is String
          ? DateTime.parse(map['created_at'])
          : (map['created_at'] is DateTime ? map['created_at'] : DateTime.now()),
    );
  }
}
