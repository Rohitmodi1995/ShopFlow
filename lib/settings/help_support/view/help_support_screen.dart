import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/app_common_button.dart';
import '../../../core/components/app_common_header.dart';
import '../../../core/components/app_common_textfield.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_languages.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validation.dart';
import '../viewmodel/help_support_viewmodel.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({
    super.key,
  });

  @override
  State<HelpSupportScreen> createState() =>
      _HelpSupportScreenState();
}

class _HelpSupportScreenState
    extends State<HelpSupportScreen>
    with ValidationClass {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _messageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    final user =
        FirebaseAuth.instance.currentUser;

    _nameController.text =
        user?.displayName?.trim() ?? '';

    _emailController.text =
        user?.email?.trim() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();

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
        : AppColors.whiteColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppCommonHeader(
        title: AppLanguage.helpSupport[
          AppConstant.language
        ],
      ),
      body: SafeArea(
        child: Consumer<HelpSupportViewModel>(
          builder: (
            context,
            viewModel,
            child,
          ) {
            return Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 800,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,
                  padding:
                      const EdgeInsets.all(
                    AppSpacing.md,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        _buildHeader(
                          context,
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.lg,
                        ),
                        Text(
                          AppLanguage
                                  .submitSupportRequest[
                            AppConstant.language
                          ],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w700,
                            color: colorScheme
                                .onSurface,
                          ),
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.xs,
                        ),
                        Text(
                          AppLanguage
                                  .supportRequestDescription[
                            AppConstant.language
                          ],
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: colorScheme
                                .onSurface
                                .withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.lg,
                        ),
                        _buildLabel(
                          context,
                          AppLanguage
                                  .fullnameText[
                            AppConstant.language
                          ],
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.xs,
                        ),
                        CustomTextField(
                          controller:
                              _nameController,
                          hintText: AppLanguage
                                  .enterfullnameText[
                            AppConstant.language
                          ],
                          validator:
                              validateName,
                          textInputAction:
                              TextInputAction
                                  .next,
                          readOnly: true,
                          prefixIcon:
                              const Icon(
                            Icons
                                .person_outline,
                          ),
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.md,
                        ),
                        _buildLabel(
                          context,
                          AppLanguage
                                  .emailadressText[
                            AppConstant.language
                          ],
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.xs,
                        ),
                        CustomTextField(
                          controller:
                              _emailController,
                          hintText: AppLanguage
                                  .enteryouremailText[
                            AppConstant.language
                          ],
                          keyboardType:
                              TextInputType
                                  .emailAddress,
                          validator:
                              validateEmail,
                          textInputAction:
                              TextInputAction
                                  .next,
                          readOnly: true,
                          prefixIcon:
                              const Icon(
                            Icons
                                .email_outlined,
                          ),
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.md,
                        ),
                        _buildLabel(
                          context,
                          AppLanguage.issueType[
                            AppConstant.language
                          ],
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.xs,
                        ),
                        DropdownButtonFormField<
                            String>(
                          initialValue: viewModel
                              .selectedIssueType,
                          isExpanded: true,
                          dropdownColor:
                              isDark
                                  ? colorScheme
                                      .surfaceContainer
                                  : AppColors
                                      .whiteColor,
                          style: TextStyle(
                            color: colorScheme
                                .onSurface,
                            fontSize: 14,
                          ),
                          decoration:
                              _dropdownDecoration(
                            context,
                          ),
                          items: viewModel
                              .issueTypes
                              .map(
                            (issue) {
                              return DropdownMenuItem<
                                  String>(
                                value: issue,
                                child: Text(
                                  issue,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: viewModel
                              .changeIssueType,
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.md,
                        ),
                        _buildLabel(
                          context,
                          AppLanguage
                                  .describeYourProblem[
                            AppConstant.language
                          ],
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.xs,
                        ),
                        CustomTextField(
                          controller:
                              _messageController,
                          hintText: AppLanguage
                                  .explainYourIssue[
                            AppConstant.language
                          ],
                          keyboardType:
                              TextInputType
                                  .multiline,
                          minLines: 5,
                          maxLines: 7,
                          maxLength: 500,
                          textInputAction:
                              TextInputAction
                                  .newline,
                          validator:
                              validateMessage,
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.md,
                        ),
                        if (viewModel
                                .errorMessage !=
                            null) ...[
                          _buildErrorMessage(
                            context,
                            viewModel
                                .errorMessage!,
                          ),
                          const SizedBox(
                            height:
                                AppSpacing.md,
                          ),
                        ],
                        AppCommonButton(
                          title: AppLanguage
                                  .submitRequest[
                            AppConstant.language
                          ],
                          icon:
                              Icons.send_outlined,
                          isLoading:
                              viewModel.isLoading,
                          onPressed: viewModel
                                  .isLoading
                              ? null
                              : () =>
                                  _submitRequest(
                                    viewModel,
                                  ),
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.lg,
                        ),
                        _buildSecurityInfo(
                          context,
                        ),
                        const SizedBox(
                          height:
                              AppSpacing.lg,
                        ),
                        _buildFaqSection(
                          context,
                        ),
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
    );
  }

  Widget _buildHeader(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.primary
                .withValues(alpha: 0.12)
            : AppColors.lightPurple,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isDark
                ? colorScheme
                    .surfaceContainer
                : AppColors.whiteColor,
            child: Icon(
              Icons.support_agent_outlined,
              size: 30,
              color: colorScheme.primary,
            ),
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
                  AppLanguage.howCanWeHelp[
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
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  AppLanguage
                          .supportHeaderDescription[
                    AppConstant.language
                  ],
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
    );
  }

  Widget _buildLabel(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context)
            .colorScheme
            .onSurface,
      ),
    );
  }

  InputDecoration _dropdownDecoration(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final borderColor = isDark
        ? colorScheme.onSurface
            .withValues(alpha: 0.25)
        : AppColors.inputBorder;

    return InputDecoration(
      hintText: AppLanguage.selectIssueType[
        AppConstant.language
      ],
      hintStyle: TextStyle(
        color: colorScheme.onSurface
            .withValues(alpha: 0.55),
      ),
      prefixIcon: Icon(
        Icons.help_outline,
        color: colorScheme.onSurface
            .withValues(alpha: 0.75),
      ),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    String message,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.error
            .withValues(alpha: 0.08),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: colorScheme.error,
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.primary
                .withValues(alpha: 0.12)
            : AppColors.lightPurple,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security_outlined,
            size: 24,
            color: colorScheme.primary,
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child: Text(
              AppLanguage
                      .supportSecurityMessage[
                AppConstant.language
              ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          AppLanguage
                  .frequentlyAskedQuestions[
            AppConstant.language
          ],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context)
                .colorScheme
                .onSurface,
          ),
        ),
        const SizedBox(
          height: AppSpacing.md,
        ),
        _buildFaq(
          context: context,
          question:
              AppLanguage.trackOrderQuestion[
            AppConstant.language
          ],
          answer:
              AppLanguage.trackOrderAnswer[
            AppConstant.language
          ],
        ),
        _buildFaq(
          context: context,
          question: AppLanguage
                  .paymentFailedQuestion[
            AppConstant.language
          ],
          answer:
              AppLanguage.paymentFailedAnswer[
            AppConstant.language
          ],
        ),
        _buildFaq(
          context: context,
          question: AppLanguage
                  .changePasswordQuestion[
            AppConstant.language
          ],
          answer: AppLanguage
                  .changePasswordAnswer[
            AppConstant.language
          ],
        ),
      ],
    );
  }

  Widget _buildFaq({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? colorScheme.surfaceContainer
        : AppColors.whiteColor;

    final borderColor = isDark
        ? colorScheme.onSurface
            .withValues(alpha: 0.18)
        : AppColors.inputBorder;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: ExpansionTile(
        backgroundColor:
            Colors.transparent,
        collapsedBackgroundColor:
            Colors.transparent,
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: colorScheme.primary,
        collapsedIconColor:
            colorScheme.onSurface
                .withValues(alpha: 0.65),
        title: Text(
          question,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: [
          Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              answer,
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
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest(
    HelpSupportViewModel viewModel,
  ) async {
    FocusScope.of(context).unfocus();

    final isValid =
        _formKey.currentState?.validate() ??
            false;

    if (!isValid) {
      return;
    }

    final success =
        await viewModel.submitSupportRequest(
      name: _nameController.text,
      email: _emailController.text,
      message: _messageController.text,
    );

    if (!mounted || !success) {
      return;
    }

    final ticketId = viewModel.ticketId;

    _messageController.clear();

    final successMessage =
        ticketId == null ||
                ticketId.trim().isEmpty
            ? AppLanguage
                    .supportRequestSubmitted[
                AppConstant.language
              ]
            : '${AppLanguage.supportRequestSubmitted[AppConstant.language]} '
                '${AppLanguage.ticketId[AppConstant.language]}: $ticketId';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            successMessage,
          ),
        ),
      );

    viewModel.resetForm();
  }
}