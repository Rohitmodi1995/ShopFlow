import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import '../constants/app_spacing.dart';
import '../theme/app_styles.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final titleColor = isDark
        ? colorScheme.onSurface
        : AppColors.textPrimary;

    final subtitleColor = isDark
        ? colorScheme.onSurfaceVariant
        : AppColors.textSecondary;

    return Column(
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).size.height *
                  0.22,
          width: double.infinity,
          child: Image.asset(
            AppImages.applogo,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(
          height: AppSpacing.md,
        ),
        Text(
          title,
          style: AppStyles.mainHeading.copyWith(
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: AppSpacing.sm,
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            subtitle,
            style: AppStyles.subHeading.copyWith(
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}