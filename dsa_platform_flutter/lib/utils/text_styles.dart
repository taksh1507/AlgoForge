import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

/// Centralized text styles using Google Fonts.
/// Use these instead of hardcoded fontFamily strings.
class AppTextStyles {
  AppTextStyles._();

  // Headings — Playfair Display (serif, weight 400, never bold)
  static TextStyle heading1({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.offBlack,
      );

  static TextStyle heading2({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.offBlack,
      );

  static TextStyle heading3({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.offBlack,
      );

  static TextStyle heading4({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.offBlack,
      );

  // Body — Space Mono (mono)
  static TextStyle body({Color? color, double? fontSize}) => GoogleFonts.spaceMono(
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.graphite,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.smoke,
      );

  // Labels — Space Mono (mono, weight 500)
  static TextStyle label({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.offBlack,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.smoke,
      );

  static TextStyle labelTiny({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.smoke,
      );

  // Stats
  static TextStyle statNumber({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.offBlack,
      );

  static TextStyle statLabel({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.smoke,
        letterSpacing: 1.2,
      );
}
