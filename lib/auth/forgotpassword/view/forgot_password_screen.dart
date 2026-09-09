import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/app_common_button.dart';
import '../../../core/components/app_common_textfield.dart';
import '../../../core/components/auth_header.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_languages.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/applayout.dart';
import '../../../core/utils/validation.dart';
import '../viewmodel/forgot_password_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen>
    with ValidationClass {
  final TextEditingController emailController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .onDrag,
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
                            colorScheme,
                            isDark,
                          ),
                          AuthHeader(
                            title: AppLanguage
                                    .forgotPasswordTitle[
                                AppConstant
                                    .language],
                            subtitle: AppLanguage
                                    .forgotPasswordSubtitle[
                                AppConstant
                                    .language],
                          ),
                          const SizedBox(
                            height:
                                AppSpacing.xl,
                          ),
                          _buildResetIcon(
                            colorScheme,
                            isDark,
                          ),
                          const SizedBox(
                            height:
                                AppSpacing.xl,
                          ),
                          _buildForm(
                            colorScheme,
                            isDark,
                          ),
                          const SizedBox(
                            height:
                                AppSpacing.xl,
                          ),
                          _buildSendButton(),
                          const SizedBox(
                            height:
                                AppSpacing.xl,
                          ),
                          _buildBackToLogin(),
                          const SizedBox(
                            height:
                                AppSpacing.lg,
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
      ),
    );
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus
        ?.unfocus();
  }

  Widget _buildBackButton(
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
          _dismissKeyboard();
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

  Widget _buildResetIcon(
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final iconBackgroundColor = isDark
        ? colorScheme.primaryContainer
            .withValues(alpha: 0.35)
        : AppColors.lightPurple;

    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lock_reset_rounded,
        color: AppColors.primary,
        size: 50,
      ),
    );
  }

  Widget _buildForm(
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final labelColor = isDark
        ? colorScheme.onSurface
        : AppColors.textPrimary;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            AppLanguage.emailadressText[
                AppConstant.language],
            style:
                AppStyles.headerText.copyWith(
              color: labelColor,
            ),
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          CustomTextField(
            controller: emailController,
            hintText:
                AppLanguage.enteryouremailText[
                    AppConstant.language],
            keyboardType:
                TextInputType.emailAddress,
            maxLength:
                AppConstant.emailAddressLenght,
            textInputAction:
                TextInputAction.done,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.primary,
              size: 22,
            ),
            validator: validateEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Selector<
        ForgotPasswordViewModel,
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
              AppLanguage.sendResetLinkText[
                  AppConstant.language],
          onPressed: isLoading
              ? null
              : () async {
                  if (!_formKey
                      .currentState!
                      .validate()) {
                    return;
                  }

                  _dismissKeyboard();

                  final viewModel = context
                      .read<
                          ForgotPasswordViewModel>();

                  final success =
                      await viewModel
                          .sendPasswordResetEmail(
                    email:
                        emailController.text,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  if (success) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLanguage
                                  .passwordResetSuccessText[
                              AppConstant
                                  .language],
                        ),
                      ),
                    );

                    Navigator
                        .pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );

                    return;
                  }

                  final message =
                      viewModel.errorMessage ??
                          AppLanguage
                                  .unableToSendResetLinkText[
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

  Widget _buildBackToLogin() {
    return GestureDetector(
      onTap: () {
        _dismissKeyboard();

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      },
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(
            width: AppSpacing.xs,
          ),
          Text(
            AppLanguage.backToLoginText[
                AppConstant.language],
            style:
                AppStyles.forgotPassword,
          ),
        ],
      ),
    );
  }
}