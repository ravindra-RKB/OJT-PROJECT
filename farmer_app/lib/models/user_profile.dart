class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? farmSize;
  final String? cropType;
  final String? experience;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.farmSize,
    this.cropType,
    this.experience,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      farmSize: json['farmSize'] as String?,
      cropType: json['cropType'] as String?,
      experience: json['experience'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'farmSize': farmSize,
      'cropType': cropType,
      'experience': experience,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? farmSize,
    String? cropType,
    String? experience,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      farmSize: farmSize ?? this.farmSize,
      cropType: cropType ?? this.cropType,
      experience: experience ?? this.experience,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

