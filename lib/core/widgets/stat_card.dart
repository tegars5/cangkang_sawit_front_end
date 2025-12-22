import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacings.dart';
import '../theme/app_radius.dart';

/// Reusable statistics card for dashboard
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacings.itemSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(AppSpacings.sm),
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
          ),
          const SizedBox(height: AppSpacings.sm + 4),

          // Title
          Text(
            title,
            style: AppTextStyles.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacings.xs),

          // Value
          Text(value, style: AppTextStyles.displaySmall.copyWith(fontSize: 28)),

          // Subtitle (optional)
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacings.xs),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
