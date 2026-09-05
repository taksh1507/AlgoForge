import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const parchment = Color(0xFFF6F3F1);
  static const lakeBlue = Color(0xFF2B59D1);
  static const periwinkleMist = Color(0xFFCFDAF5);
  static const offBlack = Color(0xFF242424);
  static const graphite = Color(0xFF4E4D4D);
  static const smoke = Color(0xFF797776);
  static const ash = Color(0xFFCECAC8);
  static const mint = Color(0xFFA7FCCD);
  static const coral = Color(0xFFFF9473);
  static const gold = Color(0xFFECDA98);

  // Dark mode equivalents
  static const darkBg = Color(0xFF161514);
  static const darkCard = Color(0xFF24211F);
  static const darkLine = Color(0xFF3A3735);
  static const darkInk = Color(0xFFEDE9E5);
  static const darkMuted = Color(0xFFA9A4A0);
  static const darkFaint = Color(0xFF8A8580);
  static const darkAccentSoft = Color(0xFF1F2F5C);
}

/// Theme-aware color palette. Screens should read `context.palette`
/// instead of hardcoding `AppColors` so dark mode works everywhere.
class AppPalette {
  final Color bg;
  final Color card;
  final Color field;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color line;
  final Color accent;
  final Color accentSoft;
  final Color success;
  final Color warn;
  final Color danger;

  const AppPalette({
    required this.bg,
    required this.card,
    required this.field,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.line,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.warn,
    required this.danger,
  });

  static const light = AppPalette(
    bg: AppColors.parchment,
    card: AppColors.parchment,
    field: AppColors.parchment,
    ink: AppColors.offBlack,
    muted: AppColors.graphite,
    faint: AppColors.smoke,
    line: AppColors.ash,
    accent: AppColors.lakeBlue,
    accentSoft: AppColors.periwinkleMist,
    success: AppColors.mint,
    warn: AppColors.gold,
    danger: AppColors.coral,
  );

  static const dark = AppPalette(
    bg: AppColors.darkBg,
    card: AppColors.darkCard,
    field: AppColors.darkCard,
    ink: AppColors.darkInk,
    muted: AppColors.darkMuted,
    faint: AppColors.darkFaint,
    line: AppColors.darkLine,
    accent: AppColors.lakeBlue,
    accentSoft: AppColors.darkAccentSoft,
    success: AppColors.mint,
    warn: AppColors.gold,
    danger: AppColors.coral,
  );
}

extension AppPaletteX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).brightness == Brightness.dark
          ? AppPalette.dark
          : AppPalette.light;
}

class AppRadii {
  AppRadii._();

  static const card = 24.0;
  static const button = 100.0;
  static const tag = 9999.0;
  static const input = 100.0;
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppFontSizes {
  AppFontSizes._();

  static const xs = 10.0;
  static const sm = 12.0;
  static const md = 14.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const hero = 32.0;
  static const display = 48.0;
}
