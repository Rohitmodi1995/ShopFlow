import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_languages.dart';
import '../../theme/app_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.headerText.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text(
            AppLanguage.viewAll[
                AppConstant.language],
            style: const TextStyle(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}