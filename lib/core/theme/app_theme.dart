import 'package:flutter/material.dart';

/// Centralized theme and color system for the app
/// Change colors here to update the entire app
class AppTheme {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF3b82f6);
  static const Color primaryGreen = Color(0xFF4ade80);
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color backgroundCard = Color(0xFF1A1F2E);
  static const Color backgroundSecondary = Color(0xFF1e293b);
  static const Color backgroundTertiary = Color(0xFF334155);
  
  // Gradient Colors
  static const List<Color> backgroundGradient = [
    Color(0xFF0f172a),
    Color(0xFF1e293b),
    Color(0xFF334155),
  ];
  
  static const List<Color> authGradient = [
    Color(0xFF1e3c72),
    Color(0xFF2a5298),
    Color(0xFF7e22ce),
  ];
  
  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static Color textTertiary = Colors.grey[600]!;
  static Color textQuaternary = Colors.grey[500]!;
  
  // Accent Colors
  static const Color errorRed = Colors.red;
  static Color navbarBackground = const Color(0xb51a2332);
  
  // Opacity variants
  static Color primaryBlueWithOpacity(double opacity) => primaryBlue.withOpacity(opacity);
  static Color primaryGreenWithOpacity(double opacity) => primaryGreen.withOpacity(opacity);
  static Color backgroundCardWithOpacity(double opacity) => backgroundCard.withOpacity(opacity);
  
  /// Get the app theme data
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(color: textPrimary),
        displayMedium: const TextStyle(color: textPrimary),
        displaySmall: const TextStyle(color: textPrimary),
        headlineLarge: const TextStyle(color: textPrimary),
        headlineMedium: const TextStyle(color: textPrimary),
        headlineSmall: const TextStyle(color: textPrimary),
        titleLarge: const TextStyle(color: textPrimary),
        titleMedium: const TextStyle(color: textPrimary),
        titleSmall: const TextStyle(color: textPrimary),
        bodyLarge: const TextStyle(color: textPrimary),
        bodyMedium: const TextStyle(color: textPrimary),
        bodySmall: const TextStyle(color: textSecondary),
        labelLarge: const TextStyle(color: textPrimary),
        labelMedium: const TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textTertiary),
      ),
    );
  }
  
  /// Get background gradient
  static BoxDecoration get backgroundGradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: backgroundGradient,
    ),
  );
  
  /// Get auth gradient decoration
  static BoxDecoration get authGradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: authGradient,
    ),
  );
}
