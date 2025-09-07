// lib/services/cloudinary_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:enforcer_auto_fine/utils/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static Future<String> uploadPhoto(File file) async {
    // 1. Validate configuration
    if (AppConfig.cloudinaryApiKey.isEmpty ||
        AppConfig.cloudinaryCloudName.isEmpty) {
      throw Exception('Cloudinary cloud name or API key not configured.');
    }

    // 2. Prepare the request
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = AppConfig.cloudinaryCloudName
      ..fields['api_key'] = AppConfig.cloudinaryApiKey
      ..files.add(
        await http.MultipartFile.fromPath(
          'file', // The field name for the file is always 'file'
          file.path,
        ),
      );

    // 3. Send the request
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 4. Handle the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final imageUrl = responseData['secure_url'] as String;
        return imageUrl;
      } else {
        throw Exception('Failed to upload photo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  /// Deletes a photo using environment variables
  static Future<bool> deletePhoto(String imageUrl) async {
    // Validate configuration
    if (AppConfig.cloudinaryApiKey.isEmpty ||
        AppConfig.cloudinaryApiSecret.isEmpty) {
      print('Error:` Cloudinary credentials` not configured properly');
      return false;
    }

    return await _deletePhotoWithCredentials(
      imageUrl,
      AppConfig.cloudinaryApiKey,
      AppConfig.cloudinaryApiSecret,
    );
  }

  /// Internal method that handles the actual deletion
  static Future<bool> _deletePhotoWithCredentials(
    String imageUrl,
    String apiKey,
    String apiSecret,
  ) async {
    try {
      // Validate that this is actually a Cloudinary URL from your cloud
      if (!_isValidCloudinaryUrl(imageUrl)) {
        print('Invalid Cloudinary URL: $imageUrl');
        return false;
      }

      // Extract public ID from the Cloudinary URL
      String publicId = _extractPublicIdFromUrl(imageUrl);

      if (publicId.isEmpty) {
        print('Could not extract public ID from URL: $imageUrl');
        return false;
      }

      print('Attempting to delete: $publicId');

      // Generate timestamp
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create signature
      String signature = _generateSignature(publicId, timestamp, apiSecret);

      // Prepare the request
      String url =
          'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/image/destroy';

      Map<String, String> body = {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
        'api_key': apiKey,
        'signature': signature,
      };

      // Make the HTTP request
      http.Response response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        print('Delete response: $responseData');

        // Check if the deletion was successful
        bool success = responseData['result'] == 'ok';

        if (!success && responseData['result'] == 'not found') {
          print('Image was already deleted or never existed');
          // You might want to return true here if you consider this successful
        }

        return success;
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during deletion: $e');
      return false;
    }
  }

  /// Delete multiple photos with rate limiting
  static Future<Map<String, bool>> deleteMultiplePhotos(
    List<String> imageUrls,
  ) async {
    Map<String, bool> results = {};

    for (String url in imageUrls) {
      bool success = await deletePhoto(url);
      results[url] = success;

      // Rate limiting to avoid API limits
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return results;
  }

  /// Generates the signature required for Cloudinary API authentication
  static String _generateSignature(
    String publicId,
    int timestamp,
    String apiSecret,
  ) {
    // Create the string to sign
    String stringToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

    // Generate SHA1 hash
    var bytes = utf8.encode(stringToSign);
    var digest = sha1.convert(bytes);

    return digest.toString();
  }

  /// Validates if the URL is from your Cloudinary cloud
  static bool _isValidCloudinaryUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      return uri.host == 'res.cloudinary.com' &&
          uri.pathSegments.contains(AppConfig.cloudinaryCloudName);
    } catch (e) {
      return false;
    }
  }

  /// Extracts the public ID from a Cloudinary URL
  static String _extractPublicIdFromUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      List<String> pathSegments = uri.pathSegments;

      int uploadIndex = pathSegments.indexOf('upload');

      if (uploadIndex == -1 || uploadIndex >= pathSegments.length - 1) {
        return '';
      }

      List<String> relevantSegments = pathSegments.sublist(uploadIndex + 1);

      // Remove version parameter if it exists
      if (relevantSegments.isNotEmpty &&
          RegExp(r'^v\d+$').hasMatch(relevantSegments.first)) {
        relevantSegments = relevantSegments.sublist(1);
      }

      if (relevantSegments.isEmpty) {
        return '';
      }

      String publicId = relevantSegments.join('/');

      // Remove file extension
      int lastDotIndex = publicId.lastIndexOf('.');
      if (lastDotIndex != -1) {
        publicId = publicId.substring(0, lastDotIndex);
      }

      return publicId;
    } catch (e) {
      print('Error extracting public ID from URL: $e');
      return '';
    }
  }
}

// Usage example:
// bool success = await CloudinaryService.deletePhoto(imageUrl);
