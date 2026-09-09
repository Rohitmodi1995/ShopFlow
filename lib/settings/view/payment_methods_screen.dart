import 'package:flutter/material.dart';

import '../../core/components/app_common_header.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppCommonHeader(
        title: AppLanguage.paymentMethods[
          AppConstant.language
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLanguage
                            .availablePaymentOptions[
                      AppConstant.language
                    ],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.xs,
                  ),
                  Text(
                    AppLanguage
                            .choosePreferredPaymentMethod[
                      AppConstant.language
                    ],
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: colorScheme
                          .onSurface
                          .withValues(
                        alpha: 0.65,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons
                        .account_balance_wallet_outlined,
                    title: AppLanguage.upi[
                      AppConstant.language
                    ],
                    subtitle: AppLanguage
                            .upiPaymentDescription[
                      AppConstant.language
                    ],
                    trailingText:
                        AppLanguage.available[
                      AppConstant.language
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  _buildPaymentMethod(
                    context: context,
                    icon:
                        Icons.credit_card_outlined,
                    title: AppLanguage
                            .creditDebitCard[
                      AppConstant.language
                    ],
                    subtitle: AppLanguage
                            .cardPaymentDescription[
                      AppConstant.language
                    ],
                    trailingText:
                        AppLanguage.available[
                      AppConstant.language
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons
                        .account_balance_outlined,
                    title:
                        AppLanguage.netBanking[
                      AppConstant.language
                    ],
                    subtitle: AppLanguage
                            .netBankingDescription[
                      AppConstant.language
                    ],
                    trailingText:
                        AppLanguage.available[
                      AppConstant.language
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons
                        .currency_rupee_outlined,
                    title: AppLanguage.razorpay[
                      AppConstant.language
                    ],
                    subtitle: AppLanguage
                            .razorpayDescription[
                      AppConstant.language
                    ],
                    trailingText:
                        AppLanguage.secure[
                      AppConstant.language
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  _buildSecurityCard(
                    context,
                  ),
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  _buildInfoCard(
                    context,
                  ),
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailingText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isDark
        ? colorScheme.onSurface.withValues(
            alpha: 0.18,
          )
        : AppColors.inputBorder;

    final accentBackground = isDark
        ? colorScheme.primary.withValues(
            alpha: 0.12,
          )
        : AppColors.lightPurple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        colorScheme.onSurface,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: colorScheme
                        .onSurface
                        .withValues(
                      alpha: 0.65,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: accentBackground,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              trailingText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? colorScheme.primary.withValues(
            alpha: 0.12,
          )
        : AppColors.lightPurple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline,
            color: colorScheme.primary,
            size: 26,
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.securePayments[
                    AppConstant.language
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        colorScheme.onSurface,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  AppLanguage
                          .securePaymentsDescription[
                    AppConstant.language
                  ],
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: colorScheme
                        .onSurface
                        .withValues(
                      alpha: 0.65,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isDark
        ? colorScheme.onSurface.withValues(
            alpha: 0.18,
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
            BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child: Text(
              AppLanguage.paymentMethodInfo[
                AppConstant.language
              ],
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
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
    );
  }
}