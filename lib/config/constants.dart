/// App Constants
///
/// Contains constant values used throughout the application
class AppConstants {
  // App Info
  static const String appName = '7 Pay Services';
  static const String appVersion = '1.0.0';

  // API Endpoints (configure as needed)
  static const String baseUrl = 'https://api.example.com';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}
