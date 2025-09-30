/// Environment configuration for the CareSync app
class Environment {
  Environment._();

  // Environment types
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';

  // Current environment (change this based on build configuration)
  static const String current = development;

  // API Base URLs
  static const String _devApiUrl = 'https://api-dev.caresync.com';
  static const String _stagingApiUrl = 'https://api-staging.caresync.com';
  static const String _prodApiUrl = 'https://api.caresync.com';

  static String get apiBaseUrl {
    switch (current) {
      case staging:
        return _stagingApiUrl;
      case production:
        return _prodApiUrl;
      default:
        return _devApiUrl;
    }
  }

  // API Keys (store these securely in production)
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
  static const String mlKitApiKey = 'YOUR_ML_KIT_API_KEY';

  // Firebase Configuration
  static const String firebaseProjectId = 'caresync-health-app';
  static const String firebaseAppId = 'YOUR_FIREBASE_APP_ID';
  static const String firebaseMessagingSenderId = 'YOUR_SENDER_ID';

  // Database Configuration
  static const String localDatabaseName = 'caresync_local.db';
  static const int localDatabaseVersion = 1;

  // App Configuration
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Feature Flags
  static const bool enableAiAssistant = true;
  static const bool enableOcrFeature = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = current != development;
  static const bool enableCrashReporting = current == production;

  // Timeouts (in seconds)
  static const int apiTimeoutDuration = 30;
  static const int syncTimeoutDuration = 60;

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userProfileKey = 'user_profile';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  // Validation
  static bool get isProduction => current == production;
  static bool get isDevelopment => current == development;
  static bool get isStaging => current == staging;
}
