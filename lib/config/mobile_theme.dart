import 'package:flutter/material.dart';
import 'theme.dart';

/// Mobile-Specific Theme Configuration
///
/// Contains design tokens optimized for mobile interfaces
/// with touch-friendly sizing, compact layouts, and gesture support.
class MobileTheme {
  // Layout Constraints
  static const double bottomNavHeight = 72.0;
  static const double appBarHeight = 56.0;
  static const double fabSize = 56.0;

  // Spacing
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 16.0,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: 20.0);
  static const double itemSpacing = 16.0;
  static const double compactSpacing = 12.0;

  // Touch Targets (minimum 48x48 for accessibility)
  static const double minTouchTarget = 48.0;
  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;

  // Border Radius
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(12.0),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(10.0),
  );
  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(8.0),
  );
  static const BorderRadius chipRadius = BorderRadius.all(
    Radius.circular(20.0),
  );

  // Shadows (lighter for mobile)
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> bottomNavShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];

  static List<BoxShadow> fabShadow = [
    BoxShadow(
      color: AppTheme.primaryColor.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // Typography Scale for Mobile (slightly smaller)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppTheme.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 26.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
    color: AppTheme.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppTheme.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppTheme.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppTheme.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppTheme.textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppTheme.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppTheme.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    color: AppTheme.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppTheme.textPrimary,
  );

  // Decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppTheme.surfaceColor,
    borderRadius: cardRadius,
    boxShadow: cardShadow,
  );

  static BoxDecoration bottomNavDecoration = BoxDecoration(
    color: AppTheme.surfaceColor,
    boxShadow: bottomNavShadow,
  );

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppTheme.primaryColor, AppTheme.primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppTheme.secondaryColor, AppTheme.secondaryLight],
  );

  // Input Decoration for Mobile
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
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: bodyMedium,
      hintStyle: bodyMedium.copyWith(color: const Color(0xFFCBD5E1)),
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, buttonHeight),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
    elevation: 0,
    textStyle: labelLarge.copyWith(color: Colors.white),
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppTheme.primaryColor,
    minimumSize: const Size(double.infinity, buttonHeight),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
    side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
    textStyle: labelLarge,
  );

  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppTheme.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
    textStyle: labelLarge.copyWith(color: AppTheme.primaryColor),
  );

  // List Tile Decoration
  static BoxDecoration listTileDecoration = BoxDecoration(
    color: AppTheme.surfaceColor,
    borderRadius: cardRadius,
  );

  // Chip Decoration
  static BoxDecoration chipDecoration({bool isSelected = false}) {
    return BoxDecoration(
      color: isSelected
          ? AppTheme.primaryColor.withOpacity(0.1)
          : const Color(0xFFF1F5F9),
      borderRadius: chipRadius,
      border: isSelected
          ? Border.all(color: AppTheme.primaryColor, width: 1.5)
          : null,
    );
  }
}
