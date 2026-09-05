import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: AppPalette.light.bg,
        card: AppPalette.light.card,
        field: AppPalette.light.field,
        ink: AppPalette.light.ink,
        muted: AppPalette.light.muted,
        faint: AppPalette.light.faint,
        line: AppPalette.light.line,
        accent: AppPalette.light.accent,
        accentSoft: AppPalette.light.accentSoft,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: AppPalette.dark.bg,
        card: AppPalette.dark.card,
        field: AppPalette.dark.field,
        ink: AppPalette.dark.ink,
        muted: AppPalette.dark.muted,
        faint: AppPalette.dark.faint,
        line: AppPalette.dark.line,
        accent: AppPalette.dark.accent,
        accentSoft: AppPalette.dark.accentSoft,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color field,
    required Color ink,
    required Color muted,
    required Color faint,
    required Color line,
    required Color accent,
    required Color accentSoft,
  }) {
    final head = (double size) => GoogleFonts.playfairDisplay(
          fontSize: size,
          fontWeight: FontWeight.w400,
          color: ink,
        );
    final body = (double size, {FontWeight? w, Color? color}) =>
        GoogleFonts.spaceMono(
          fontSize: size,
          fontWeight: w ?? FontWeight.w400,
          color: color ?? muted,
        );

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: ink,
        secondary: accent,
        onSecondary: ink,
        error: AppColors.coral,
        onError: ink,
        surface: card,
        onSurface: ink,
        outline: line,
        surfaceContainerHighest: accentSoft,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: ink),
      ),
      textTheme: TextTheme(
        displayLarge: head(48),
        displayMedium: head(32),
        headlineMedium: head(24),
        headlineSmall: head(20),
        titleLarge: head(18),
        bodyLarge: body(16),
        bodyMedium: body(14),
        bodySmall: body(12, color: faint),
        labelLarge: body(14, w: FontWeight.w500, color: ink),
        labelMedium: body(12, w: FontWeight.w500, color: faint),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: line, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: line, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: faint),
        labelStyle: TextStyle(color: faint),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: accent,
        unselectedItemColor: faint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: bg),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStatePropertyAll(accentSoft),
        thumbColor: WidgetStatePropertyAll(accent),
      ),
    );
  }
}