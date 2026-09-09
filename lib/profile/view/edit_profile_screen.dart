import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_common_button.dart';
import '../../core/components/app_common_textfield.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_styles.dart';
import '../viewmodel/profile_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController
      _nameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) {
      return;
    }

    final profile = context
        .read<ProfileViewModel>()
        .profile;

    if (profile != null) {
      _nameController.text =
          profile.name;

      _emailController.text =
          profile.email;
    }

    _isInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    final formState =
        _formKey.currentState;

    if (formState == null ||
        !formState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final viewModel =
        context.read<ProfileViewModel>();

    final success =
        await viewModel.updateProfile(
      name: _nameController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLanguage
                      .profileUpdatedSuccessfully[
                  AppConstant.language],
            ),
          ),
        );

      Navigator.pop(context);

      return;
    }

    final error =
        viewModel.errorMessage;

    if (error == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
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
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor:
            Colors.transparent,
        foregroundColor: isDark
            ? colorScheme.onSurface
            : AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          AppLanguage.editProfile[
              AppConstant.language],
          style:
              AppStyles.headerText.copyWith(
            fontSize: 18,
            fontWeight:
                FontWeight.w700,
            color: isDark
                ? colorScheme.onSurface
                : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child:
            Consumer<ProfileViewModel>(
          builder: (
            context,
            viewModel,
            child,
          ) {
            return LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 600,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .stretch,
                          children: [
                            const SizedBox(
                              height:
                                  AppSpacing.md,
                            ),

                            const Center(
                              child:
                                  CircleAvatar(
                                radius: 48,
                                backgroundColor:
                                    AppColors
                                        .primary,
                                child: Icon(
                                  Icons
                                      .person_rounded,
                                  size: 50,
                                  color:
                                      AppColors
                                          .whiteColor,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 32,
                            ),

                            CustomTextField(
                              controller:
                                  _nameController,
                              hintText: AppLanguage
                                      .enterfullnameText[
                                  AppConstant
                                      .language],
                              textInputAction:
                                  TextInputAction
                                      .done,
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .person_outline,
                              ),
                              validator: (value) {
                                return viewModel
                                    .validateName(
                                  value ?? '',
                                );
                              },
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            CustomTextField(
                              controller:
                                  _emailController,
                              readOnly: true,
                              hintText:
                                  AppLanguage.email[
                                AppConstant
                                    .language
                              ],
                              keyboardType:
                                  TextInputType
                                      .emailAddress,
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .email_outlined,
                              ),
                              suffixIcon:
                                  const Icon(
                                Icons
                                    .lock_outline,
                                size: 20,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              AppLanguage
                                      .emailChangeDisabled[
                                  AppConstant
                                      .language],
                              style: AppStyles
                                  .subHeading
                                  .copyWith(
                                fontSize: 12,
                                color: isDark
                                    ? colorScheme
                                        .onSurface
                                        .withValues(
                                          alpha:
                                              0.60,
                                        )
                                    : AppColors
                                        .textSecondary,
                              ),
                            ),

                            const SizedBox(
                              height: 32,
                            ),

                            AppCommonButton(
                              title: AppLanguage
                                      .saveChanges[
                                  AppConstant
                                      .language],
                              icon: Icons
                                  .check_rounded,
                              isLoading:
                                  viewModel
                                      .isUpdating,
                              onPressed: viewModel
                                      .isUpdating
                                  ? null
                                  : _saveProfile,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}