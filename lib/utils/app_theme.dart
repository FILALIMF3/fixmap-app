import 'package:flutter/material.dart';

class AppTheme {
  // ----------------------------------
  // A. The App's Color Palette
  // ----------------------------------
  static const Color primaryColor = Color(0xFFc1272d); // Moroccan Red
  static const Color secondaryColor = Color(0xFF006233); // Moroccan Green
  static const Color neutral_background = Color(0xFFf5f5f5); // Background
  static const Color neutral_text = Color(0xFF333333); // Text
  static const Color neutral_white = Color(0xFFffffff); // Cards
  static const Color accentColor = Color(0xFF007aff); // Bright Blue for accents

  // ----------------------------------
  // B. The App's Theme Data
  // ----------------------------------
  static final ThemeData lightTheme = ThemeData(
    // 1. Core Colors
    primaryColor: primaryColor,
    scaffoldBackgroundColor: neutral_background,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: neutral_white,
      background: neutral_background,
      error: primaryColor, // Use primary red for errors
      onPrimary: neutral_white,
      onSecondary: neutral_white,
      onSurface: neutral_text,
      onBackground: neutral_text,
      onError: neutral_white,
    ),

    // 2. Typography
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: neutral_text),
      displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: neutral_text),
      headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, color: neutral_text),
      headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: neutral_text),
      titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: neutral_text),
      bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: neutral_text),
      bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: neutral_text),
      labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: neutral_white),
    ),

    // 3. Component Themes
    appBarTheme: const AppBarTheme(
      backgroundColor: neutral_background,
      elevation: 0,
      iconTheme: IconThemeData(color: neutral_text),
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: neutral_text, fontFamily: 'Inter'),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: neutral_white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        minimumSize: const Size(double.infinity, 54),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: neutral_white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(
        color: neutral_text,
        fontWeight: FontWeight.normal,
      ),
    ),

    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    iconTheme: const IconThemeData(
      color: neutral_text,
      size: 24.0,
    ),
  );
}
