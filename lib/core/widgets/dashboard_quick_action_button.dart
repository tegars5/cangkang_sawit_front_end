import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DashboardQuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const DashboardQuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? const Color(0xFF0D1B2A)
          : Colors
                .transparent, // Using dark navy for primary as per design ref, or keep generic?
      // The user asked to keep "Cangkang Sawit" theme (green).
      // But the image shows Navy. I will stick to AppColors.primary (Green) for brand consistency as requested.
      // "Gunakan tetap warna hijau/tema Cangkang Sawit"
      // So I will use AppColors.primary for filled.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPrimary ? BorderSide.none : BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: isPrimary
              ? BoxDecoration(
                  color: AppColors.primary, // Using primary green
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Row(
            mainAxisAlignment: isPrimary
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isPrimary ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: isPrimary ? TextAlign.center : TextAlign.left,
                ),
              ),
              if (!isPrimary)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textTertiary,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
