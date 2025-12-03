import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Cloudinary will be used for image hosting instead of Firebase Storage
import 'cloudinary_service.dart';
import 'supabase_service.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CloudinaryService _cloudinary = CloudinaryService();
  final String _collection = 'products';

  Future<String> _uploadImage(dynamic file, String sellerId,
      {required int index, void Function(int index, int bytesTransferred, int? totalBytes)? onProgress}) async {
    try {
      final id = Uuid().v4();
      final folder = 'product_images/$sellerId';
      print('ProductService: Uploading image to Cloudinary folder: $folder');

      if (kIsWeb) {
        // On web we must upload bytes
        print('ProductService: Preparing bytes for web upload...');
        Uint8List bytes;
        if (file is XFile) {
          print('ProductService: Converting XFile to bytes');
          bytes = await file.readAsBytes();
        } else if (file is Uint8List) {
          print('ProductService: File is already Uint8List');
          bytes = file;
        } else if (file is File) {
          print('ProductService: Converting File to bytes');
          bytes = await file.readAsBytes();
        } else {
          throw Exception('Unsupported file type for web upload: ${file.runtimeType}');
        }
        print('ProductService: Bytes prepared, size: ${bytes.length} bytes');
        
        // Upload bytes to Cloudinary (web)
        try {
          final url = await _cloudinary.uploadImage(file: bytes, folder: folder, fileName: '$id.jpg');
          print('ProductService: Cloudinary upload completed: $url');
          return url;
        } catch (e) {
          print('ProductService: Cloudinary upload error (web): $e');
          rethrow;
        }
      } else {
        // Mobile/desktop: accept dart:io File or XFile
        // Mobile/desktop: upload file path via Cloudinary
        try {
          String path;
          if (file is XFile) {
            path = file.path;
          } else if (file is File) {
            path = file.path;
          } else {
            throw Exception('Unsupported file type for upload: ${file.runtimeType}');
          }
          final url = await _cloudinary.uploadImage(file: path, folder: folder, fileName: '$id.jpg');
          print('ProductService: Cloudinary upload completed: $url');
          return url;
        } catch (e) {
          print('ProductService: Cloudinary upload error (mobile): $e');
          rethrow;
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
    List<String>? failedImages;
    
    // Upload images sequentially with retries  
    if (imageFiles.isNotEmpty) {
      failedImages = [];
      for (int idx = 0; idx < imageFiles.length; idx++) {
        final file = imageFiles[idx];
        const int maxAttempts = 2;
        int attempt = 0;
        bool uploaded = false;
        while (!uploaded && attempt < maxAttempts) {
          attempt++;
          try {
            print('ProductService: Uploading image #${idx + 1}/${imageFiles.length} (attempt $attempt)');
            final url = await _uploadImage(file, sellerId, index: idx, onProgress: (i, transferred, total) {
              try {
                if (onImageProgress != null) onImageProgress(i, transferred, total);
              } catch (_) {}
            });
            print('ProductService: Image #${idx + 1} uploaded successfully');
            imageUrls.add(url);
            uploaded = true;
          } catch (e) {
            print('ProductService: upload error for image #$idx attempt $attempt: $e');
            if (attempt >= maxAttempts) {
              print('ProductService: Image #${idx + 1} failed after $maxAttempts attempts - will create product without this image');
              failedImages.add('Image ${idx + 1}: $e');
            } else {
              // small delay before retry
              await Future.delayed(Duration(seconds: 2 * attempt));
            }
          }
        }
      }
    } else {
      print('ProductService: No images to upload');
    }

    print('ProductService: All images uploaded. Creating Firestore document...');

    try {
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

      print('ProductService: Document created with ID: ${docRef.id}');
      final doc = await docRef.get();
      final product = Product.fromDoc(doc);
      print('ProductService: Product creation complete: ${product.id}');
      return product;
    } catch (e) {
      print('ProductService: Error creating product in Firestore: $e');
      rethrow;
    }

  }

  /// Create a product in Supabase (Postgres). This is an optional migration
  /// path. The table `products` should exist with columns matching keys used
  /// below (sellerId, name, description, price, unit, images (json), latitude,
  /// longitude, address, availableQuantity, category, created_at).
  Future<Product> createProductSupabase({
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

    // Upload images to Cloudinary first
    if (imageFiles.isNotEmpty) {
      for (int idx = 0; idx < imageFiles.length; idx++) {
        final file = imageFiles[idx];
        try {
          final url = await _uploadImage(file, sellerId, index: idx, onProgress: onImageProgress);
          imageUrls.add(url);
        } catch (e) {
          print('ProductService: Failed to upload image #$idx to Cloudinary: $e');
        }
      }
    }

    final sb = SupabaseService().client;
    try {
      final resp = await sb.from('products').insert({
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
      }).select().maybeSingle();

      // The response may be a map representing the created row
      final data = resp as dynamic;
      if (data == null) throw Exception('Supabase insert returned null');
      final id = (data['id'] ?? '').toString();
      return Product.fromMap(Map<String, dynamic>.from(data), id);
    } catch (e) {
      print('ProductService: Error creating product in Supabase: $e');
      rethrow;
    }
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

  /// Update a product document. If [replaceImages] is true and [newImageFiles]
  /// is provided, the old images will be deleted from storage and replaced
  /// with newly uploaded images. Returns the updated Product.
  Future<Product> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    String? unit,
    List<dynamic>? newImageFiles,
    bool replaceImages = false,
    double? latitude,
    double? longitude,
    String? address,
    int? availableQuantity,
    String? category,
    void Function(int index, int bytesTransferred, int? totalBytes)? onImageProgress,
  }) async {
    try {
      final docRef = _db.collection(_collection).doc(productId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) throw Exception('Product $productId not found');
      final current = Product.fromDoc(snapshot);

      List<String> uploadedUrls = List.from(current.images);

      // If asked to replace images, upload new ones and delete old ones
      if (replaceImages && newImageFiles != null) {
        // upload new images
        uploadedUrls = [];
        for (int idx = 0; idx < newImageFiles.length; idx++) {
          final file = newImageFiles[idx];
          try {
            final url = await _uploadImage(file, current.sellerId, index: idx, onProgress: onImageProgress);
            uploadedUrls.add(url);
          } catch (e) {
            print('ProductService: Failed to upload replacement image #$idx: $e');
          }
        }

        // delete old images from storage (best-effort)
        for (final url in current.images) {
          try {
            await _deleteStorageFileByUrl(url);
          } catch (e) {
            print('ProductService: Failed to delete old image $url: $e');
          }
        }
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (unit != null) updateData['unit'] = unit;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;
      if (address != null) updateData['address'] = address;
      if (availableQuantity != null) updateData['availableQuantity'] = availableQuantity;
      if (category != null) updateData['category'] = category;
      if (replaceImages) updateData['images'] = uploadedUrls;

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();
        await docRef.update(updateData);
      }

      final updatedDoc = await docRef.get();
      return Product.fromDoc(updatedDoc);
    } catch (e) {
      print('ProductService: Error updating product $productId: $e');
      rethrow;
    }
  }

  /// Delete a product and all associated images from storage.
  Future<void> deleteProduct(String productId) async {
    try {
      final docRef = _db.collection(_collection).doc(productId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) return;
      final product = Product.fromDoc(snapshot);

      // Delete images from storage (best-effort)
      for (final url in product.images) {
        try {
          await _deleteStorageFileByUrl(url);
        } catch (e) {
          print('ProductService: Failed to delete image $url: $e');
        }
      }

      // Delete Firestore document
      await docRef.delete();
      print('ProductService: Deleted product $productId');
    } catch (e) {
      print('ProductService: Error deleting product $productId: $e');
      rethrow;
    }
  }

  Future<void> _deleteStorageFileByUrl(String url) async {
    try {
      // Cloudinary deletion requires signed server-side requests (API secret).
      // For now, do not attempt deletion from client; log and continue.
      print('ProductService: _deleteStorageFileByUrl called for $url - skipping deletion on client (requires server-side API)');
    } catch (e) {
      print('ProductService: Error deleting storage file by URL $url: $e');
      rethrow;
    }
  }
}
