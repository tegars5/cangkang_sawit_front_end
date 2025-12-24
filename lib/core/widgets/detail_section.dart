import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacings.dart';
import 'app_card.dart';

/// Section container for detail screens
class DetailSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;

  const DetailSection({
    super.key,
    required this.title,
    this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: AppSpacings.sm),
              ],
              Text(title, style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacings.md),
          child,
        ],
      ),
    );
  }
}
