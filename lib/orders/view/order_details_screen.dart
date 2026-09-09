import 'package:flutter/material.dart';

import '../../core/components/app_common_header.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_styles.dart';
import '../model/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? colorScheme.surface
        : AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppCommonHeader(
        title: AppLanguage.orderDetails[
            AppConstant.language],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: ListView(
            padding: const EdgeInsets.all(
              AppSpacing.md,
            ),
            children: [
              _buildOrderInfo(context),
              const SizedBox(
                height: AppSpacing.md,
              ),
              _buildProducts(context),
              const SizedBox(
                height: AppSpacing.md,
              ),
              _buildAddress(context),
              const SizedBox(
                height: AppSpacing.md,
              ),
              _buildPriceSummary(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return _CommonCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            AppLanguage.orderInformation[
                AppConstant.language],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          _InfoRow(
            title: AppLanguage.orderId[
                AppConstant.language],
            value: order.id,
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          _InfoRow(
            title: AppLanguage.orderDate[
                AppConstant.language],
            value: _formatDate(
              order.createdAt,
            ),
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          _InfoRow(
            title: AppLanguage.orderStatus[
                AppConstant.language],
            value: _getLocalizedStatus(
              order.orderStatus,
            ),
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          _InfoRow(
            title: AppLanguage.paymentStatus[
                AppConstant.language],
            value: _getLocalizedStatus(
              order.paymentStatus,
            ),
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          _InfoRow(
            title: AppLanguage.paymentMethod[
                AppConstant.language],
            value: _getPaymentMethod(
              order.paymentMethod,
            ),
          ),
          if (order.razorpayPaymentId != null &&
              order.razorpayPaymentId!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.sm,
            ),
            _InfoRow(
              title: AppLanguage.transactionId[
                  AppConstant.language],
              value: order
                  .razorpayPaymentId!
                  .trim(),
            ),
          ],
          const SizedBox.shrink(),
          if (colorScheme.brightness ==
              Brightness.dark)
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildProducts(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final dividerColor = isDark
        ? colorScheme.outline.withValues(
            alpha: 0.30,
          )
        : AppColors.inputBorder;

    return _CommonCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            AppLanguage.products[
                AppConstant.language],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (
              context,
              index,
            ) {
              return Divider(
                height: 28,
                color: dividerColor,
              );
            },
            itemBuilder: (
              context,
              index,
            ) {
              final item =
                  order.items[index];

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _ProductImage(
                    imageUrl: item.imageUrl,
                  ),
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: AppStyles
                              .headerText
                              .copyWith(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w600,
                            color: colorScheme
                                .onSurface,
                          ),
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.sm,
                        ),
                        Text(
                          '₹${item.price.toStringAsFixed(2)} × '
                          '${item.quantity}',
                          style: AppStyles
                              .subHeading
                              .copyWith(
                            fontSize: 13,
                            color: colorScheme
                                .onSurface
                                .withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.sm,
                        ),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(2)}',
                          style: AppStyles
                              .headerText
                              .copyWith(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                            color: colorScheme
                                .onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddress(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final address = order.address;

    final fullAddress = [
      address.house,
      address.street,
      address.city,
      address.state,
      address.pincode,
    ].where(
      (value) => value.trim().isNotEmpty,
    ).join(', ');

    return _CommonCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            AppLanguage.deliveryAddress[
                AppConstant.language],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Text(
            address.name,
            style:
                AppStyles.headerText.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            address.phone,
            style:
                AppStyles.subHeading.copyWith(
              fontSize: 14,
              color: colorScheme.onSurface
                  .withValues(
                alpha: 0.65,
              ),
            ),
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          Text(
            fullAddress,
            style:
                AppStyles.subHeading.copyWith(
              height: 1.5,
              fontSize: 14,
              color: colorScheme.onSurface
                  .withValues(
                alpha: 0.80,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final dividerColor = isDark
        ? colorScheme.outline.withValues(
            alpha: 0.30,
          )
        : AppColors.inputBorder;

    return _CommonCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            AppLanguage.priceDetails[
                AppConstant.language],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          _PriceRow(
            title: AppLanguage.subtotal[
                AppConstant.language],
            amount: order.subTotal,
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          _PriceRow(
            title: AppLanguage.deliveryCharge[
                AppConstant.language],
            amount: order.deliveryCharge,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
            ),
            child: Divider(
              color: dividerColor,
            ),
          ),
          _PriceRow(
            title: AppLanguage.totalAmount[
                AppConstant.language],
            amount: order.totalAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Text(
      title,
      style:
          AppStyles.headerText.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    final day = date.day
        .toString()
        .padLeft(2, '0');

    final month = date.month
        .toString()
        .padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _getLocalizedStatus(
    String value,
  ) {
    switch (value.trim().toLowerCase()) {
      case 'paid':
        return AppLanguage.paid[
            AppConstant.language];

      case 'failed':
        return AppLanguage.failed[
            AppConstant.language];

      case 'confirmed':
        return AppLanguage.confirmed[
            AppConstant.language];

      case 'shipped':
        return AppLanguage.shipped[
            AppConstant.language];

      case 'delivered':
        return AppLanguage.delivered[
            AppConstant.language];

      case 'cancelled':
        return AppLanguage.cancelled[
            AppConstant.language];

      case 'out for delivery':
        return AppLanguage.outForDelivery[
            AppConstant.language];

      case 'pending':
      default:
        return AppLanguage.pending[
            AppConstant.language];
    }
  }

  String _getPaymentMethod(
    String value,
  ) {
    final normalizedValue =
        value.trim().toLowerCase();

    if (normalizedValue == 'razorpay') {
      return 'Razorpay';
    }

    if (value.trim().isEmpty) {
      return '-';
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }
}

class _CommonCard
    extends StatelessWidget {
  final Widget child;

  const _CommonCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isDark
        ? colorScheme.outline.withValues(
            alpha: 0.30,
          )
        : AppColors.inputBorder;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: child,
    );
  }
}

class _ProductImage
    extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.background;

    final iconColor = colorScheme.onSurface
        .withValues(
      alpha: 0.45,
    );

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.trim().isEmpty
          ? Icon(
              Icons.image_outlined,
              color: iconColor,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Icon(
                  Icons
                      .broken_image_outlined,
                  color: iconColor,
                );
              },
            ),
    );
  }
}

class _InfoRow
    extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style:
                AppStyles.subHeading.copyWith(
              fontSize: 14,
              color: colorScheme.onSurface
                  .withValues(
                alpha: 0.65,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: AppSpacing.md,
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style:
                AppStyles.headerText.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceRow
    extends StatelessWidget {
  final String title;
  final double amount;
  final bool isTotal;

  const _PriceRow({
    required this.title,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style:
                AppStyles.subHeading.copyWith(
              fontSize:
                  isTotal ? 16 : 14,
              fontWeight: isTotal
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: isTotal
                  ? colorScheme.onSurface
                  : colorScheme.onSurface
                      .withValues(
                      alpha: 0.65,
                    ),
            ),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style:
              AppStyles.headerText.copyWith(
            fontSize:
                isTotal ? 18 : 14,
            fontWeight: isTotal
                ? FontWeight.w700
                : FontWeight.w600,
            color: isTotal
                ? AppColors.primary
                : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}