import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacings.dart';
import '../theme/app_radius.dart';

/// Reusable order/task list item card
class OrderListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color? statusColor;
  final VoidCallback? onTap;

  const OrderListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacings.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mediumRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacings.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacings.xs),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacings.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacings.sm + 4,
                    vertical: AppSpacings.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: (statusColor ?? AppColors.primary).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: statusColor ?? AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
