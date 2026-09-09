import 'package:flutter/material.dart';

import '../../core/components/app_common_header.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({
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
        : AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppCommonHeader(
        title: AppLanguage.termsConditions[
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _TermsSection(
                    title:
                        AppLanguage.acceptanceOfTerms[
                      AppConstant.language
                    ],
                    description: AppLanguage
                        .acceptanceOfTermsDescription[
                      AppConstant.language
                    ],
                  ),
                  _TermsSection(
                    title:
                        AppLanguage.userAccountTerms[
                      AppConstant.language
                    ],
                    description: AppLanguage
                        .userAccountTermsDescription[
                      AppConstant.language
                    ],
                  ),
                  _TermsSection(
                    title:
                        AppLanguage.productsAndOrders[
                      AppConstant.language
                    ],
                    description: AppLanguage
                        .productsAndOrdersDescription[
                      AppConstant.language
                    ],
                  ),
                  _TermsSection(
                    title:
                        AppLanguage.termsPayments[
                      AppConstant.language
                    ],
                    description: AppLanguage
                        .termsPaymentsDescription[
                      AppConstant.language
                    ],
                  ),
                  _TermsSection(
                    title: AppLanguage
                        .deliveryInformation[
                      AppConstant.language
                    ],
                    description: AppLanguage
                        .deliveryInformationDescription[
                      AppConstant.language
                    ],
                  ),
                  _TermsSection(
                    title: AppLanguage
                        .userResponsibilities[
                      AppConstant.language
                    ],
                    description: AppLanguage
                        .userResponsibilitiesDescription[
                      AppConstant.language
                    ],
                  ),
                  _TermsSection(
                    title: AppLanguage
                        .termsThirdPartyServices[
                      AppConstant.language
                    ],
                    description: AppLanguage
                        .termsThirdPartyServicesDescription[
                      AppConstant.language
                    ],
                  ),
                  _TermsSection(
                    title:
                        AppLanguage.serviceAvailability[
                      AppConstant.language
                    ],
                    description: AppLanguage
                        .serviceAvailabilityDescription[
                      AppConstant.language
                    ],
                  ),
                  _TermsSection(
                    title: AppLanguage.changesToTerms[
                      AppConstant.language
                    ],
                    description: AppLanguage
                        .changesToTermsDescription[
                      AppConstant.language
                    ],
                  ),
                  _TermsSection(
                    title: AppLanguage.termsContact[
                      AppConstant.language
                    ],
                    description: AppLanguage
                        .termsContactDescription[
                      AppConstant.language
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String description;

  const _TermsSection({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: colorScheme.onSurface.withValues(
                alpha: 0.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}