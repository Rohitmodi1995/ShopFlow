import 'package:flutter/material.dart';
import '../../core/components/app_common_header.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colorScheme.surface : AppColors.whiteColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppCommonHeader(title: AppLanguage.aboutUs[AppConstant.language]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection(
                    context: context,
                    icon: Icons.shopping_bag_outlined,
                    title: AppLanguage.aboutShopFlow[AppConstant.language],
                    description: AppLanguage
                        .aboutShopFlowDescription[AppConstant.language],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildSection(
                    context: context,
                    icon: Icons.track_changes_outlined,
                    title: AppLanguage.ourMission[AppConstant.language],
                    description:
                        AppLanguage.ourMissionDescription[AppConstant.language],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildSection(
                    context: context,
                    icon: Icons.auto_awesome_outlined,
                    title: AppLanguage.whatWeOffer[AppConstant.language],
                    description: AppLanguage
                        .whatWeOfferDescription[AppConstant.language],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildVersionSection(context),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : AppColors.lightPurple,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 46,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppLanguage.appName[AppConstant.language],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppLanguage.shopFlowTagline[AppConstant.language],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.18)
        : AppColors.inputBorder;

    final iconBackgroundColor = isDark
        ? colorScheme.primary.withValues(alpha: 0.12)
        : AppColors.lightPurple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
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
                const SizedBox(height: AppSpacing.sm),
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
          ),
        ],
      ),
    );
  }

  Widget _buildVersionSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final secondaryColor = colorScheme.onSurface.withValues(alpha: 0.60);

    return Center(
      child: Column(
        children: [
          Text(
            '${AppLanguage.version[AppConstant.language]} 1.0.0',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '© 2026 '
            '${AppLanguage.appName[AppConstant.language]}. '
            '${AppLanguage.allRightsReserved[AppConstant.language]}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: secondaryColor),
          ),
        ],
      ),
    );
  }
}
