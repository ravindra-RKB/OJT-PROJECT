class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String sellerId;
  final String sellerName;
  final String productImage;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.sellerId,
    required this.sellerName,
    required this.productImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'product_image': productImage,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id'] ?? map['productId'] ?? '',
      productName: map['product_name'] ?? map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      sellerId: map['seller_id'] ?? map['sellerId'] ?? '',
      sellerName: map['seller_name'] ?? map['sellerName'] ?? '',
      productImage: map['product_image'] ?? map['productImage'] ?? '',
    );
  }
}

class Order {
  final String id;
  final String buyerId;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // pending, confirmed, shipped, delivered, cancelled
  final String deliveryAddress;
  final String city;
  final String state;
  final String zipCode;
  final String paymentMethod; // cod, online
  final String paymentStatus; // pending, completed, failed
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? trackingNumber;
  final String? notes;

  Order({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.trackingNumber,
    this.notes,
  });

  int get totalItems => items.fold<int>(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toMap() {
    return {
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'buyer_email': buyerEmail,
      'buyer_phone': buyerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'delivery_address': deliveryAddress,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'tracking_number': trackingNumber,
      'notes': notes,
    };
  }

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    final itemsRaw = map['items'] as List? ?? [];
    return Order(
      id: id,
      buyerId: map['buyer_id'] ?? map['buyerId'] ?? '',
      buyerName: map['buyer_name'] ?? map['buyerName'] ?? '',
      buyerEmail: map['buyer_email'] ?? map['buyerEmail'] ?? '',
      buyerPhone: map['buyer_phone'] ?? map['buyerPhone'] ?? '',
      items: itemsRaw.map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item))).toList(),
      totalAmount: (map['total_amount'] ?? map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      deliveryAddress: map['delivery_address'] ?? map['deliveryAddress'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zip_code'] ?? map['zipCode'] ?? '',
      paymentMethod: map['payment_method'] ?? map['paymentMethod'] ?? 'cod',
      paymentStatus: map['payment_status'] ?? map['paymentStatus'] ?? 'pending',
      createdAt: map['created_at'] is String
          ? DateTime.parse(map['created_at'])
          : (map['created_at'] is DateTime ? map['created_at'] : DateTime.now()),
      confirmedAt: map['confirmed_at'] is String ? DateTime.parse(map['confirmed_at']) : null,
      shippedAt: map['shipped_at'] is String ? DateTime.parse(map['shipped_at']) : null,
      deliveredAt: map['delivered_at'] is String ? DateTime.parse(map['delivered_at']) : null,
      cancelledAt: map['cancelled_at'] is String ? DateTime.parse(map['cancelled_at']) : null,
      trackingNumber: map['tracking_number'] ?? map['trackingNumber'],
      notes: map['notes'],
    );
  }

  Order copyWith({
    String? status,
    String? paymentStatus,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? trackingNumber,
    String? notes,
  }) {
    return Order(
      id: id,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerEmail: buyerEmail,
      buyerPhone: buyerPhone,
      items: items,
      totalAmount: totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress,
      city: city,
      state: state,
      zipCode: zipCode,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
    );
  }
}
