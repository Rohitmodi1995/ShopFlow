import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopflow/core/constants/app_colors.dart';
import 'package:shopflow/core/constants/app_constants.dart';
import 'package:shopflow/core/constants/app_languages.dart';
import 'package:shopflow/core/utils/validation.dart';

import '../../../core/components/app_common_button.dart';
import '../../../core/components/app_common_textfield.dart';
import '../../../core/components/app_social_button.dart';
import '../../../core/components/auth_header.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/applayout.dart';
import '../../google/viewmodel/google_auth_viewmodel.dart';
import '../viewmodel/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with ValidationClass {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
      title: AppLanguage.welcomebackText[
          AppConstant.language],
      subtitle:
          AppLanguage.signintocontinueText[
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
        horizontal: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
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
              height: AppSpacing.md,
            ),
            _forgotPasswordText(),
            const SizedBox(
              height: AppSpacing.xl,
            ),
            _loginButton(),
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
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            AppLanguage
                    .donthavaanaccountText[
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
                AppRoutes.signup,
              );
            },
            child: Text(
              AppLanguage.signupText[
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
    return Selector<LoginViewModel, bool>(
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
              TextInputAction.done,
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
                  .read<LoginViewModel>()
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

  Widget _forgotPasswordText() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          _dismissKeyboard();

          Navigator.pushNamed(
            context,
            AppRoutes.forgotPassword,
          );
        },
        child: Text(
          AppLanguage.forgotPasswordText[
              AppConstant.language],
          style: AppStyles.forgotPassword,
        ),
      ),
    );
  }

  Widget _loginButton() {
    return Selector<LoginViewModel, bool>(
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
              AppLanguage.loginButtonText[
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
                      .read<LoginViewModel>();

                  final result =
                      await viewModel.login(
                    email:
                        emailController.text,
                    password:
                        passwordController
                            .text,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  switch (result) {
                    case LoginResult.success:
                      Navigator
                          .pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                      break;

                    case LoginResult
                          .emailNotVerified:
                      Navigator.pushNamed(
                        context,
                        AppRoutes
                            .emailVerification,
                        arguments:
                            emailController
                                .text
                                .trim(),
                      );
                      break;

                    case LoginResult.failed:
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