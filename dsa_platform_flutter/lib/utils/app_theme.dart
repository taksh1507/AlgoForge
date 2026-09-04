import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.parchment,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lakeBlue,
        onPrimary: Colors.white,
        surface: AppColors.parchment,
        onSurface: AppColors.offBlack,
        outline: AppColors.ash,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.parchment,
        foregroundColor: AppColors.offBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: AppColors.offBlack,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: AppColors.offBlack,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.offBlack,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.offBlack,
        ),
        bodyLarge: GoogleFonts.spaceMono(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.graphite,
        ),
        bodyMedium: GoogleFonts.spaceMono(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.graphite,
        ),
        bodySmall: GoogleFonts.spaceMono(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.smoke,
        ),
        labelLarge: GoogleFonts.spaceMono(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.offBlack,
        ),
        labelMedium: GoogleFonts.spaceMono(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.smoke,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.parchment,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: AppColors.ash, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.parchment,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.ash, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.ash, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.lakeBlue, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.parchment,
        selectedItemColor: AppColors.lakeBlue,
        unselectedItemColor: AppColors.smoke,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
