import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'products';

  Future<String> _uploadImage(dynamic file, String sellerId) async {
    try {
      final id = Uuid().v4();
      final ref = _storage.ref().child('product_images/$sellerId/$id.jpg');

      if (kIsWeb) {
        // On web we must upload bytes
        Uint8List bytes;
        if (file is XFile) {
          bytes = await file.readAsBytes();
        } else if (file is Uint8List) {
          bytes = file;
        } else if (file is File) {
          bytes = await file.readAsBytes();
        } else {
          throw Exception('Unsupported file type for web upload: ${file.runtimeType}');
        }
        final uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        await uploadTask;
        final url = await ref.getDownloadURL();
        return url;
      } else {
        // Mobile/desktop: accept dart:io File or XFile
        if (file is XFile) {
          final f = File(file.path);
          final uploadTask = ref.putFile(f, SettableMetadata(contentType: 'image/jpeg'));
          await uploadTask;
          return await ref.getDownloadURL();
        } else if (file is File) {
          final uploadTask = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
          await uploadTask;
          return await ref.getDownloadURL();
        } else {
          throw Exception('Unsupported file type for upload: ${file.runtimeType}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> createProduct({
    required String sellerId,
    required String name,
    required String description,
    required double price,
    required String unit,
    required List<dynamic> imageFiles,
    required double latitude,
    required double longitude,
    required String address,
    required int availableQuantity,
    required String category,
  }) async {
    final List<String> imageUrls = [];
    for (final file in imageFiles) {
      final url = await _uploadImage(file, sellerId);
      imageUrls.add(url);
    }

    final docRef = await _db.collection(_collection).add({
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'images': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'availableQuantity': availableQuantity,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final doc = await docRef.get();
    return Product.fromDoc(doc);
  }

  Future<List<Product>> fetchProducts({
    double? userLat,
    double? userLng,
    double? maxDistanceKm,
    String? category,
  }) async {
    final snapshot = await _db.collection(_collection).orderBy('createdAt', descending: true).get();
    final products = snapshot.docs.map((d) => Product.fromDoc(d)).toList();

    if (userLat != null && userLng != null && maxDistanceKm != null) {
      products.retainWhere((p) {
        final distance = _distanceInKm(userLat, userLng, p.latitude, p.longitude);
        return distance <= maxDistanceKm;
      });
    }

    if (category != null && category.isNotEmpty) {
      return products.where((p) => p.category == category).toList();
    }

    return products;
  }

  double _distanceInKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}
