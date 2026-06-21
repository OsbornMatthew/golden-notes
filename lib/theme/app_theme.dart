import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0F0E0C);
  static const Color surface = Color(0xFF1A1814);
  static const Color surfaceLight = Color(0xFF242019);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldBright = Color(0xFFF1C84A);
  static const Color goldMuted = Color(0xFF8A7430);
  static const Color textPrimary = Color(0xFFF5EFE0);
  static const Color textSecondary = Color(0xFFA89F8C);
  static const Color divider = Color(0xFF2E2A22);
  static const Color danger = Color(0xFFCF6679);
}

class AppTheme {
  static ThemeData get darkGold {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.gold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.goldBright,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.gold,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.black,
      ),
      iconTheme: const IconThemeData(color: AppColors.gold),
      dividerColor: AppColors.divider,
      cardColor: AppColors.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}
