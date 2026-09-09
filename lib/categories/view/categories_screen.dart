import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/home/product_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_styles.dart';
import '../../wishlist/viewmodel/wishlist_viewmodel.dart';
import '../viewmodel/categories_viewmodel.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<CategoriesViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colorScheme.surface : AppColors.whiteColor;

    final viewModel = context.watch<CategoriesViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          AppLanguage.categories[AppConstant.language],
          style: AppStyles.headerText.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? colorScheme.onSurface : AppColors.textPrimary,
          ),
        ),
      ),
      body: Container(
        color: backgroundColor,
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CategoriesViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorView(context, viewModel);
    }

    return Column(
      children: [
        _buildCategories(context, viewModel),
        const SizedBox(height: AppSpacing.md),
        Expanded(child: _buildProducts(context, viewModel)),
      ],
    );
  }

  Widget _buildCategories(BuildContext context, CategoriesViewModel viewModel) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.categories.length + 1,
        separatorBuilder: (_, _) {
          return const SizedBox(width: AppSpacing.sm);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return _categoryChip(
              context: context,
              title: AppLanguage.all[AppConstant.language],
              isSelected: viewModel.selectedCategory == 'all',
              onTap: viewModel.selectAllCategories,
            );
          }

          final category = viewModel.categories[index - 1];

          return _categoryChip(
            context: context,
            title: category.name,
            isSelected: viewModel.selectedCategory == category.id,
            onTap: () {
              viewModel.selectCategory(category.id);
            },
          );
        },
      ),
    );
  }

  Widget _categoryChip({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final chipBackgroundColor = isSelected
        ? AppColors.primary
        : isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.whiteColor;

    final chipBorderColor = isSelected
        ? AppColors.primary
        : isDark
        ? colorScheme.outline.withValues(alpha: 0.40)
        : AppColors.inputBorder;

    final chipTextColor = isSelected
        ? AppColors.whiteColor
        : isDark
        ? colorScheme.onSurface
        : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: chipBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: chipBorderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppStyles.subHeading.copyWith(
            color: chipTextColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProducts(BuildContext context, CategoriesViewModel viewModel) {
    final products = viewModel.filteredProducts;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (products.isEmpty) {
      return Center(
        child: Text(
          AppLanguage.noProductsFound[AppConstant.language],
          style: AppStyles.subHeading.copyWith(
            color: isDark
                ? colorScheme.onSurface.withValues(alpha: 0.70)
                : AppColors.textSecondary,
          ),
        ),
      );
    }

    final wishlistViewModel = context.watch<WishlistViewModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return ProductCard(
              product: product,
              isWishlist: wishlistViewModel.isInWishlist(product.id),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.productDetails,
                  arguments: product,
                );
              },
              onWishlist: () {
                context.read<WishlistViewModel>().toggleWishlist(product);
              },
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) {
      return 5;
    }

    if (width >= 900) {
      return 4;
    }

    if (width >= 600) {
      return 3;
    }

    return 2;
  }

  Widget _buildErrorView(BuildContext context, CategoriesViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.primary, size: 45),
            const SizedBox(height: AppSpacing.md),
            Text(
              viewModel.errorMessage ??
                  AppLanguage.somethingWentWrongError[AppConstant.language],
              textAlign: TextAlign.center,
              style: AppStyles.subHeading.copyWith(
                color: isDark ? colorScheme.onSurface : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: viewModel.initialize,
              child: Text(AppLanguage.retry[AppConstant.language]),
            ),
          ],
        ),
      ),
    );
  }
}
