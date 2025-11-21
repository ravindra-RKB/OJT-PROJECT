class MandiPrice {
  final String commodity;
  final String market;
  final double price;
  final String unit;
  final DateTime date;
  final String? state;
  final String? district;

  MandiPrice({
    required this.commodity,
    required this.market,
    required this.price,
    required this.unit,
    required this.date,
    this.state,
    this.district,
  });

  factory MandiPrice.fromJson(Map<String, dynamic> json) {
    return MandiPrice(
      commodity: json['commodity'] as String? ?? 'Unknown',
      market: json['market'] as String? ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'Quintal',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      state: json['state'] as String?,
      district: json['district'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commodity': commodity,
      'market': market,
      'price': price,
      'unit': unit,
      'date': date.toIso8601String(),
      'state': state,
      'district': district,
    };
  }
}

