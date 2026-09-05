import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized text styles using Google Fonts.
/// Use these instead of hardcoded fontFamily strings.
///
/// Colors default to [null] intentionally so text inherits the active theme's
/// color (light headings are near-black; in dark mode they become near-white).
class AppTextStyles {
  AppTextStyles._();

  // Headings — Playfair Display (serif, weight 400, never bold)
  static TextStyle heading1({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle heading2({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle heading3({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle heading4({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // Body — Space Mono (mono)
  static TextStyle body({Color? color, double? fontSize}) => GoogleFonts.spaceMono(
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // Labels — Space Mono (mono, weight 500)
  static TextStyle label({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle labelTiny({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // Stats
  static TextStyle statNumber({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle statLabel({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 1.2,
      );
}