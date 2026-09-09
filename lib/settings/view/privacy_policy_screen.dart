import 'package:flutter/material.dart';

import '../../core/components/app_common_header.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colorScheme.surface : AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppCommonHeader(
        title: AppLanguage.privacyPolicy[AppConstant.language],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PolicySection(
                    title:
                        AppLanguage.informationWeCollect[AppConstant.language],
                    description: AppLanguage
                        .informationWeCollectDescription[AppConstant.language],
                  ),
                  _PolicySection(
                    title: AppLanguage
                        .howWeUseYourInformation[AppConstant.language],
                    description:
                        AppLanguage
                            .howWeUseYourInformationDescription[AppConstant
                            .language],
                  ),
                  _PolicySection(
                    title: AppLanguage.payments[AppConstant.language],
                    description:
                        AppLanguage.paymentsDescription[AppConstant.language],
                  ),
                  _PolicySection(
                    title: AppLanguage.dataSecurity[AppConstant.language],
                    description: AppLanguage
                        .dataSecurityDescription[AppConstant.language],
                  ),
                  _PolicySection(
                    title: AppLanguage.thirdPartyServices[AppConstant.language],
                    description: AppLanguage
                        .thirdPartyServicesDescription[AppConstant.language],
                  ),
                  _PolicySection(
                    title: AppLanguage.accountInformation[AppConstant.language],
                    description: AppLanguage
                        .accountInformationDescription[AppConstant.language],
                  ),
                  _PolicySection(
                    title:
                        AppLanguage.changesToThisPolicy[AppConstant.language],
                    description: AppLanguage
                        .changesToThisPolicyDescription[AppConstant.language],
                  ),
                  _PolicySection(
                    title: AppLanguage.contactUs[AppConstant.language],
                    description: AppLanguage
                        .contactUsPrivacyDescription[AppConstant.language],
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

class _PolicySection extends StatelessWidget {
  final String title;
  final String description;

  const _PolicySection({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
