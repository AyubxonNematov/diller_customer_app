import 'package:flutter/material.dart';

class AppColors {
  static const darkNavy = Color(0xFF1E2D3D);
  static const gold = Color(0xFFF5BF1A);
  static const goldLight = Color(0xFFFFF3CC);
  static const grayText = Color(0xFF8E8E93);
  static const graySubtle = Color(0xFFC7C7CC);
  static const background = Color(0xFFF8F8F8);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkNavy,
        brightness: Brightness.light,
        primary: AppColors.darkNavy,
        secondary: AppColors.gold,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkNavy,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          side: const BorderSide(color: AppColors.graySubtle),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
