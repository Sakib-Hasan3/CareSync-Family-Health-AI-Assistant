import 'env.dart';

/// Runtime application configuration
class AppConfig {
  AppConfig._();

  // App Information
  static const String appName = 'CareSync';
  static const String appDescription = 'Family Health Management Application';
  static String get appVersion => Environment.appVersion;
  static String get buildNumber => Environment.appBuildNumber;

  // API Configuration
  static String get baseApiUrl => Environment.apiBaseUrl;
  static Duration get apiTimeout =>
      Duration(seconds: Environment.apiTimeoutDuration);
  static Duration get syncTimeout =>
      Duration(seconds: Environment.syncTimeoutDuration);

  // Database Configuration
  static String get databaseName => Environment.localDatabaseName;
  static int get databaseVersion => Environment.localDatabaseVersion;

  // Feature Configuration
  static bool get isAiAssistantEnabled => Environment.enableAiAssistant;
  static bool get isOcrEnabled => Environment.enableOcrFeature;
  static bool get isOfflineModeEnabled => Environment.enableOfflineMode;
  static bool get isAnalyticsEnabled => Environment.enableAnalytics;
  static bool get isCrashReportingEnabled => Environment.enableCrashReporting;

  // UI Configuration
  static const int maxFamilyMembers = 10;
  static const int maxDocumentsPerUser = 100;
  static const int maxMedicationsPerUser = 50;
  static const int maxVitalRecordsPerDay = 10;

  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentFormats = [
    'pdf',
    'doc',
    'docx',
    'txt',
  ];

  // Notification Configuration
  static const String defaultNotificationChannelId = 'caresync_default';
  static const String medicationReminderChannelId = 'medication_reminders';
  static const String appointmentReminderChannelId = 'appointment_reminders';
  static const String emergencyChannelId = 'emergency_alerts';

  // Security Configuration
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;

  // Sync Configuration
  static const int syncIntervalMinutes = 15;
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 5;

  // Maps Configuration
  static String get googleMapsApiKey => Environment.googleMapsApiKey;
  static const double defaultMapZoom = 15.0;
  static const double nearbyServicesRadius = 5000; // 5km in meters

  // Emergency Configuration
  static const String defaultEmergencyNumber = '911';
  static const List<String> emergencyServices = [
    'Police',
    'Fire Department',
    'Ambulance',
    'Poison Control',
  ];

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minAgeYears = 0;
  static const int maxAgeYears = 150;

  // Cache Configuration
  static const int imageCacheDurationDays = 7;
  static const int dataCacheDurationHours = 24;
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Debug Configuration
  static bool get isDebugMode => Environment.isDevelopment;
  static bool get enableLogging =>
      Environment.isDevelopment || Environment.isStaging;

  // Theme Configuration
  static const String defaultTheme = 'light';
  static const String defaultLanguage = 'en';

  // Biometric Authentication
  static const bool enableBiometricAuth = true;
  static const String biometricReason =
      'Please authenticate to access your health data';

  /// Get configuration summary for debugging
  static Map<String, dynamic> getConfigSummary() {
    return {
      'environment': Environment.current,
      'apiUrl': baseApiUrl,
      'version': '$appVersion+$buildNumber',
      'features': {
        'aiAssistant': isAiAssistantEnabled,
        'ocr': isOcrEnabled,
        'offline': isOfflineModeEnabled,
        'analytics': isAnalyticsEnabled,
        'crashReporting': isCrashReportingEnabled,
      },
      'limits': {
        'maxFamilyMembers': maxFamilyMembers,
        'maxFileSize': maxFileSize,
        'sessionTimeout': sessionTimeoutMinutes,
      },
    };
  }
}
