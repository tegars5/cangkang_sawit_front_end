import 'package:flutter/material.dart';

/// Centralized color constants for the app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary colors
  static const Color primary = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFF66BB6A);

  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);

  // Input colors
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE0E0E0);

  // Status colors
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF4CAF50);

  // Utility colors
  static Color primaryLight = primary.withValues(alpha: 0.1);
  static Color primaryMedium = primary.withValues(alpha: 0.15);
  static Color primaryShadow = primary.withValues(alpha: 0.3);
  static Color shadowLight = Colors.black.withValues(alpha: 0.06);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.08);
}
