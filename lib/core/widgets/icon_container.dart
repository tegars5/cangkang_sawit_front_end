import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Circular icon container with light background
class IconContainer extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  const IconContainer({
    super.key,
    required this.icon,
    this.size = 104,
    this.iconSize = 64,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size / 5),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: iconSize, color: iconColor ?? AppColors.primary),
    );
  }
}
