import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  final String _collection = 'products';
  final String _bucket = 'uploads'; // ensure this bucket exists in Supabase storage

  Future<String> _uploadImage(dynamic file, String sellerId,
      {required int index, void Function(int index, int bytesTransferred, int? totalBytes)? onProgress}) async {
    try {
      final id = Uuid().v4();
      final path = 'product_images/$sellerId/$id.jpg';
      final storage = Supabase.instance.client.storage;

      print('ProductService: Starting upload for image #$index to path: $path');

      // Prepare data
      Uint8List bytes;
      if (kIsWeb) {
        if (file is XFile) {
          bytes = await file.readAsBytes();
        } else if (file is Uint8List) {
          bytes = file;
        } else if (file is File) {
          bytes = await file.readAsBytes();
        } else {
          throw Exception('Unsupported file type for web upload: ${file.runtimeType}');
        }
      } else {
        if (file is XFile) {
          final f = File(file.path);
          bytes = await f.readAsBytes();
        } else if (file is File) {
          bytes = await file.readAsBytes();
        } else if (file is Uint8List) {
          bytes = file;
        } else {
          throw Exception('Unsupported file type for upload: ${file.runtimeType}');
        }
      }

      print('ProductService: Image #$index bytes: ${bytes.length}');

      // Attempt upload to Supabase storage
      try {
        print('ProductService: Attempting uploadBinary for $path');
        await storage.from(_bucket).uploadBinary(path, bytes);
        print('ProductService: uploadBinary succeeded for $path');
        
        final String publicUrl = storage.from(_bucket).getPublicUrl(path);
        print('ProductService: Generated public URL: $publicUrl');
        
        if (onProgress != null) onProgress(index, bytes.length, bytes.length);
        return publicUrl;
      } catch (e) {
        print('ProductService: uploadBinary failed: $e');
        
        // Fallback: if running on native and we have a File path, try upload(File)
        try {
          if (!kIsWeb && file is XFile) {
            final f = File(file.path);
            if (await f.exists()) {
              print('ProductService: Attempting fallback upload() for $path');
              await storage.from(_bucket).upload(path, f);
              print('ProductService: upload() succeeded for $path');
              
              final String publicUrl = storage.from(_bucket).getPublicUrl(path);
              print('ProductService: Generated public URL (fallback): $publicUrl');
              
              if (onProgress != null) onProgress(index, bytes.length, bytes.length);
              return publicUrl;
            }
          }
        } catch (e2) {
          print('ProductService: Fallback upload() failed: $e2');
        }

        throw Exception('Supabase storage upload failed: $e');
      }
    } catch (e) {
      print('ProductService: Exception in _uploadImage: $e');
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

    print('ProductService: createProduct called with ${imageFiles.length} images');

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
            print('ProductService: Uploading image $idx (attempt $attempt/$maxAttempts)');
            final url = await _uploadImage(file, sellerId, index: idx, onProgress: (i, transferred, total) {
              try {
                if (onImageProgress != null) onImageProgress(i, transferred, total);
              } catch (_) {}
            });
            print('ProductService: Successfully got URL for image $idx: $url');
            imageUrls.add(url);
            uploaded = true;
          } catch (e) {
            print('ProductService: Image $idx upload failed (attempt $attempt): $e');
            if (attempt >= maxAttempts) {
              failedImages.add('Image ${idx + 1}: $e');
            } else {
              await Future.delayed(Duration(seconds: 2 * attempt));
            }
          }
        }
      }
    }

    print('ProductService: Collected ${imageUrls.length} image URLs: $imageUrls');

    try {
      final id = Uuid().v4();
      final record = {
        'id': id,
        'seller_id': sellerId,
        'name': name,
        'description': description,
        'price': price,
        'unit': unit,
        'images': imageUrls,  // ← This MUST be saved
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'available_quantity': availableQuantity,
        'category': category,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('ProductService: Inserting product record with images: ${record['images']}');
      
      final res = await Supabase.instance.client.from(_collection).insert(record).select().single();
      final data = Map<String, dynamic>.from(res);
      
      print('ProductService: Product inserted. Database images field: ${data['images']}');
      
      return Product.fromMap(data, data['id'] ?? id);
    } catch (e) {
      print('ProductService: Error in createProduct insert: $e');
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
    final realtime = Supabase.instance.client.from('products').stream(primaryKey: ['id']);
    return realtime.map((payload) {
      // payload may be a List or a single record depending on SDK - normalize
      List<dynamic> rows;
      try {
        rows = List<dynamic>.from(payload as List);
      } catch (_) {
        if (payload is Map) {
          rows = [payload];
        } else {
          rows = [];
        }
      }
      var products = rows.map((r) {
        final row = Map<String, dynamic>.from(r as Map);
        final id = row['id']?.toString() ?? '';
        return Product.fromMap(row, id);
      }).toList();

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
      final sel = await Supabase.instance.client.from(_collection).select().eq('id', productId).single();
      final current = Product.fromMap(Map<String, dynamic>.from(sel), productId);

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
      if (availableQuantity != null) updateData['available_quantity'] = availableQuantity;
      if (category != null) updateData['category'] = category;
      if (replaceImages) updateData['images'] = uploadedUrls;

      if (updateData.isNotEmpty) {
        updateData['updated_at'] = DateTime.now().toIso8601String();
        await Supabase.instance.client.from(_collection).update(updateData).eq('id', productId).select().single();
      }

      final updated = await Supabase.instance.client.from(_collection).select().eq('id', productId).single();
      return Product.fromMap(Map<String, dynamic>.from(updated), productId);
    } catch (e) {
      print('ProductService: Error updating product $productId: $e');
      rethrow;
    }
  }

  /// Delete a product and all associated images from storage.
  Future<void> deleteProduct(String productId) async {
    try {
      final sel = await Supabase.instance.client.from(_collection).select().eq('id', productId).single();
      final product = Product.fromMap(Map<String, dynamic>.from(sel), productId);

      // Delete images from storage (best-effort)
      for (final url in product.images) {
        try {
          await _deleteStorageFileByUrl(url);
        } catch (e) {
          print('ProductService: Failed to delete image $url: $e');
        }
      }

      // Delete record
      await Supabase.instance.client.from(_collection).delete().eq('id', productId);
      print('ProductService: Deleted product $productId');
    } catch (e) {
      print('ProductService: Error deleting product $productId: $e');
      rethrow;
    }
  }

  Future<void> _deleteStorageFileByUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      // Look for bucket name in path segments and extract the file path after the bucket
      final segments = uri.pathSegments;
      int idx = segments.indexOf(_bucket);
      String path;
      if (idx >= 0 && idx + 1 < segments.length) {
        path = segments.sublist(idx + 1).join('/');
      } else {
        // fallback: try to extract last two segments
        path = segments.skip(segments.length - 2).join('/');
      }
      await Supabase.instance.client.storage.from(_bucket).remove([path]);
      print('ProductService: Deleted storage file at $url (path: $path)');
    } catch (e) {
      print('ProductService: Error deleting storage file by URL $url: $e');
      rethrow;
    }
  }
}
