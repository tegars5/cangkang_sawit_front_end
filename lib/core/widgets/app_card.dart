import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacings.dart';

/// Reusable card container with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final double? padding;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding ?? AppSpacings.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
