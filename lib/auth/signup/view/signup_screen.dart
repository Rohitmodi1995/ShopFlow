import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopflow/core/utils/validation.dart';

import '../../../core/components/app_common_button.dart';
import '../../../core/components/app_common_textfield.dart';
import '../../../core/components/app_social_button.dart';
import '../../../core/components/auth_header.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_languages.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/applayout.dart';
import '../../google/viewmodel/google_auth_viewmodel.dart';
import '../viewmodel/signup_viewmodel.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
  });

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with ValidationClass {
  final TextEditingController fullnameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController
      confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _buildHeader(),
                          _buildFormBody(
                            colorScheme,
                            isDark,
                          ),
                          const Spacer(),
                          _buildFooter(
                            colorScheme,
                            isDark,
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

  Widget _buildHeader() {
    return AuthHeader(
      title: AppLanguage.createaccountText[
          AppConstant.language],
      subtitle:
          AppLanguage.joinusandstartshoppingText[
              AppConstant.language],
    );
  }

  Widget _buildFormBody(
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final labelColor = isDark
        ? colorScheme.onSurface
        : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              AppLanguage.fullnameText[
                  AppConstant.language],
              style:
                  AppStyles.headerText.copyWith(
                color: labelColor,
              ),
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            _fullnameTextField(),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              AppLanguage.emailadressText[
                  AppConstant.language],
              style:
                  AppStyles.headerText.copyWith(
                color: labelColor,
              ),
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            _emailTextField(),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              AppLanguage.passwordText[
                  AppConstant.language],
              style:
                  AppStyles.headerText.copyWith(
                color: labelColor,
              ),
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            _passwordTextField(),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              AppLanguage.confirmpasswordText[
                  AppConstant.language],
              style:
                  AppStyles.headerText.copyWith(
                color: labelColor,
              ),
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            _confirmPasswordTextField(),
            const SizedBox(
              height: AppSpacing.xl,
            ),
            _signupButton(),
            const SizedBox(
              height: AppSpacing.xl,
            ),
            _orDivider(
              colorScheme,
              isDark,
            ),
            const SizedBox(
              height: AppSpacing.xl,
            ),
            _googleLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final textColor = isDark
        ? colorScheme.onSurface
        : AppColors.blackColor;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            AppLanguage
                    .alreadyhaveandaccountText[
                AppConstant.language],
            style: TextStyle(
              color: textColor,
            ),
          ),
          const SizedBox(
            width: AppSpacing.xs,
          ),
          GestureDetector(
            onTap: () {
              _dismissKeyboard();

              Navigator.pushNamed(
                context,
                AppRoutes.login,
              );
            },
            child: Text(
              AppLanguage.loginText[
                  AppConstant.language],
              style: AppStyles
                  .footerforloginandsignupText
                  .copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fullnameTextField() {
    return CustomTextField(
      controller: fullnameController,
      hintText:
          AppLanguage.enterfullnameText[
              AppConstant.language],
      keyboardType: TextInputType.name,
      maxLength:
          AppConstant.fullnameLength,
      textInputAction:
          TextInputAction.next,
      prefixIcon: const Icon(
        Icons.person_outline,
        color: AppColors.primary,
        size: 22,
      ),
      validator: validateName,
    );
  }

  Widget _emailTextField() {
    return CustomTextField(
      controller: emailController,
      hintText:
          AppLanguage.enteryouremailText[
              AppConstant.language],
      keyboardType:
          TextInputType.emailAddress,
      maxLength:
          AppConstant.emailAddressLenght,
      textInputAction:
          TextInputAction.next,
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: AppColors.primary,
        size: 22,
      ),
      validator: validateEmail,
    );
  }

  Widget _passwordTextField() {
    return Selector<SignupViewModel, bool>(
      selector: (_, viewModel) =>
          viewModel.isPasswordVisible,
      builder: (
        context,
        isPasswordVisible,
        child,
      ) {
        return CustomTextField(
          controller: passwordController,
          hintText: AppLanguage
                  .enteryourpasswordText[
              AppConstant.language],
          keyboardType:
              TextInputType.visiblePassword,
          maxLength:
              AppConstant.passwordLength,
          textInputAction:
              TextInputAction.next,
          obscureText:
              !isPasswordVisible,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppColors.primary,
            size: 22,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              context
                  .read<SignupViewModel>()
                  .setPassword();
            },
            icon: Icon(
              isPasswordVisible
                  ? Icons
                      .visibility_outlined
                  : Icons
                      .visibility_off_outlined,
              color: AppColors.primary,
              size: 25,
            ),
          ),
          validator: validatePassword,
        );
      },
    );
  }

  Widget _confirmPasswordTextField() {
    return Selector<SignupViewModel, bool>(
      selector: (_, viewModel) =>
          viewModel
              .isConfirmPasswordVisible,
      builder: (
        context,
        isConfirmPasswordVisible,
        child,
      ) {
        return CustomTextField(
          controller:
              confirmPasswordController,
          hintText: AppLanguage
                  .enterconfirmpasswordText[
              AppConstant.language],
          keyboardType:
              TextInputType.visiblePassword,
          maxLength:
              AppConstant.passwordLength,
          textInputAction:
              TextInputAction.done,
          obscureText:
              !isConfirmPasswordVisible,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppColors.primary,
            size: 22,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              context
                  .read<SignupViewModel>()
                  .setConfirmPassword();
            },
            icon: Icon(
              isConfirmPasswordVisible
                  ? Icons
                      .visibility_outlined
                  : Icons
                      .visibility_off_outlined,
              color: AppColors.primary,
              size: 25,
            ),
          ),
          validator: (value) {
            return validateConfirmPassword(
              passwordController.text,
              value,
            );
          },
        );
      },
    );
  }

  Widget _signupButton() {
    return Selector<SignupViewModel, bool>(
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
              AppLanguage.signupButtonText[
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
                      .read<SignupViewModel>();

                  final user =
                      await viewModel.signup(
                    name: fullnameController
                        .text,
                    email:
                        emailController.text,
                    password:
                        passwordController
                            .text,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  if (user != null) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes
                          .emailVerification,
                      arguments:
                          emailController
                              .text
                              .trim(),
                    );

                    return;
                  }

                  final message =
                      viewModel.errorMessage;

                  if (message == null ||
                      message.isEmpty) {
                    return;
                  }

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

  Widget _orDivider(
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

  Widget _googleLoginButton() {
    return Selector<GoogleAuthViewModel, bool>(
      selector: (_, viewModel) =>
          viewModel.isLoading,
      builder: (
        context,
        isLoading,
        child,
      ) {
        return AppSocialButton(
          title: AppLanguage
                  .continuewithgoogleText[
              AppConstant.language],
          iconPath: AppImages.googleIcon,
          isLoading: isLoading,
          onPressed: isLoading
              ? null
              : () async {
                  _dismissKeyboard();

                  final viewModel = context
                      .read<GoogleAuthViewModel>();

                  final result =
                      await viewModel
                          .signInWithGoogle();

                  if (!context.mounted) {
                    return;
                  }

                  switch (result) {
                    case GoogleAuthResult.success:
                      Navigator
                          .pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                      break;

                    case GoogleAuthResult.cancelled:
                      break;

                    case GoogleAuthResult.failed:
                      final message =
                          viewModel.errorMessage;

                      if (message == null ||
                          message.isEmpty) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            message,
                          ),
                        ),
                      );
                      break;
                  }
                },
        );
      },
    );
  }
}