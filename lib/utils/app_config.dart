// lib/config/app_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get cloudinaryApiKey {
    return dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  }

  static String get cloudinaryApiSecret {
    return dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  }

  static String get cloudinaryCloudName {
    return dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  }


}
