import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../address/model/address_model.dart';
import '../../cart/model/cart_item_model.dart';
import '../../cart/viewmodel/cart_viewmodel.dart';
import '../../core/components/app_common_button.dart';
import '../../core/components/app_common_header.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_styles.dart';
import '../../orders/model/order_model.dart';
import '../../orders/model/order_summary_argument.dart';
import '../../orders/viewmodel/order_viewmodel.dart';
import '../../payment/service/payment_gateway.dart';
import '../../payment/viewmodel/payment_viewmodel.dart';
import '../model/checkout_data.dart';

class OrderSummaryScreen extends StatelessWidget {
  final AddressModel address;
  final CheckoutData checkoutData;

  const OrderSummaryScreen({
    super.key,
    required this.address,
    required this.checkoutData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colorScheme.surface : AppColors.background;

    final items = _getCheckoutItems();
    final subTotal = _calculateSubTotal(items);

    const deliveryCharge = 0.0;

    final totalAmount = subTotal + deliveryCharge;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppCommonHeader(
        title: AppLanguage.orderSummary[AppConstant.language],
      ),
      body: items.isEmpty
          ? _buildEmptyView(context)
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                              context,
                              AppLanguage.deliveryAddress[AppConstant.language],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildAddressCard(context),
                            const SizedBox(height: AppSpacing.lg),
                            _buildSectionTitle(
                              context,
                              AppLanguage.orderItems[AppConstant.language],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: AppSpacing.sm);
                              },
                              itemBuilder: (context, index) {
                                return _buildProductItem(context, items[index]);
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildSectionTitle(
                              context,
                              AppLanguage.priceDetails[AppConstant.language],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildPriceDetails(
                              context: context,
                              subTotal: subTotal,
                              deliveryCharge: deliveryCharge,
                              totalAmount: totalAmount,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildBottomSection(
                  context: context,
                  items: items,
                  totalAmount: totalAmount,
                ),
              ],
            ),
    );
  }

  List<CartItemModel> _getCheckoutItems() {
    if (checkoutData.isBuyNow) {
      final product = checkoutData.product;

      if (product == null) {
        return [];
      }

      return [CartItemModel(product: product, quantity: checkoutData.quantity)];
    }

    return checkoutData.items;
  }

  double _calculateSubTotal(List<CartItemModel> items) {
    return items.fold(0.0, (total, cartItem) {
      final product = cartItem.product;

      final productPrice = product.discountPrice > 0
          ? product.discountPrice
          : product.price;

      return total + (productPrice * cartItem.quantity);
    });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      title,
      style: AppStyles.headerText.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.35)
        : AppColors.inputBorder;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  address.name,
                  style: AppStyles.headerText.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLanguage.defaultText[AppConstant.language],
                    style: AppStyles.subHeading.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            address.phone,
            style: AppStyles.subHeading.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.70),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _getFullAddress(),
            style: AppStyles.subHeading.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, CartItemModel cartItem) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final product = cartItem.product;

    final productPrice = product.discountPrice > 0
        ? product.discountPrice
        : product.price;

    final itemTotal = productPrice * cartItem.quantity;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : AppColors.whiteColor,
        border: Border.all(
          color: isDark
              ? colorScheme.outline.withValues(alpha: 0.35)
              : AppColors.inputBorder,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : AppColors.lightPurple,
              child: product.imageUrl.isEmpty
                  ? _buildImageError()
                  : Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImageError();
                      },
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.headerText.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${AppLanguage.quantityShort[AppConstant.language]}: '
                  '${cartItem.quantity}',
                  style: AppStyles.subHeading.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.70),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '₹${productPrice.toStringAsFixed(0)} × '
                  '${cartItem.quantity}',
                  style: AppStyles.subHeading.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '₹${itemTotal.toStringAsFixed(0)}',
            style: AppStyles.headerText.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails({
    required BuildContext context,
    required double subTotal,
    required double deliveryCharge,
    required double totalAmount,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : AppColors.whiteColor,
        border: Border.all(
          color: isDark
              ? colorScheme.outline.withValues(alpha: 0.35)
              : AppColors.inputBorder,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            context: context,
            title: AppLanguage.subtotal[AppConstant.language],
            value: '₹${subTotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPriceRow(
            context: context,
            title: AppLanguage.deliveryCharge[AppConstant.language],
            value: deliveryCharge == 0
                ? AppLanguage.free[AppConstant.language]
                : '₹${deliveryCharge.toStringAsFixed(0)}',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(
              height: 1,
              color: isDark
                  ? colorScheme.outline.withValues(alpha: 0.30)
                  : AppColors.inputBorder,
            ),
          ),
          _buildPriceRow(
            context: context,
            title: AppLanguage.totalAmount[AppConstant.language],
            value: '₹${totalAmount.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required BuildContext context,
    required String title,
    required String value,
    bool isTotal = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppStyles.subHeading.copyWith(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: isTotal ? 1 : 0.70),
          ),
        ),
        Text(
          value,
          style: AppStyles.headerText.copyWith(
            color: isTotal ? AppColors.primary : colorScheme.onSurface,
            fontSize: isTotal ? 17 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection({
    required BuildContext context,
    required List<CartItemModel> items,
    required double totalAmount,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : AppColors.whiteColor,
        border: Border(
          top: BorderSide(
            color: isDark
                ? colorScheme.outline.withValues(alpha: 0.30)
                : AppColors.inputBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLanguage.total[AppConstant.language],
                          style: AppStyles.subHeading.copyWith(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '₹${totalAmount.toStringAsFixed(0)}',
                          style: AppStyles.headerText.copyWith(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Consumer2<PaymentViewModel, OrderViewModel>(
                      builder:
                          (context, paymentViewModel, orderViewModel, child) {
                            final isLoading =
                                paymentViewModel.isProcessing ||
                                orderViewModel.isCreatingOrder;

                            return AppCommonButton(
                              title: AppLanguage
                                  .continueToPayment[AppConstant.language],
                              isLoading: isLoading,
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      await _continueToPayment(
                                        context: context,
                                        items: items,
                                        totalAmount: totalAmount,
                                      );
                                    },
                            );
                          },
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

  Widget _buildEmptyView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          AppLanguage.noProductsAvailableForCheckout[AppConstant.language],
          textAlign: TextAlign.center,
          style: AppStyles.subHeading.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.70),
          ),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }

  String _getFullAddress() {
    return '${address.house}, '
        '${address.street}, '
        '${address.city}, '
        '${address.state} - '
        '${address.pincode}';
  }

  Future<void> _continueToPayment({
    required BuildContext context,
    required List<CartItemModel> items,
    required double totalAmount,
  }) async {
    if (items.isEmpty) {
      return;
    }

    final paymentViewModel = context.read<PaymentViewModel>();

    paymentViewModel.startPayment(
      amount: totalAmount,
      name: 'ShopFlow',
      description: AppLanguage.orderPayment[AppConstant.language],
      email: '',
      contact: address.phone,
      onSuccess: (PaymentSuccessResult result) async {
        if (!context.mounted) {
          return;
        }

        final paymentId = result.paymentId?.trim();

        if (paymentId == null || paymentId.isEmpty) {
          _showMessage(
            context,
            AppLanguage.paymentIdNotReceived[AppConstant.language],
          );
          return;
        }

        final subTotal = _calculateSubTotal(items);

        const deliveryCharge = 0.0;

        final orderItems = items.map((cartItem) {
          final product = cartItem.product;

          final productPrice = product.discountPrice > 0
              ? product.discountPrice
              : product.price;

          return OrderItemModel(
            productId: product.id,
            name: product.name,
            imageUrl: product.imageUrl,
            price: productPrice,
            quantity: cartItem.quantity,
          );
        }).toList();

        final orderAddress = OrderAddressModel(
          name: address.name,
          phone: address.phone,
          house: address.house,
          street: address.street,
          city: address.city,
          state: address.state,
          pincode: address.pincode,
        );

        final order = OrderModel(
          id: '',
          userId: '',
          items: orderItems,
          address: orderAddress,
          subTotal: subTotal,
          deliveryCharge: deliveryCharge,
          totalAmount: totalAmount,
          orderStatus: 'confirmed',
          paymentStatus: 'paid',
          paymentMethod: 'razorpay',
          razorpayOrderId: result.orderId?.trim(),
          razorpayPaymentId: paymentId,
          createdAt: DateTime.now(),
        );

        final orderViewModel = context.read<OrderViewModel>();

        final orderId = await orderViewModel.createOrder(order);

        if (!context.mounted) {
          return;
        }

        if (orderId == null) {
          _showMessage(
            context,
            orderViewModel.errorMessage ??
                AppLanguage.paymentSuccessfulOrderUpdateFailed[AppConstant
                    .language],
          );
          return;
        }

        if (checkoutData.isCart) {
          await context.read<CartViewModel>().clearCart();
        }

        if (!context.mounted) {
          return;
        }

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.orderSuccess,
          arguments: OrderSuccessArguments(
            orderId: orderId,
            amount: totalAmount,
          ),
        );
      },
      onFailure: (_) {
        if (!context.mounted) {
          return;
        }

        _showMessage(context, AppLanguage.paymentFailed[AppConstant.language]);
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
