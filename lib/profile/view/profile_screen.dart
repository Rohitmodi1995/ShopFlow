import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_common_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_styles.dart';
import '../viewmodel/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colorScheme.surface : AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: isDark ? colorScheme.onSurface : AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          AppLanguage.profile[AppConstant.language],
          style: AppStyles.headerText.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? colorScheme.onSurface : AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (viewModel.errorMessage != null && viewModel.profile == null) {
            return _ProfileErrorView(
              message: viewModel.errorMessage!,
              onRetry: viewModel.loadProfile,
            );
          }

          final profile = viewModel.profile;

          if (profile == null) {
            return Center(
              child: Text(
                AppLanguage.profileNotFound[AppConstant.language],
                style: AppStyles.subHeading.copyWith(
                  color: isDark ? colorScheme.onSurface : AppColors.textPrimary,
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: viewModel.loadProfile,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          const Center(
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            profile.name,
                            textAlign: TextAlign.center,
                            style: AppStyles.headerText.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? colorScheme.onSurface
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile.email,
                            textAlign: TextAlign.center,
                            style: AppStyles.subHeading.copyWith(
                              fontSize: 14,
                              color: isDark
                                  ? colorScheme.onSurface.withValues(
                                      alpha: 0.65,
                                    )
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: profile.isEmailVerified
                                    ? Colors.green.withValues(alpha: 0.10)
                                    : Colors.orange.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    profile.isEmailVerified
                                        ? Icons.verified_rounded
                                        : Icons.info_outline_rounded,
                                    size: 18,
                                    color: profile.isEmailVerified
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    profile.isEmailVerified
                                        ? AppLanguage.emailVerified[AppConstant
                                              .language]
                                        : AppLanguage
                                              .emailNotVerified[AppConstant
                                              .language],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: profile.isEmailVerified
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _ProfileInfoCard(
                            icon: Icons.person_outline,
                            title: AppLanguage.name[AppConstant.language],
                            value: profile.name,
                          ),
                          const SizedBox(height: 12),
                          _ProfileInfoCard(
                            icon: Icons.email_outlined,
                            title: AppLanguage.email[AppConstant.language],
                            value: profile.email,
                          ),
                          const SizedBox(height: 12),
                          _ProfileInfoCard(
                            icon: Icons.login_rounded,
                            title: AppLanguage.loginType[AppConstant.language],
                            value: profile.loginType,
                          ),
                          const SizedBox(height: 28),
                          AppCommonButton(
                            title:
                                AppLanguage.editProfile[AppConstant.language],
                            icon: Icons.edit_outlined,
                            onPressed: () async {
                              final profileViewModel = viewModel;

                              await Navigator.pushNamed(
                                context,
                                AppRoutes.editProfile,
                              );

                              if (!mounted) {
                                return;
                              }

                              await profileViewModel.loadProfile();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.background;

    final borderColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.35)
        : AppColors.inputBorder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.subHeading.copyWith(
                    fontSize: 12,
                    color: isDark
                        ? colorScheme.onSurface.withValues(alpha: 0.60)
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppStyles.headerText.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? colorScheme.onSurface
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.subHeading.copyWith(
                color: isDark ? colorScheme.onSurface : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            AppCommonButton(
              title: AppLanguage.retry[AppConstant.language],
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
