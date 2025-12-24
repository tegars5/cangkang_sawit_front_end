import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacings.dart';
import '../theme/app_radius.dart';

/// Badge widget to display order/task status
class StatusBadge extends StatelessWidget {
  final String status;
  final String displayText;

  const StatusBadge({
    super.key,
    required this.status,
    required this.displayText,
  });

  Color get _backgroundColor {
    switch (status) {
      case 'pending':
        return Colors.orange.shade50;
      case 'on_delivery':
      case 'on_the_way':
      case 'arrived':
        return Colors.blue.shade50;
      case 'completed':
        return Colors.green.shade50;
      case 'cancelled':
        return Colors.red.shade50;
      default:
        return AppColors.surface;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'pending':
        return Colors.orange.shade700;
      case 'on_delivery':
      case 'on_the_way':
      case 'arrived':
        return Colors.blue.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'pending':
        return Icons.pending_outlined;
      case 'on_delivery':
      case 'on_the_way':
        return Icons.local_shipping_outlined;
      case 'arrived':
        return Icons.location_on_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.sm,
        vertical: AppSpacings.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: AppRadius.smallRadius,
        border: Border.all(color: _textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 16, color: _textColor),
          const SizedBox(width: AppSpacings.xs),
          Text(
            displayText,
            style: AppTextStyles.bodySmall.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
