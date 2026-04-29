import 'package:flutter/material.dart';

class AppTheme {
  static const deepBlack = Color(0xFF0A0A0F);
  static const darkGrey = Color(0xFF1A1A2E);
  static const neonCyan = Color(0xFF00F5FF);
  static const neonPurple = Color(0xFF9D00FF);
  static const neonBlue = Color(0xFF0066FF);
  static const grey = Color(0xFF8A8A9E);

  static final darkNeonTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: deepBlack,
    primaryColor: neonCyan,
    colorScheme: const ColorScheme.dark(
      primary: neonCyan,
      secondary: neonPurple,
      surface: darkGrey,
      background: deepBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: deepBlack,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: neonCyan,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonCyan,
        foregroundColor: deepBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: neonCyan, fontWeight: FontWeight.bold),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: neonCyan,
    ),
  );
}