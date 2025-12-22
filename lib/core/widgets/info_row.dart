import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacings.dart';

/// Reusable widget for displaying information rows with icon, label, and value
///
/// Example usage:
/// ```dart
/// InfoRow(
///   icon: Icons.location_on,
///   label: 'Tujuan',
///   value: 'Jakarta Selatan',
/// )
/// ```
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final TextStyle? valueStyle;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
        const SizedBox(width: AppSpacings.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: valueStyle ?? AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
