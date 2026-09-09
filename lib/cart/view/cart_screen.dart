import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../address/view/address_screen.dart';
import '../../checkout/model/checkout_data.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_styles.dart';
import '../model/cart_item_model.dart';
import '../viewmodel/cart_viewmodel.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colorScheme.surface : AppColors.background;

    final cartViewModel = context.watch<CartViewModel>();

    _handleActionError(context, cartViewModel);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: isDark ? colorScheme.onSurface : AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          AppLanguage.myCart[AppConstant.language],
          style: AppStyles.headerText.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? colorScheme.onSurface : AppColors.textPrimary,
          ),
        ),
      ),
      body: _buildBody(context, cartViewModel),
    );
  }

  Widget _buildBody(BuildContext context, CartViewModel cartViewModel) {
    if (cartViewModel.isLoading && cartViewModel.cartItems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (cartViewModel.errorMessage != null && cartViewModel.cartItems.isEmpty) {
      return _buildErrorView(context, cartViewModel);
    }

    if (cartViewModel.isEmpty) {
      return _buildEmptyCart(context);
    }

    return _buildCartContent(context, cartViewModel);
  }

  Widget _buildCartContent(BuildContext context, CartViewModel cartViewModel) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: cartViewModel.cartItems.length,
                separatorBuilder: (_, _) {
                  return const SizedBox(height: AppSpacing.md);
                },
                itemBuilder: (context, index) {
                  final cartItem = cartViewModel.cartItems[index];

                  return _buildCartItem(context, cartItem, cartViewModel);
                },
              ),
            ),
          ),
        ),
        _buildOrderSummary(context, cartViewModel),
      ],
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItemModel cartItem,
    CartViewModel cartViewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final product = cartItem.product;

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.35)
        : AppColors.inputBorder;

    final imageBackgroundColor = isDark
        ? AppColors.primary.withValues(alpha: 0.10)
        : AppColors.lightPurple;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 95,
              height: 105,
              color: imageBackgroundColor,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImageError();
                      },
                    )
                  : _buildImageError(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: SizedBox(
              height: 105,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.headerText.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? colorScheme.onSurface
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          cartViewModel.removeFromCart(product.id);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 21,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '₹${product.discountPrice.toStringAsFixed(0)}',
                    style: AppStyles.headerText.copyWith(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _quantityButton(
                        context: context,
                        icon: Icons.remove,
                        onTap: () {
                          cartViewModel.decreaseQuantity(product.id);
                        },
                      ),
                      SizedBox(
                        width: 38,
                        child: Text(
                          cartItem.quantity.toString(),
                          textAlign: TextAlign.center,
                          style: AppStyles.headerText.copyWith(
                            fontSize: 15,
                            color: isDark
                                ? colorScheme.onSurface
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _quantityButton(
                        context: context,
                        icon: Icons.add,
                        onTap: () {
                          cartViewModel.increaseQuantity(product.id);
                        },
                      ),
                      const Spacer(),
                      Text(
                        '₹${cartItem.totalPrice.toStringAsFixed(0)}',
                        style: AppStyles.headerText.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? colorScheme.onSurface
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest
              : Colors.transparent,
          border: Border.all(
            color: isDark
                ? colorScheme.outline.withValues(alpha: 0.40)
                : AppColors.inputBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 17,
          color: isDark ? colorScheme.onSurface : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartViewModel cartViewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final summaryColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.30)
        : AppColors.inputBorder;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: summaryColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _summaryRow(
                    context: context,
                    title: AppLanguage.products[AppConstant.language],
                    value: cartViewModel.totalProducts.toString(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _summaryRow(
                    context: context,
                    title: AppLanguage.totalQuantity[AppConstant.language],
                    value: cartViewModel.totalItems.toString(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _summaryRow(
                    context: context,
                    title: AppLanguage.subtotal[AppConstant.language],
                    value: '₹${cartViewModel.subTotal.toStringAsFixed(0)}',
                    isTotal: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        _proceedToCheckout(context, cartViewModel);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.whiteColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppLanguage.proceedToCheckout[AppConstant.language],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow({
    required BuildContext context,
    required String title,
    required String value,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppStyles.subHeading.copyWith(
            color: isDark
                ? colorScheme.onSurface.withValues(alpha: 0.70)
                : AppColors.textSecondary,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppStyles.headerText.copyWith(
            color: isTotal
                ? AppColors.primary
                : isDark
                ? colorScheme.onSurface
                : AppColors.textPrimary,
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final iconBackgroundColor = isDark
        ? AppColors.primary.withValues(alpha: 0.12)
        : AppColors.lightPurple;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
                Icons.shopping_cart_outlined,
                color: AppColors.primary,
                size: 50,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLanguage.emptyCartTitle[AppConstant.language],
              textAlign: TextAlign.center,
              style: AppStyles.headerText.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: isDark ? colorScheme.onSurface : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLanguage.emptyCartSubtitle[AppConstant.language],
              textAlign: TextAlign.center,
              style: AppStyles.subHeading.copyWith(
                color: isDark
                    ? colorScheme.onSurface.withValues(alpha: 0.65)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, CartViewModel cartViewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              cartViewModel.errorMessage ??
                  AppLanguage.somethingWentWrongError[AppConstant.language],
              textAlign: TextAlign.center,
              style: AppStyles.subHeading.copyWith(
                color: isDark ? colorScheme.onSurface : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: cartViewModel.loadCart,
              child: Text(AppLanguage.retry[AppConstant.language]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.primary,
        size: 35,
      ),
    );
  }

  void _handleActionError(BuildContext context, CartViewModel cartViewModel) {
    final errorMessage = cartViewModel.errorMessage;

    if (errorMessage == null ||
        cartViewModel.cartItems.isEmpty ||
        cartViewModel.isLoading) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));

      cartViewModel.clearError();
    });
  }

  void _proceedToCheckout(BuildContext context, CartViewModel cartViewModel) {
    if (cartViewModel.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressScreen(
          isCheckout: true,
          checkoutData: CheckoutData.cart(items: cartViewModel.cartItems),
        ),
      ),
    );
  }
}
