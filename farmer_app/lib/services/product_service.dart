import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
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

  Future<String> _uploadImage(dynamic file, String sellerId,
      {required int index, void Function(int index, int bytesTransferred, int? totalBytes)? onProgress}) async {
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
        // listen for progress
        final sub = uploadTask.snapshotEvents.listen((s) {
          try {
            final transferred = s.bytesTransferred;
            final total = s.totalBytes == 0 ? null : s.totalBytes;
            if (onProgress != null) onProgress(index, transferred, total);
          } catch (_) {}
        });
        try {
          // wait for completion but avoid hanging too long
          await uploadTask.whenComplete(() {}).timeout(const Duration(seconds: 180));
        } on TimeoutException catch (e) {
          try {
            await uploadTask.cancel();
          } catch (_) {}
          await sub.cancel();
          throw Exception('Image upload timed out (web): ${e.toString()}');
        }
        await sub.cancel();
        final url = await ref.getDownloadURL();
        return url;
      } else {
        // Mobile/desktop: accept dart:io File or XFile
        if (file is XFile) {
          final f = File(file.path);
          final uploadTask = ref.putFile(f, SettableMetadata(contentType: 'image/jpeg'));
          final sub = uploadTask.snapshotEvents.listen((s) {
            try {
              final transferred = s.bytesTransferred;
              final total = s.totalBytes == 0 ? null : s.totalBytes;
              if (onProgress != null) onProgress(index, transferred, total);
            } catch (_) {}
          });
          try {
            await uploadTask.whenComplete(() {}).timeout(const Duration(seconds: 180));
          } on TimeoutException catch (e) {
            try {
              await uploadTask.cancel();
            } catch (_) {}
            await sub.cancel();
            throw Exception('Image upload timed out (mobile XFile): ${e.toString()}');
          }
          await sub.cancel();
          return await ref.getDownloadURL();
        } else if (file is File) {
          final uploadTask = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
          final sub = uploadTask.snapshotEvents.listen((s) {
            try {
              final transferred = s.bytesTransferred;
              final total = s.totalBytes == 0 ? null : s.totalBytes;
              if (onProgress != null) onProgress(index, transferred, total);
            } catch (_) {}
          });
          try {
            await uploadTask.whenComplete(() {}).timeout(const Duration(seconds: 180));
          } on TimeoutException catch (e) {
            try {
              await uploadTask.cancel();
            } catch (_) {}
            await sub.cancel();
            throw Exception('Image upload timed out (mobile File): ${e.toString()}');
          }
          await sub.cancel();
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
    void Function(int index, int bytesTransferred, int? totalBytes)? onImageProgress,
  }) async {
    final List<String> imageUrls = [];
    // Upload images sequentially with retries and rollback on failure
    for (int idx = 0; idx < imageFiles.length; idx++) {
      final file = imageFiles[idx];
      const int maxAttempts = 3;
      int attempt = 0;
      while (true) {
        attempt++;
        try {
          // attempt upload
          final url = await _uploadImage(file, sellerId, index: idx, onProgress: (i, transferred, total) {
            try {
              if (onImageProgress != null) onImageProgress(i, transferred, total);
            } catch (_) {}
          });
          imageUrls.add(url);
          break; // success -> next file
        } catch (e) {
          // log and retry if attempts left
          try {
            print('ProductService: upload error for image #$idx attempt $attempt: $e');
          } catch (_) {}
          if (attempt >= maxAttempts) {
            // rollback: delete any uploaded images so far
            for (final uploaded in imageUrls) {
              try {
                await _storage.refFromURL(uploaded).delete();
              } catch (_) {}
            }
            throw Exception('Failed to upload image #${idx + 1}: $e');
          }
          // small delay before retry
          await Future.delayed(Duration(seconds: 1 * attempt));
        }
      }
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

  /// Stream products in real-time (ordered by createdAt desc)
  Stream<List<Product>> streamProducts({double? userLat, double? userLng, double? maxDistanceKm, String? category}) {
    final qs = _db.collection(_collection).orderBy('createdAt', descending: true).snapshots();
    return qs.map((snap) {
      var products = snap.docs.map((d) => Product.fromDoc(d)).toList();

      // client-side distance filter (optional)
      if (userLat != null && userLng != null && maxDistanceKm != null) {
        products = products.where((p) {
          final distance = _distanceInKm(userLat, userLng, p.latitude, p.longitude);
          return distance <= maxDistanceKm;
        }).toList();
      }

      if (category != null && category.isNotEmpty) {
        products = products.where((p) => p.category == category).toList();
      }
      return products;
    });
  }
}
