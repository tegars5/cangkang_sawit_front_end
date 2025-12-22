import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';
import 'app_spacings.dart';

/// Main theme configuration for the app
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  static ThemeData get lightTheme {
    return ThemeData(
      // Modern color scheme
      primarySwatch: Colors.green,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      // Text theme
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          displaySmall: AppTextStyles.displaySmall,
          headlineMedium: AppTextStyles.headlineMedium,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.surface,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        labelStyle: AppTextStyles.inputLabel,
        hintStyle: AppTextStyles.inputHint,
        border: OutlineInputBorder(
          borderRadius: AppRadius.mediumRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mediumRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 3,
          shadowColor: AppColors.primaryShadow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacings.xl,
            vertical: AppSpacings.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: AppColors.shadowMedium,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        color: AppColors.surface,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacings.md,
          vertical: AppSpacings.sm,
        ),
      ),

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),

      useMaterial3: true,
    );
  }
}
