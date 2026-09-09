import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_styles.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final VoidCallback onContinue;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.onContinue,
  });

  @override
  State<OrderSuccessScreen> createState() =>
      _OrderSuccessScreenState();
}

class _OrderSuccessScreenState
    extends State<OrderSuccessScreen> {
  Timer? _timer;
  bool _isContinuing = false;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 3),
      _continueToOrders,
    );
  }

  void _continueToOrders() {
    if (!mounted || _isContinuing) {
      return;
    }

    _isContinuing = true;
    widget.onContinue();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isDark
        ? colorScheme.outline.withValues(
            alpha: 0.30,
          )
        : AppColors.inputBorder;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 650,
              ),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withValues(
                          alpha: 0.10,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons
                            .check_circle_rounded,
                        size: 80,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.lg,
                    ),
                    Text(
                      AppLanguage
                              .paymentSuccessful[
                          AppConstant.language],
                      textAlign:
                          TextAlign.center,
                      style: AppStyles.headerText
                          .copyWith(
                        fontSize: 26,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    Text(
                      AppLanguage
                              .thankYouForShopping[
                          AppConstant.language],
                      textAlign:
                          TextAlign.center,
                      style: AppStyles.subHeading
                          .copyWith(
                        fontSize: 16,
                        color: colorScheme
                            .onSurface
                            .withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context: context,
                            title: AppLanguage
                                    .orderId[
                                AppConstant
                                    .language],
                            value: widget.orderId,
                          ),
                          const SizedBox(
                            height: AppSpacing.sm,
                          ),
                          Divider(
                            color: borderColor,
                          ),
                          const SizedBox(
                            height: AppSpacing.sm,
                          ),
                          _buildInfoRow(
                            context: context,
                            title: AppLanguage
                                    .amountPaid[
                                AppConstant
                                    .language],
                            value:
                                '₹${widget.amount.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.lg,
                    ),
                    Text(
                      AppLanguage
                              .redirectingToMyOrders[
                          AppConstant.language],
                      textAlign:
                          TextAlign.center,
                      style: AppStyles.subHeading
                          .copyWith(
                        fontSize: 14,
                        color: colorScheme
                            .onSurface
                            .withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.lg,
                    ),
                    TextButton(
                      onPressed:
                          _continueToOrders,
                      child: Text(
                        AppLanguage.viewMyOrders[
                            AppConstant.language],
                        style: AppStyles
                            .headerText
                            .copyWith(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String title,
    required String value,
  }) {
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
              fontWeight:
                  FontWeight.w600,
              color:
                  colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}