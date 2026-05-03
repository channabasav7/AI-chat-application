import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads environment variables from .env file
class EnvLoader {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('Environment variables loaded successfully');
    } catch (e) {
      debugPrint('Warning: Could not load .env file: $e');
      // This is okay in production where .env might not exist
    }
  }

  static String? getApiKey(String key) {
    return dotenv.env[key];
  }

  static String getApiKeyOrThrow(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('API Key "$key" not found in environment variables');
    }
    return value;
  }

  static bool isKeySet(String key) {
    final value = dotenv.env[key];
    return value != null && value.isNotEmpty && value != 'your_${key.toLowerCase()}_here';
  }
}
