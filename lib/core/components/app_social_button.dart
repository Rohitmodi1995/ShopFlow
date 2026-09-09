import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_styles.dart';

class AppSocialButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppSocialButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? colorScheme.surfaceContainerHighest
        : Colors.white;

    final borderColor = isDark
        ? colorScheme.outline.withValues(
            alpha: 0.60,
          )
        : AppColors.inputBorder;

    final textColor = isDark
        ? colorScheme.onSurface
        : AppColors.textPrimary;

    final shadowColor = isDark
        ? Colors.black.withValues(
            alpha: 0.20,
          )
        : Colors.black.withValues(
            alpha: 0.06,
          );

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : onPressed,
          borderRadius:
              BorderRadius.circular(30),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color:
                          AppColors.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Image.asset(
                        iconPath,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        title,
                        style: AppStyles
                            .socialButtonText
                            .copyWith(
                          color: textColor,
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