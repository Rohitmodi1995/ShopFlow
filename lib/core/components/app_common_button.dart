import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppCommonButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;
  final double height;

  const AppCommonButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isOutlined
        ? AppColors.primary
        : AppColors.whiteColor;

    final child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foregroundColor,
            ),
          )
        : Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            mainAxisSize:
                MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed:
                  isLoading
                      ? null
                      : onPressed,
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    AppColors.primary,
                disabledForegroundColor:
                    AppColors.textSecondary,
                side: BorderSide(
                  color: onPressed == null
                      ? AppColors.inputBorder
                      : AppColors.primary,
                ),
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed:
                  isLoading
                      ? null
                      : onPressed,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    AppColors.whiteColor,
                disabledBackgroundColor:
                    AppColors.inputBorder,
                disabledForegroundColor:
                    AppColors.textSecondary,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              child: child,
            ),
    );
  }
}