import 'package:flutter/foundation.dart' show kIsWeb;

/// Responsive helper utility class
///
/// Provides helper methods to determine platform and screen size
class ResponsiveHelper {
  /// Check if the app is running on web
  static bool get isWeb => kIsWeb;

  /// Check if the app is running on mobile (not web)
  static bool get isMobile => !kIsWeb;

  /// Check if screen width is considered mobile size
  static bool isMobileSize(double width) => width < 768;

  /// Check if screen width is considered tablet size
  static bool isTabletSize(double width) => width >= 768 && width < 1024;

  /// Check if screen width is considered desktop size
  static bool isDesktopSize(double width) => width >= 1024;
}
