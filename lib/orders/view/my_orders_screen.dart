import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_common_button.dart';
import '../../core/components/app_common_header.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_styles.dart';
import '../model/order_argument.dart';
import '../model/order_model.dart';
import '../viewmodel/order_viewmodel.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({
    super.key,
  });

  @override
  State<MyOrdersScreen> createState() =>
      _MyOrdersScreenState();
}

class _MyOrdersScreenState
    extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        context
            .read<OrderViewModel>()
            .loadOrders();
      },
    );
  }

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
        title: AppLanguage.myOrders[
            AppConstant.language],
      ),
      body: Consumer<OrderViewModel>(
        builder: (
          context,
          orderViewModel,
          child,
        ) {
          if (orderViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (orderViewModel.errorMessage != null &&
              orderViewModel.orders.isEmpty) {
            return _buildErrorView(
              context,
              orderViewModel,
            );
          }

          if (orderViewModel.orders.isEmpty) {
            return _buildEmptyView(context);
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 900,
              ),
              child: RefreshIndicator(
                onRefresh: () =>
                    orderViewModel.loadOrders(),
                child: ListView.separated(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(
                    AppSpacing.md,
                  ),
                  itemCount:
                      orderViewModel.orders.length,
                  separatorBuilder: (
                    context,
                    index,
                  ) {
                    return const SizedBox(
                      height: AppSpacing.sm,
                    );
                  },
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final order =
                        orderViewModel.orders[index];

                    return _OrderCard(
                      order: order,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.orderDetails,
                          arguments:
                              OrderDetailsArguments(
                            order: order,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    OrderViewModel orderViewModel,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              Text(
                AppLanguage.unableToLoadOrders[
                    AppConstant.language],
                textAlign: TextAlign.center,
                style:
                    AppStyles.headerText.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                orderViewModel.errorMessage ??
                    AppLanguage.somethingWentWrong[
                        AppConstant.language],
                textAlign: TextAlign.center,
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
                height: AppSpacing.lg,
              ),
              SizedBox(
                width: 180,
                child: AppCommonButton(
                  title: AppLanguage.retry[
                      AppConstant.language],
                  onPressed: () {
                    orderViewModel.loadOrders();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 72,
                color: colorScheme.onSurface
                    .withValues(
                  alpha: 0.45,
                ),
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              Text(
                AppLanguage.noOrdersYet[
                    AppConstant.language],
                textAlign: TextAlign.center,
                style:
                    AppStyles.headerText.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                AppLanguage.noOrdersDescription[
                    AppConstant.language],
                textAlign: TextAlign.center,
                style:
                    AppStyles.subHeading.copyWith(
                  fontSize: 14,
                  color: colorScheme.onSurface
                      .withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final firstItem = order.items.isNotEmpty
        ? order.items.first
        : null;

    final totalQuantity =
        order.items.fold<int>(
      0,
      (
        previousValue,
        item,
      ) {
        return previousValue +
            item.quantity;
      },
    );

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isDark
        ? colorScheme.outline.withValues(
            alpha: 0.30,
          )
        : AppColors.inputBorder;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black
                        .withValues(
                      alpha: 0.04,
                    ),
                    blurRadius: 12,
                    offset:
                        const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildTopSection(context),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Divider(
                height: 1,
                color: borderColor,
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              if (firstItem != null)
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _ProductImage(
                      imageUrl:
                          firstItem.imageUrl,
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
                            firstItem.name,
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: AppStyles
                                .headerText
                                .copyWith(
                              fontSize: 16,
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
                            order.items.length > 1
                                ? '${order.items.length} '
                                    '${AppLanguage.productssmall[AppConstant.language]} '
                                    '• $totalQuantity '
                                    '${AppLanguage.items[AppConstant.language]}'
                                : '${AppLanguage.quantityShort[AppConstant.language]}: '
                                    '${firstItem.quantity}',
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
                            '₹${firstItem.totalPrice.toStringAsFixed(2)}',
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
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              Divider(
                height: 1,
                color: borderColor,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLanguage.totalAmount[
                          AppConstant.language],
                      style: AppStyles
                          .subHeading
                          .copyWith(
                        fontSize: 15,
                        color: colorScheme
                            .onSurface
                            .withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: AppStyles
                        .headerText
                        .copyWith(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Row(
                children: [
                  Expanded(
                    child: _StatusChip(
                      title: order.orderStatus,
                      type:
                          _StatusType.order,
                    ),
                  ),
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  Expanded(
                    child: _StatusChip(
                      title:
                          order.paymentStatus,
                      type:
                          _StatusType.payment,
                    ),
                  ),
                ],
              ),
              if (order.razorpayPaymentId !=
                      null &&
                  order.razorpayPaymentId!
                      .trim()
                      .isNotEmpty) ...[
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(
                    AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme
                            .surfaceContainerHighest
                        : AppColors.background,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons
                            .receipt_long_outlined,
                        size: 18,
                        color: colorScheme
                            .onSurface
                            .withValues(
                          alpha: 0.60,
                        ),
                      ),
                      const SizedBox(
                        width: AppSpacing.sm,
                      ),
                      Expanded(
                        child: Text(
                          '${AppLanguage.transactionId[AppConstant.language]}: '
                          '${order.razorpayPaymentId}',
                          style: AppStyles
                              .subHeading
                              .copyWith(
                            fontSize: 12,
                            color: colorScheme
                                .onSurface
                                .withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                AppLanguage.orderId[
                    AppConstant.language],
                style:
                    AppStyles.subHeading.copyWith(
                  fontSize: 12,
                  color: colorScheme.onSurface
                      .withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '#${_shortOrderId(order.id)}',
                style:
                    AppStyles.headerText.copyWith(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: AppSpacing.sm,
        ),
        Text(
          _formatDate(
            order.createdAt,
          ),
          style:
              AppStyles.subHeading.copyWith(
            fontSize: 12,
            color: colorScheme.onSurface
                .withValues(
              alpha: 0.65,
            ),
          ),
        ),
      ],
    );
  }

  String _shortOrderId(
    String id,
  ) {
    if (id.length <= 10) {
      return id.toUpperCase();
    }

    return id
        .substring(0, 10)
        .toUpperCase();
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
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(14),
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

enum _StatusType {
  order,
  payment,
}

class _StatusChip
    extends StatelessWidget {
  final String title;
  final _StatusType type;

  const _StatusChip({
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedTitle =
        title.trim().toLowerCase();

    final color =
        _getColor(normalizedTitle);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            _getIcon(normalizedTitle),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _getLocalizedStatus(
                normalizedTitle,
              ),
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedStatus(
    String status,
  ) {
    switch (status) {
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

  Color _getColor(
    String status,
  ) {
    if (type == _StatusType.payment) {
      switch (status) {
        case 'paid':
          return Colors.green;

        case 'failed':
          return Colors.red;

        case 'pending':
        default:
          return Colors.orange;
      }
    }

    switch (status) {
      case 'confirmed':
      case 'delivered':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'shipped':
      case 'out for delivery':
        return Colors.blue;

      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getIcon(
    String status,
  ) {
    if (type == _StatusType.payment) {
      switch (status) {
        case 'paid':
          return Icons
              .check_circle_outline_rounded;

        case 'failed':
          return Icons.cancel_outlined;

        default:
          return Icons.schedule_rounded;
      }
    }

    switch (status) {
      case 'confirmed':
        return Icons
            .check_circle_outline_rounded;

      case 'shipped':
        return Icons
            .local_shipping_outlined;

      case 'delivered':
        return Icons
            .inventory_2_outlined;

      case 'cancelled':
        return Icons.cancel_outlined;

      default:
        return Icons.schedule_rounded;
    }
  }
}