import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized text styles using Poppins font
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // Display styles
  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle displaySmall = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Headline styles
  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Title styles
  static TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Body styles
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
  );

  // Button style
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Subtitle style
  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Input field style
  static TextStyle input = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static TextStyle inputLabel = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static TextStyle inputHint = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textTertiary,
  );
}
