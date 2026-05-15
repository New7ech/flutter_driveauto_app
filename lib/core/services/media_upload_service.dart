import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MediaUploadException implements Exception {
  const MediaUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MediaUploadService {
  const MediaUploadService();

  static const int maxImageBytes = 8 * 1024 * 1024;

  Future<String> uploadSlideImage({
    required XFile file,
    required String serieId,
    required String diapoId,
  }) async {
    final cloudName = dotenv.maybeGet('CLOUDINARY_CLOUD_NAME')?.trim();
    final uploadPreset = dotenv.maybeGet('CLOUDINARY_UPLOAD_PRESET')?.trim();
    final folder = dotenv.maybeGet('CLOUDINARY_SLIDES_FOLDER')?.trim();

    if (cloudName == null ||
        cloudName.isEmpty ||
        uploadPreset == null ||
        uploadPreset.isEmpty) {
      throw const MediaUploadException(
        "Cloudinary n'est pas configuré. Ajoutez CLOUDINARY_CLOUD_NAME et CLOUDINARY_UPLOAD_PRESET dans le fichier .env.",
      );
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const MediaUploadException("L'image choisie est vide.");
    }
    if (bytes.length > maxImageBytes) {
      throw MediaUploadException(
        "L'image fait ${(bytes.length / 1024 / 1024).toStringAsFixed(1)} Mo. La limite actuelle est de 8 Mo.",
      );
    }

    final uri = Uri.https(
      'api.cloudinary.com',
      '/v1_1/$cloudName/image/upload',
    );
    final safeSerieId = _safePublicIdPart(serieId);
    final safeDiapoId = _safePublicIdPart(diapoId);
    final uniquePublicId =
        '${safeDiapoId}_${DateTime.now().millisecondsSinceEpoch}';
    final targetFolder = (folder == null || folder.isEmpty)
        ? 'driveauto/slides'
        : folder;

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = '$targetFolder/$safeSerieId'
      ..fields['public_id'] = uniquePublicId
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name.isEmpty ? '$uniquePublicId.jpg' : file.name,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MediaUploadException(_formatCloudinaryError(response));
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const MediaUploadException(
        "Cloudinary a retourné une réponse invalide.",
      );
    }

    final secureUrl = body['secure_url'];
    if (secureUrl is! String || secureUrl.trim().isEmpty) {
      throw const MediaUploadException(
        "Cloudinary n'a pas retourné d'URL publique pour l'image.",
      );
    }

    return secureUrl;
  }

  static String _safePublicIdPart(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return sanitized.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : sanitized;
  }

  static String _formatCloudinaryError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      final error = body is Map<String, dynamic> ? body['error'] : null;
      final message = error is Map<String, dynamic> ? error['message'] : null;
      if (message is String && message.trim().isNotEmpty) {
        return 'Upload Cloudinary refusé : ${message.trim()}';
      }
    } catch (_) {
      // Keep the generic error below.
    }
    return 'Upload Cloudinary refusé (${response.statusCode}).';
  }
}
