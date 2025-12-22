import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacings.dart';

/// Reusable widget for displaying loading states
///
/// Example usage:
/// ```dart
/// LoadingSection(message: 'Memuat data...')
/// ```
class LoadingSection extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingSection({super.key, this.message, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacings.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size ?? 40,
              height: size ?? 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacings.md),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
