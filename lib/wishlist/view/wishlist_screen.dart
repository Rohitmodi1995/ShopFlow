import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/home/product_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_styles.dart';
import '../viewmodel/wishlist_viewmodel.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? colorScheme.surface
        : AppColors.whiteColor;

    final wishlistViewModel =
        context.watch<WishlistViewModel>();

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
          AppLanguage.myWishlist[
              AppConstant.language],
          style: AppStyles.headerText.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? colorScheme.onSurface
                : AppColors.textPrimary,
          ),
        ),
      ),
      body: _buildBody(
        context,
        wishlistViewModel,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WishlistViewModel viewModel,
  ) {
    if (viewModel.isLoading &&
        viewModel.wishlistProducts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (viewModel.errorMessage != null &&
        viewModel.wishlistProducts.isEmpty) {
      return _buildErrorView(
        context,
        viewModel,
      );
    }

    if (viewModel.wishlistProducts.isEmpty) {
      return _buildEmptyWishlist(
        context,
      );
    }

    return _buildWishlistProducts(
      context,
      viewModel,
    );
  }

  Widget _buildWishlistProducts(
    BuildContext context,
    WishlistViewModel viewModel,
  ) {
    final products =
        viewModel.wishlistProducts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            _getCrossAxisCount(
          constraints.maxWidth,
        );

        return GridView.builder(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          itemCount: products.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final product =
                products[index];

            return ProductCard(
              product: product,
              isWishlist: true,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.productDetails,
                  arguments: product,
                );
              },
              onWishlist: () {
                viewModel.toggleWishlist(
                  product,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyWishlist(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final iconBackgroundColor = isDark
        ? AppColors.primary.withValues(
            alpha: 0.12,
          )
        : AppColors.lightPurple;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: AppColors.primary,
                size: 50,
              ),
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              AppLanguage.emptyWishlistTitle[
                  AppConstant.language],
              textAlign: TextAlign.center,
              style: AppStyles.headerText.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? colorScheme.onSurface
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              AppLanguage
                      .emptyWishlistSubtitle[
                  AppConstant.language],
              textAlign: TextAlign.center,
              style: AppStyles.subHeading.copyWith(
                color: isDark
                    ? colorScheme.onSurface
                        .withValues(
                          alpha: 0.65,
                        )
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    WishlistViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 48,
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            Text(
              viewModel.errorMessage ??
                  AppLanguage
                          .somethingWentWrongError[
                      AppConstant.language],
              textAlign: TextAlign.center,
              style: AppStyles.subHeading.copyWith(
                color: isDark
                    ? colorScheme.onSurface
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            ElevatedButton(
              onPressed: viewModel.loadWishlist,
              child: Text(
                AppLanguage.retry[
                    AppConstant.language],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(
    double width,
  ) {
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
}