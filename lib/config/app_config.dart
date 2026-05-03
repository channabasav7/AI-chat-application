class AppConfig {
  // API Keys
  static String get openaiApiKey => const String.fromEnvironment(
        'OPENAI_API_KEY',
        defaultValue: 'your_openai_api_key_here',
      );

  static String get googleApiKey => const String.fromEnvironment(
        'GOOGLE_API_KEY',
        defaultValue: 'your_google_api_key_here',
      );

  // Firebase Configuration
  static String get firebaseApiKey => const String.fromEnvironment(
        'FIREBASE_API_KEY',
        defaultValue: '',
      );

  static String get firebaseProjectId => const String.fromEnvironment(
        'FIREBASE_PROJECT_ID',
        defaultValue: '',
      );

  // Environment
  static String get environment => const String.fromEnvironment(
        'ENVIRONMENT',
        defaultValue: 'development',
      );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}
