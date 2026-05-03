import '../services/env_loader.dart';

class AppConfig {
  // API Keys
  static String get openaiApiKey => EnvLoader.getApiKey(
        'OPENAI_API_KEY',
      ) ??
      'your_openai_api_key_here';

  static String get googleApiKey => EnvLoader.getApiKey(
        'GOOGLE_API_KEY',
      ) ??
      'your_google_api_key_here';

  // Firebase Configuration
  static String get firebaseApiKey => EnvLoader.getApiKey('FIREBASE_API_KEY') ?? '';

  static String get firebaseAuthDomain => EnvLoader.getApiKey('FIREBASE_AUTH_DOMAIN') ?? '';

  static String get firebaseProjectId => EnvLoader.getApiKey('FIREBASE_PROJECT_ID') ?? '';

  static String get firebaseStorageBucket => EnvLoader.getApiKey('FIREBASE_STORAGE_BUCKET') ?? '';

  static String get firebaseMessagingSenderId =>
      EnvLoader.getApiKey('FIREBASE_MESSAGING_SENDER_ID') ?? '';

  static String get firebaseAppId => EnvLoader.getApiKey('FIREBASE_APP_ID') ?? '';

  static String get firebaseMeasurementId =>
      EnvLoader.getApiKey('FIREBASE_MEASUREMENT_ID') ?? '';

  // Environment
  static String get environment => EnvLoader.getApiKey('ENVIRONMENT') ?? 'development';

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}
