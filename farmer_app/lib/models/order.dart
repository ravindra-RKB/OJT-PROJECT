import 'package:cloud_firestore/cloud_firestore.dart';

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
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'productImage': productImage,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      productImage: map['productImage'] ?? '',
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
  final Timestamp createdAt;
  final Timestamp? confirmedAt;
  final Timestamp? shippedAt;
  final Timestamp? deliveredAt;
  final Timestamp? cancelledAt;
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
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerEmail': buyerEmail,
      'buyerPhone': buyerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
      'confirmedAt': confirmedAt,
      'shippedAt': shippedAt,
      'deliveredAt': deliveredAt,
      'cancelledAt': cancelledAt,
      'trackingNumber': trackingNumber,
      'notes': notes,
    };
  }

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    return Order(
      id: id,
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerEmail: map['buyerEmail'] ?? '',
      buyerPhone: map['buyerPhone'] ?? '',
      items: (map['items'] as List?)?.map((item) => OrderItem.fromMap(item)).toList() ?? [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      deliveryAddress: map['deliveryAddress'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'cod',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      confirmedAt: map['confirmedAt'],
      shippedAt: map['shippedAt'],
      deliveredAt: map['deliveredAt'],
      cancelledAt: map['cancelledAt'],
      trackingNumber: map['trackingNumber'],
      notes: map['notes'],
    );
  }

  /// Construct an Order from a Supabase/Postgres row representation.
  /// Supabase will typically return timestamps as ISO strings or DateTime objects.
  factory Order.fromSupabase(String id, Map<String, dynamic> map) {
    DateTime parseTs(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    final created = parseTs(map['created_at'] ?? map['createdAt'] ?? map['createdAt']);
    Timestamp createdTs = Timestamp.fromDate(created);

    Timestamp? parseOptional(dynamic v) {
      if (v == null) return null;
      final dt = parseTs(v);
      return Timestamp.fromDate(dt);
    }

    return Order(
      id: id,
      buyerId: map['buyerId'] ?? map['buyer_id'] ?? '',
      buyerName: map['buyerName'] ?? map['buyer_name'] ?? '',
      buyerEmail: map['buyerEmail'] ?? map['buyer_email'] ?? '',
      buyerPhone: map['buyerPhone'] ?? map['buyer_phone'] ?? '',
      items: (map['items'] as List?)?.map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item))).toList() ?? [],
      totalAmount: (map['totalAmount'] ?? map['total_amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      deliveryAddress: map['deliveryAddress'] ?? map['delivery_address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? map['zip_code'] ?? '',
      paymentMethod: map['paymentMethod'] ?? map['payment_method'] ?? 'cod',
      paymentStatus: map['paymentStatus'] ?? map['payment_status'] ?? 'pending',
      createdAt: createdTs,
      confirmedAt: parseOptional(map['confirmedAt'] ?? map['confirmed_at']),
      shippedAt: parseOptional(map['shippedAt'] ?? map['shipped_at']),
      deliveredAt: parseOptional(map['deliveredAt'] ?? map['delivered_at']),
      cancelledAt: parseOptional(map['cancelledAt'] ?? map['cancelled_at']),
      trackingNumber: map['trackingNumber'] ?? map['tracking_number'],
      notes: map['notes'],
    );
  }

  Order copyWith({
    String? status,
    String? paymentStatus,
    Timestamp? confirmedAt,
    Timestamp? shippedAt,
    Timestamp? deliveredAt,
    Timestamp? cancelledAt,
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
