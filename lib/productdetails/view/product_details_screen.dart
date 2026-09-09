import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../address/view/address_screen.dart';
import '../../cart/viewmodel/cart_viewmodel.dart';
import '../../checkout/model/checkout_data.dart';
import '../../core/components/app_common_button.dart';
import '../../core/components/productdetails/shimmer/product_details_shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_styles.dart';
import '../../home/model/product_model.dart';
import '../../wishlist/viewmodel/wishlist_viewmodel.dart';
import '../viewmodel/product_details_viewmodel.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<ProductDetailsViewModel>().setProduct(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colorScheme.surface : AppColors.background;

    final viewModel = context.watch<ProductDetailsViewModel>();

    final product = viewModel.product;

    if (product == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const SafeArea(child: ProductDetailsShimmer()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context, product),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageSection(context, product, viewModel),
                        const SizedBox(height: AppSpacing.lg),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProductInformation(context, product),
                              const SizedBox(height: AppSpacing.lg),
                              _buildStockAndQuantity(
                                context,
                                product,
                                viewModel,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              _buildDescription(context, product, viewModel),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomButton(context, product, viewModel),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ProductModel product) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? colorScheme.surface : AppColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.maybePop(context);
        },
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
      ),
      title: Text(
        product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppStyles.headerText.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _shareProduct(product);
          },
          icon: const Icon(Icons.share_outlined, size: 22),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) {
    final images = viewModel.productImages;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AspectRatio(
            aspectRatio: 1.05,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainer
                        : AppColors.lightPurple,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: images.isEmpty
                        ? _buildImageError(context)
                        : PageView.builder(
                            itemCount: images.length,
                            onPageChanged: viewModel.setImageIndex,
                            itemBuilder: (context, index) {
                              return _buildNetworkImage(context, images[index]);
                            },
                          ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: _buildWishlistButton(product),
                ),
              ],
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          _buildImageIndicator(
            context,
            images.length,
            viewModel.currentImageIndex,
          ),
        ],
      ],
    );
  }

  Widget _buildNetworkImage(BuildContext context, String imageUrl) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }

        if (frame == null) {
          return _buildImageShimmer(context);
        }

        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildImageError(context);
      },
    );
  }

  Widget _buildImageShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark
          ? colorScheme.onSurface.withValues(alpha: 0.10)
          : AppColors.inputBorder,
      highlightColor: isDark
          ? colorScheme.onSurface.withValues(alpha: 0.20)
          : AppColors.background,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? colorScheme.surfaceContainer : AppColors.whiteColor,
      ),
    );
  }

  Widget _buildImageError(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.primary,
        size: 60,
      ),
    );
  }

  Widget _buildWishlistButton(ProductModel product) {
    return Consumer<WishlistViewModel>(
      builder: (context, wishlistViewModel, child) {
        final isWishlist = wishlistViewModel.isInWishlist(product.id);

        return Material(
          color: AppColors.whiteColor,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            onTap: () {
              wishlistViewModel.toggleWishlist(product);
            },
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                isWishlist ? Icons.favorite : Icons.favorite_border,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageIndicator(
    BuildContext context,
    int count,
    int currentIndex,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isSelected = currentIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 18 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : isDark
                ? colorScheme.onSurface.withValues(alpha: 0.25)
                : AppColors.inputBorder,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildProductInformation(BuildContext context, ProductModel product) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: AppStyles.headerText.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildRating(context, product),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildPriceCard(context, product),
      ],
    );
  }

  Widget _buildRating(BuildContext context, ProductModel product) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        ...List.generate(5, (index) {
          final star = index + 1;

          return Icon(
            product.rating >= star
                ? Icons.star_rounded
                : product.rating >= star - 0.5
                ? Icons.star_half_rounded
                : Icons.star_border_rounded,
            size: 20,
            color: Colors.amber,
          );
        }),
        const SizedBox(width: AppSpacing.sm),
        Text(
          product.rating.toStringAsFixed(1),
          style: AppStyles.subHeading.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.70),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(BuildContext context, ProductModel product) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? colorScheme.onSurface.withValues(alpha: 0.15)
              : AppColors.inputBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₹${product.discountPrice.toStringAsFixed(0)}',
            style: AppStyles.headerText.copyWith(
              color: AppColors.primary,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (product.price > product.discountPrice) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '₹${product.price.toStringAsFixed(0)}',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.60),
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockAndQuantity(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final inStock = product.stock > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colorScheme.onSurface.withValues(alpha: 0.15)
              : AppColors.inputBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: inStock
                  ? Colors.green.withValues(alpha: 0.10)
                  : Colors.red.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: inStock ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  inStock
                      ? AppLanguage.inStock[AppConstant.language]
                      : AppLanguage.outOfStock[AppConstant.language],
                  style: TextStyle(
                    color: inStock ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (inStock) _buildQuantitySelector(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(
    BuildContext context,
    ProductDetailsViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _quantityButton(
          context: context,
          icon: Icons.remove,
          onTap: viewModel.decreaseQuantity,
        ),
        SizedBox(
          width: 42,
          child: Text(
            viewModel.quantity.toString(),
            textAlign: TextAlign.center,
            style: AppStyles.headerText.copyWith(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        _quantityButton(
          context: context,
          icon: Icons.add,
          onTap: viewModel.increaseQuantity,
        ),
      ],
    );
  }

  Widget _quantityButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark
                ? colorScheme.onSurface.withValues(alpha: 0.20)
                : AppColors.inputBorder,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 19, color: colorScheme.onSurface),
      ),
    );
  }

  Widget _buildDescription(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final description = product.description.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLanguage.description[AppConstant.language],
          style: AppStyles.headerText.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          description.isNotEmpty
              ? description
              : AppLanguage.noDescriptionAvailable[AppConstant.language],
          maxLines: viewModel.isDescriptionExpanded ? null : 3,
          overflow: viewModel.isDescriptionExpanded
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: AppStyles.subHeading.copyWith(
            height: 1.6,
            color: colorScheme.onSurface.withValues(alpha: 0.70),
          ),
        ),
        if (description.length > 100) ...[
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: viewModel.toggleDescription,
            child: Text(
              viewModel.isDescriptionExpanded
                  ? AppLanguage.readLess[AppConstant.language]
                  : AppLanguage.readMore[AppConstant.language],
              style: AppStyles.headerText.copyWith(
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final inStock = product.stock > 0;

    return Container(
      color: isDark ? colorScheme.surface : AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              children: [
                Expanded(
                  child: AppCommonButton(
                    title: inStock
                        ? AppLanguage.addToCart[AppConstant.language]
                        : AppLanguage.outOfStock[AppConstant.language],
                    icon: Icons.shopping_cart_outlined,
                    isOutlined: true,
                    onPressed: !inStock
                        ? null
                        : () {
                            _addToCart(context, product, viewModel);
                          },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppCommonButton(
                    title: AppLanguage.buyNow[AppConstant.language],
                    icon: Icons.flash_on_rounded,
                    onPressed: !inStock
                        ? null
                        : () {
                            _buyNow(context, product, viewModel);
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) async {
    await context.read<CartViewModel>().addToCart(
      product,
      quantity: viewModel.quantity,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${viewModel.quantity} × '
            '${product.name} '
            '${AppLanguage.addedToCart[AppConstant.language]}',
          ),
        ),
      );
  }

  void _buyNow(
    BuildContext context,
    ProductModel product,
    ProductDetailsViewModel viewModel,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressScreen(
          isCheckout: true,
          checkoutData: CheckoutData.buyNow(
            product: product,
            quantity: viewModel.quantity,
          ),
        ),
      ),
    );
  }

  void _shareProduct(ProductModel product) {}
}
