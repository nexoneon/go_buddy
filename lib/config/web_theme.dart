import 'package:flutter/material.dart';
import 'theme.dart';

/// Web-Specific Theme Configuration
///
/// Contains design tokens optimized for web/desktop interfaces
/// with wider layouts, mouse interactions, and admin panel styling.
class WebTheme {
  // Layout Constraints
  static const double maxContentWidth = 1200.0;
  static const double sidebarWidth = 280.0;
  static const double topNavHeight = 64.0;
  static const double minScreenWidth = 800.0;

  // Spacing
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 48.0,
    vertical: 24.0,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(24.0);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: 32.0);
  static const double itemSpacing = 24.0;

  // Border Radius
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(16.0),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(12.0),
  );
  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(10.0),
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Typography Scale for Web
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
    color: AppTheme.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 36.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
    color: AppTheme.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
    color: AppTheme.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppTheme.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppTheme.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppTheme.textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppTheme.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppTheme.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppTheme.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppTheme.textSecondary,
  );

  // Admin Panel Colors
  static const Color sidebarBackground = Color(0xFF1E293B);
  static const Color sidebarItemHover = Color(0xFF334155);
  static const Color sidebarItemActive = Color(0xFF3B82F6);
  static const Color sidebarText = Color(0xFFE2E8F0);
  static const Color sidebarTextMuted = Color(0xFF94A3B8);

  // Decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppTheme.surfaceColor,
    borderRadius: cardRadius,
    boxShadow: cardShadow,
  );

  static BoxDecoration sidebarDecoration = const BoxDecoration(
    color: sidebarBackground,
    boxShadow: [
      BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(4, 0)),
    ],
  );

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
  );

  // Input Decoration for Web
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: bodyMedium,
      hintStyle: bodyMedium.copyWith(color: const Color(0xFFCBD5E1)),
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
    elevation: 0,
    textStyle: labelLarge.copyWith(color: Colors.white),
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppTheme.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
    side: const BorderSide(color: AppTheme.primaryColor, width: 2),
    textStyle: labelLarge,
  );

  static ButtonStyle ghostButtonStyle = TextButton.styleFrom(
    foregroundColor: AppTheme.textSecondary,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
    textStyle: bodyMedium,
  );
}
