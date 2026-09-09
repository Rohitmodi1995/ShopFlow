import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_common_button.dart';
import '../../core/components/app_common_header.dart';
import '../../core/components/app_common_textfield.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/utils/validation.dart';
import '../viewmodel/change_password_viewmodel.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with ValidationClass {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _changePassword(ChangePasswordViewModel viewModel) async {
    if (viewModel.isLoading) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();

    final errorMessage = await viewModel.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      _showMessage(errorMessage);
      return;
    }

    _showMessage(AppLanguage.passwordChangedSuccessfully[AppConstant.language]);

    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colorScheme.surface : AppColors.background;

    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: Consumer<ChangePasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppCommonHeader(
              title: AppLanguage.changePassword[AppConstant.language],
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          const Icon(
                            Icons.lock_reset_rounded,
                            size: 70,
                            color: AppColors.primary,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            AppLanguage.updatePassword[AppConstant.language],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            AppLanguage.changePasswordSubtitle[AppConstant
                                .language],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.60,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          CustomTextField(
                            controller: _currentPasswordController,
                            hintText: AppLanguage
                                .currentPassword[AppConstant.language],
                            obscureText: !_showCurrentPassword,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showCurrentPassword = !_showCurrentPassword;
                                });
                              },
                              icon: Icon(
                                _showCurrentPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            validator: validatePassword,
                          ),

                          const SizedBox(height: 18),

                          CustomTextField(
                            controller: _newPasswordController,
                            hintText:
                                AppLanguage.newPassword[AppConstant.language],
                            obscureText: !_showNewPassword,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showNewPassword = !_showNewPassword;
                                });
                              },
                              icon: Icon(
                                _showNewPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            validator: (value) {
                              return validateNewPassword(
                                _currentPasswordController.text,
                                value,
                              );
                            },
                          ),

                          const SizedBox(height: 18),

                          CustomTextField(
                            controller: _confirmPasswordController,
                            hintText: AppLanguage
                                .confirmpasswordText[AppConstant.language],
                            obscureText: !_showConfirmPassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showConfirmPassword = !_showConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _showConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            validator: (value) {
                              return validateConfirmPassword(
                                _newPasswordController.text,
                                value,
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          AppCommonButton(
                            title: AppLanguage
                                .changePassword[AppConstant.language],
                            icon: Icons.lock_reset_rounded,
                            isLoading: viewModel.isLoading,
                            onPressed: viewModel.isLoading
                                ? null
                                : () {
                                    _changePassword(viewModel);
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
