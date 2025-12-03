import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';

/// Simple Cloudinary wrapper. Requires you to configure the
/// `CLOUDINARY_CLOUD_NAME` and `CLOUDINARY_UPLOAD_PRESET` in your
/// environment or replace the placeholders below.
class CloudinaryService {
  // Replace these with your Cloudinary details or load from env (flutter_dotenv)
  static const String cloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME', defaultValue: 'your-cloud-name');
  static const String uploadPreset = String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET', defaultValue: 'your-upload-preset');

  final CloudinaryPublic _client = CloudinaryPublic(cloudName, uploadPreset, cache: false);

  /// Uploads a file to Cloudinary. `filePathOrBytes` may be a local file path
  /// or bytes (for web). The returned string is the secure URL.
  Future<String> uploadImage({required dynamic file, required String folder, String? fileName}) async {
    try {
      CloudinaryResponse res;
      if (file is Uint8List) {
        final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
        res = await _client.uploadFile(CloudinaryFile.fromBytes(file, folder: folder, fileName: name));
      } else if (file is String) {
        // treat as file path
        res = await _client.uploadFile(CloudinaryFile.fromFile(file, folder: folder));
      } else {
        // XFile or File types should provide a path
        try {
          final path = (file.path ?? '') as String;
          res = await _client.uploadFile(CloudinaryFile.fromFile(path, folder: folder));
        } catch (e) {
          // fallback to converting to bytes isn't implemented here
          rethrow;
        }
      }
      return res.secureUrl;
    } catch (e) {
      rethrow;
    }
  }
}
