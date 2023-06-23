import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4A3780);
  static const Color scaffoldBackground = Color(0xFFF1F5F9);

  static ThemeData lightTheme = ThemeData(
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
    ),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackground,
    textTheme: const TextTheme(
      displayMedium: TextStyle(
        fontFamily: 'Inter',
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
  );
}
