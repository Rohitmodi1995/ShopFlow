import 'package:flutter/material.dart';

import '../../../home/model/category_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../theme/app_styles.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isAll;

  const CategoryItem({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
    this.isAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.12)
        : isDark
            ? AppColors.primary.withValues(alpha: 0.10)
            : AppColors.lightPurple;

    final borderColor = isSelected
        ? AppColors.primary
        : isDark
            ? theme.dividerColor
            : AppColors.inputBorder;

    final textColor = isSelected
        ? AppColors.primary
        : isDark
            ? colorScheme.onSurface.withValues(alpha: 0.65)
            : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: isAll
                    ? const Icon(
                        Icons.grid_view_rounded,
                        color: AppColors.primary,
                        size: 28,
                      )
                    : _buildCategoryImage(),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppStyles.subHeading.copyWith(
                color: textColor,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryImage() {
    if (category.imageUrl.isEmpty) {
      return const Icon(
        Icons.category_outlined,
        color: AppColors.primary,
        size: 28,
      );
    }

    return Image.network(
      category.imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return const Icon(
          Icons.category_outlined,
          color: AppColors.primary,
          size: 28,
        );
      },
    );
  }
}