import 'package:flutter/material.dart';

/// Application color palette with dark mode and vibrant accents
class AppColors {
  // Primary Background
  static const Color primaryBackground = Color(0xFF121212); // Charcoal
  static const Color deepNavy = Color(0xFF0D1B2A); // Deep Navy

  // Secondary Background
  static const Color secondaryBackground = Color(0xFF1E1E1E); // Dark Gray

  // Text Colors
  static const Color bodyText = Color(0xFFE0E0E0); // Light Gray
  static const Color headerText = Color(0xFFFFFFFF); // Pure White
  static const Color mutedText = Color(0xFF9E9E9E); // Muted Gray

  // Status Colors
  static const Color available = Color(0xFF00FFFF); // Bright Cyan
  static const Color occupied = Color(0xFFDC143C); // Crimson
  static const Color pending = Color(0xFFFFBF00); // Amber
  static const Color maintenance = Color(0xFFFF6B00); // Orange

  // Interactive Elements
  static const Color buttonPrimary = Color(0xFF3B82F6); // Electric Blue
  static const Color hover = Color(0xFF39FF14); // Neon Green
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFFBBF24); // Amber

  // Borders and Dividers
  static const Color dividerColor = Color(0xFF2D2D2D); // Better Dark Gray
  static const Color borderColor = Color(0xFF404040); // Medium Dark Gray

  // Shadow and Overlay
  static const Color shadowColor = Color(0x1A000000); // 10% black
}

/// Theme configuration for the app
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.buttonPrimary,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      cardColor: AppColors.secondaryBackground,
      dividerColor: AppColors.dividerColor,
      colorScheme: ColorScheme.dark(
        primary: AppColors.buttonPrimary,
        secondary: AppColors.hover,
        tertiary: AppColors.available,
        error: AppColors.error,
        errorContainer: AppColors.error.withOpacity(0.2),
        surface: AppColors.secondaryBackground,
        surfaceContainer: AppColors.dividerColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.secondaryBackground,
        foregroundColor: AppColors.headerText,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.headerText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: AppColors.headerText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.headerText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: AppColors.headerText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.headerText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.headerText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.bodyText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.bodyText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: AppColors.mutedText,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.headerText,
          elevation: 4,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.buttonPrimary,
          side: BorderSide(color: AppColors.buttonPrimary, width: 2),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.hover,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.secondaryBackground,
        filled: true,
        hintStyle: TextStyle(color: AppColors.mutedText),
        labelStyle: TextStyle(color: AppColors.bodyText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.buttonPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      cardTheme: CardThemeData(
        color: AppColors.secondaryBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondaryBackground,
        selectedColor: AppColors.buttonPrimary,
        labelStyle: TextStyle(color: AppColors.bodyText),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.hover,
        unselectedLabelColor: AppColors.mutedText,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.hover, width: 3),
        ),
      ),
    );
  }
}

/// Extension for easy access to colors throughout the app
extension ColorExtensions on Color {
  Color withAlpha(int alpha) {
    return withAlpha(alpha);
  }

  Color lighten({double amount = 0.1}) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightened = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }

  Color darken({double amount = 0.1}) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}
