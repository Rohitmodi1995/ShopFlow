import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/app_common_button.dart';
import '../../../core/components/auth_header.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_languages.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/applayout.dart';
import '../viewmodel/email_verification_viewmodel.dart';

class EmailVerificationScreen
    extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        AppLayout.getFormWidth(
                      constraints.maxWidth,
                    ),
                    minHeight:
                        constraints.maxHeight,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal:
                          AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        _buildBackButton(
                          context,
                          colorScheme,
                          isDark,
                        ),
                        AuthHeader(
                          title: AppLanguage
                                  .verifyYourEmailText[
                              AppConstant
                                  .language],
                          subtitle: AppLanguage
                                  .verificationLinkSentText[
                              AppConstant
                                  .language],
                        ),
                        const SizedBox(
                          height: AppSpacing.md,
                        ),
                        _buildEmail(
                          colorScheme,
                          isDark,
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildEmailIcon(
                          colorScheme,
                          isDark,
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildInfoCard(
                          colorScheme,
                          isDark,
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildOpenEmailButton(),
                        const SizedBox(
                          height: AppSpacing.md,
                        ),
                        _buildVerifiedButton(
                          context,
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildDivider(
                          colorScheme,
                          isDark,
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildResendButton(
                          context,
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                        _buildChangeEmail(
                          context,
                          colorScheme,
                          isDark,
                        ),
                        const SizedBox(
                          height: AppSpacing.xl,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackButton(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final iconColor = isDark
        ? colorScheme.onSurface
        : AppColors.textSecondary;

    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildEmail(
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final emailColor = isDark
        ? colorScheme.onSurface
        : AppColors.textPrimary;

    final subtitleColor = isDark
        ? colorScheme.onSurfaceVariant
        : AppColors.textSecondary;

    return Column(
      children: [
        Text(
          email,
          style:
              AppStyles.headerText.copyWith(
            color: emailColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: AppSpacing.xs,
        ),
        Text(
          AppLanguage.checkInboxText[
              AppConstant.language],
          style:
              AppStyles.subHeading.copyWith(
            color: subtitleColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailIcon(
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final backgroundColor = isDark
        ? colorScheme.primaryContainer
            .withValues(alpha: 0.35)
        : AppColors.lightPurple;

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.mark_email_unread_outlined,
        color: AppColors.primary,
        size: 55,
      ),
    );
  }

  Widget _buildInfoCard(
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final backgroundColor = isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.lightPurple;

    final borderColor = isDark
        ? colorScheme.outline.withValues(
            alpha: 0.60,
          )
        : AppColors.inputBorder;

    final titleColor = isDark
        ? colorScheme.onSurface
        : AppColors.textPrimary;

    final subtitleColor = isDark
        ? colorScheme.onSurfaceVariant
        : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 24,
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
                  AppLanguage
                          .didntReceiveEmailText[
                      AppConstant.language],
                  style: AppStyles.headerText
                      .copyWith(
                    color: titleColor,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  AppLanguage.checkSpamText[
                      AppConstant.language],
                  style: AppStyles.subHeading
                      .copyWith(
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenEmailButton() {
    return AppCommonButton(
      title:
          AppLanguage.openEmailAppText[
              AppConstant.language],
      onPressed: () {
      
      },
    );
  }

  Widget _buildVerifiedButton(
    BuildContext context,
  ) {
    return Selector<
        EmailVerificationViewModel,
        bool>(
      selector: (_, viewModel) =>
          viewModel.isLoading,
      builder: (
        context,
        isLoading,
        child,
      ) {
        return AppCommonButton(
          isLoading: isLoading,
          title:
              AppLanguage.iveVerifiedText[
                  AppConstant.language],
          onPressed: isLoading
              ? null
              : () async {
                  final viewModel = context
                      .read<
                          EmailVerificationViewModel>();

                  final success =
                      await viewModel
                          .checkVerification();

                  if (!context.mounted) {
                    return;
                  }

                  if (success) {
                    Navigator
                        .pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );

                    return;
                  }

                  final message =
                      viewModel.errorMessage ??
                          AppLanguage
                                  .emailNotVerifiedText[
                              AppConstant
                                  .language];

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        message,
                      ),
                    ),
                  );
                },
        );
      },
    );
  }

  Widget _buildDivider(
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final dividerColor = isDark
        ? colorScheme.outline.withValues(
            alpha: 0.50,
          )
        : AppColors.inputBorder;

    final textColor = isDark
        ? colorScheme.onSurface.withValues(
            alpha: 0.70,
          )
        : AppColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Text(
            AppLanguage.orText[
                AppConstant.language],
            style: AppStyles.orText.copyWith(
              color: textColor,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildResendButton(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () async {
        final viewModel = context
            .read<
                EmailVerificationViewModel>();

        final success =
            await viewModel.resendEmail();

        if (!context.mounted) {
          return;
        }

        final message = success
            ? AppLanguage
                    .verificationEmailSentText[
                AppConstant.language]
            : viewModel.errorMessage ??
                AppLanguage
                        .unableToSendVerificationEmailText[
                    AppConstant.language];

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      },
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.refresh_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Text(
            AppLanguage
                    .resendVerificationEmailText[
                AppConstant.language],
            style:
                AppStyles.forgotPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildChangeEmail(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final textColor = isDark
        ? colorScheme.onSurfaceVariant
        : AppColors.textSecondary;

    return Column(
      children: [
        Text(
          AppLanguage
                  .wrongEmailAddressText[
              AppConstant.language],
          style:
              AppStyles.subHeading.copyWith(
            color: textColor,
          ),
        ),
        const SizedBox(
          height: AppSpacing.xs,
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            AppLanguage
                    .changeEmailAddressText[
                AppConstant.language],
            style:
                AppStyles.forgotPassword,
          ),
        ),
      ],
    );
  }
}