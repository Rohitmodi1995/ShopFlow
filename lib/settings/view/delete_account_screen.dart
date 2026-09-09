import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_common_button.dart';
import '../../core/components/app_common_header.dart';
import '../../core/components/app_common_textfield.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validation.dart';
import '../viewmodel/delete_account_viewmodel.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState
    extends State<DeleteAccountScreen>
    with ValidationClass {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _reasonController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _reasonController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onDeleteAccount() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final viewModel =
        context.read<DeleteAccountViewModel>();

    final success = await viewModel.deleteAccount(
      currentPassword: viewModel.hasPasswordProvider
          ? _passwordController.text
          : null,
    );

    if (!mounted || !success) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
        context.watch<DeleteAccountViewModel>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? colorScheme.surface
        : AppColors.background;

    final borderColor = isDark
        ? colorScheme.onSurface.withValues(
            alpha: 0.12,
          )
        : AppColors.inputBorder;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppCommonHeader(
          title: AppLanguage.deleteAccount[
            AppConstant.language
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 700,
              ),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(
                            alpha:
                                isDark ? 0.08 : 0.06,
                          ),
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color:
                                Colors.red.withValues(
                              alpha: 0.20,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment:
                                  Alignment.center,
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.red.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),
                              child: const Icon(
                                Icons
                                    .warning_amber_rounded,
                                color: Colors.red,
                                size: 26,
                              ),
                            ),
                            const SizedBox(
                              width: AppSpacing.md,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    AppLanguage
                                            .deleteAccountWarningTitle[
                                        AppConstant
                                            .language],
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    AppLanguage
                                            .deleteAccountWarningSubtitle[
                                        AppConstant
                                            .language],
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
                      ),

                      const SizedBox(height: 28),

                      Text(
                        AppLanguage
                                .deleteAccountReasonTitle[
                            AppConstant.language],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        AppLanguage
                                .deleteAccountReasonSubtitle[
                            AppConstant.language],
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface
                              .withValues(
                            alpha: 0.60,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      CustomTextField(
                        controller:
                            _reasonController,
                        hintText: AppLanguage
                                .deleteAccountReasonHint[
                            AppConstant.language],
                        keyboardType:
                            TextInputType.multiline,
                        maxLength: 250,
                        minLines: 5,
                        maxLines: 7,
                        textInputAction:
                            TextInputAction.newline,
                        validator:
                            validateDeleteAccountReason,
                      ),

                      if (viewModel
                          .hasPasswordProvider) ...[
                        const SizedBox(height: 24),

                        Text(
                          AppLanguage.currentPassword[
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

                        const SizedBox(height: 6),

                        Text(
                          AppLanguage
                                  .enteryourpasswordText[
                              AppConstant.language],
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme
                                .onSurface
                                .withValues(
                              alpha: 0.60,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller:
                              _passwordController,
                          hintText:
                              AppLanguage.currentPassword[
                            AppConstant.language
                          ],
                          obscureText:
                              _obscurePassword,
                          textInputAction:
                              TextInputAction.done,
                          validator:
                              validatePassword,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons
                                      .visibility_off_outlined
                                  : Icons
                                      .visibility_outlined,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      Container(
                        padding:
                            const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: colorScheme.onSurface
                                  .withValues(
                                alpha: 0.60,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLanguage
                                        .deleteAccountPermanentWarning[
                                    AppConstant.language],
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: colorScheme
                                      .onSurface
                                      .withValues(
                                    alpha: 0.60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      AppCommonButton(
                        title:
                            AppLanguage.deleteAccount[
                          AppConstant.language
                        ],
                        icon:
                            Icons.delete_outline_rounded,
                        isLoading:
                            viewModel.isDeleting,
                        onPressed: viewModel.isDeleting
                            ? null
                            : _onDeleteAccount,
                      ),

                      if (viewModel.errorMessage !=
                              null &&
                          viewModel
                              .errorMessage!.isNotEmpty) ...[
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),
                        Text(
                          viewModel.errorMessage!,
                          textAlign:
                              TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}