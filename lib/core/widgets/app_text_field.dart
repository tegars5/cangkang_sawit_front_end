import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable text field widget with consistent styling
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTextStyles.input,
      onChanged: onChanged,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label ?? labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.primary)
            : null,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
