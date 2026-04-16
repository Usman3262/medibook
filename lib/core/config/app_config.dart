/// Environment configuration and constants
class AppConfig {
  AppConfig._();

  // Firebase Configuration
  static const String firebaseProjectId = 'YOUR_PROJECT_ID';
  static const String firebaseAppId = 'YOUR_APP_ID';
  static const String firebaseMessagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
  static const String firebaseApiKey = 'YOUR_API_KEY';

  // Cloudflare R2 Configuration
  static const String r2AccountId = 'YOUR_ACCOUNT_ID';
  static const String r2AccessKeyId = 'YOUR_ACCESS_KEY_ID';
  static const String r2SecretAccessKey = 'YOUR_SECRET_ACCESS_KEY';
  static const String r2BucketName = 'medibook';

  // API Configuration
  static const String apiBaseUrl = 'https://api.medibook.com';

  // App Configuration
  static const String appName = 'MediBook';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int pageSize = 20;

  // Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds
}
