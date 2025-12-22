import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacings.dart';
import '../theme/app_radius.dart';

/// Reusable widget for displaying error states with retry functionality
///
/// Example usage:
/// ```dart
/// ErrorView(
///   message: 'Gagal memuat data',
///   onRetry: () => _fetchData(),
/// )
/// ```
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryButtonText;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.xl),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacings.md),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacings.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryButtonText ?? 'Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
