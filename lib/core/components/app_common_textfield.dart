import 'package:flutter/material.dart';
import 'package:shopflow/core/constants/app_colors.dart';

import '../theme/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool obscureText;
  final String hintText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? minLines;
  final int maxLines;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.minLines,
    this.maxLines = 1,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? colorScheme.onSurface : AppColors.textPrimary;

    final hintColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.55)
        : AppColors.textSecondary;

    final borderColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.60)
        : AppColors.inputBorder;

    final fieldColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
        : AppColors.background;

    final iconColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.75)
        : AppColors.textPrimary;

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      validator: validator,
      minLines: obscureText ? 1 : minLines,
      maxLines: obscureText ? 1 : maxLines,
      textInputAction: textInputAction,
      style: AppStyles.inputText.copyWith(color: textColor),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        filled: true,
        fillColor: fieldColor,
        hintText: hintText,
        hintStyle: AppStyles.inputHint.copyWith(color: hintColor),
        prefixIcon: prefixIcon == null
            ? null
            : IconTheme(
                data: IconThemeData(color: iconColor),
                child: prefixIcon!,
              ),
        suffixIcon: suffixIcon == null
            ? null
            : IconTheme(
                data: IconThemeData(color: iconColor),
                child: suffixIcon!,
              ),
        counterText: '',
        errorStyle: TextStyle(color: colorScheme.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
