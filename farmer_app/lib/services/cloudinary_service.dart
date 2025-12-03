import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloudinary_public/cloudinary_public.dart' show CloudinaryPublic, CloudinaryFile;

/// Simple Cloudinary wrapper. Requires you to configure the
/// `CLOUDINARY_CLOUD_NAME` and `CLOUDINARY_UPLOAD_PRESET` in your
/// environment or replace the placeholders below.
class CloudinaryService {
  // Replace these with your Cloudinary details or load from env (flutter_dotenv)
  static const String cloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME', defaultValue: 'your-cloud-name');
  static const String uploadPreset = String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET', defaultValue: 'your-upload-preset');

  final CloudinaryPublic _client = CloudinaryPublic(cloudName, uploadPreset, cache: false);

  /// Uploads a file to Cloudinary. `file` may be a local file path or bytes
  /// (for web). Returns the secure URL on success.
  Future<String> uploadImage({required dynamic file, required String folder, String? fileName}) async {
    try {
      // If bytes (web), do a multipart upload directly to Cloudinary unsigned endpoint
      if (file is Uint8List) {
        final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
        final request = http.MultipartRequest('POST', uri);
        request.fields['upload_preset'] = uploadPreset;
        if (folder.isNotEmpty) request.fields['folder'] = folder;
        request.files.add(http.MultipartFile.fromBytes('file', file, filename: name));
        final streamed = await request.send();
        final resp = await http.Response.fromStream(streamed);
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          final decoded = json.decode(resp.body) as Map<String, dynamic>;
          return decoded['secure_url'] as String;
        } else {
          throw Exception('Cloudinary upload failed: ${resp.statusCode} ${resp.body}');
        }
      }

      // For file paths (mobile/desktop), delegate to cloudinary_public client
      if (file is String) {
        final res = await _client.uploadFile(CloudinaryFile.fromFile(file, folder: folder));
        return res.secureUrl;
      }

      // For XFile or File objects with a path, try to extract path
      try {
        final path = file.path as String;
        final res = await _client.uploadFile(CloudinaryFile.fromFile(path, folder: folder));
        return res.secureUrl;
      } catch (e) {
        throw Exception('Unsupported file type for Cloudinary upload: ${file.runtimeType}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
