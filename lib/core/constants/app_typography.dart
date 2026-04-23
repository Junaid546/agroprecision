import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Display stat (for big metrics like $5,120.00 or 4,892)
  static TextStyle displayStat = GoogleFonts.manrope(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 44 / 36,
    letterSpacing: -0.72,
    color: AppColors.onSurface,
  );

  // Headline Large (screen titles)
  static TextStyle headlineLg = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.24,
    color: AppColors.onSurface,
  );

  // Headline Medium (card headers)
  static TextStyle headlineMd = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: AppColors.onSurface,
  );

  // Body Large
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.onSurface,
  );

  // Body Medium
  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurfaceVariant,
  );

  // Label Bold (chips, badges)
  static TextStyle labelBold = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  // Label Medium
  static TextStyle labelMd = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: AppColors.onSurfaceVariant,
  );

  // App bar title
  static TextStyle appBarTitle = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.2,
  );

  // Nav label
  static TextStyle navLabel = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
