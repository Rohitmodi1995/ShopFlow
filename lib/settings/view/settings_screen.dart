import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_common_header.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../viewmodel/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLanguage.deleteAccount[
                    AppConstant.language
                  ],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            AppLanguage.deleteAccountConfirmation[
              AppConstant.language
            ],
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colorScheme.onSurface.withValues(
                alpha: 0.70,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                AppLanguage.cancel[
                  AppConstant.language
                ],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Continue',
              ),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true ||
        !context.mounted) {
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.deleteAccount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel =
        context.watch<SettingsViewModel>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark =
        theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? colorScheme.surface
        : AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppCommonHeader(
        title: AppLanguage.settings[
          AppConstant.language
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SettingsSectionTitle(
                  title: AppLanguage.preferences[
                    AppConstant.language
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                _SettingsTile(
                  icon:
                      Icons.notifications_none_rounded,
                  title: AppLanguage.notifications[
                    AppConstant.language
                  ],
                  subtitle:
                      AppLanguage.manageAppNotifications[
                    AppConstant.language
                  ],
                  trailing: Switch(
                    value: settingsViewModel
                        .notificationsEnabled,
                    onChanged: settingsViewModel
                        .toggleNotifications,
                  ),
                ),

                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: AppLanguage.darkMode[
                    AppConstant.language
                  ],
                  subtitle:
                      AppLanguage.useDarkAppearance[
                    AppConstant.language
                  ],
                  trailing: Switch(
                    value:
                        settingsViewModel.darkModeEnabled,
                    onChanged:
                        settingsViewModel.toggleDarkMode,
                  ),
                ),

                const SizedBox(height: 24),

                _SettingsSectionTitle(
                  title: AppLanguage.account[
                    AppConstant.language
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                if (settingsViewModel
                    .hasPasswordProvider)
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: AppLanguage.changePassword[
                      AppConstant.language
                    ],
                    subtitle:
                        AppLanguage.updateAccountPassword[
                      AppConstant.language
                    ],
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.changePassword,
                      );
                    },
                  ),

                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: AppLanguage.deleteAccount[
                    AppConstant.language
                  ],
                  subtitle:
                      AppLanguage.deleteAccountSubtitle[
                    AppConstant.language
                  ],
                  isDestructive: true,
                  onTap: () {
                    _showDeleteAccountDialog(
                      context,
                    );
                  },
                ),

                const SizedBox(height: 24),

                _SettingsSectionTitle(
                  title: AppLanguage.legal[
                    AppConstant.language
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: AppLanguage.privacyPolicy[
                    AppConstant.language
                  ],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.privacyPolicy,
                    );
                  },
                ),

                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: AppLanguage.termsConditions[
                    AppConstant.language
                  ],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.termsConditions,
                    );
                  },
                ),

                const SizedBox(height: 24),

                _SettingsSectionTitle(
                  title: AppLanguage.app[
                    AppConstant.language
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: AppLanguage.appVersion[
                    AppConstant.language
                  ],
                  subtitle: '1.0.0',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionTitle
    extends StatelessWidget {
  final String title;

  const _SettingsSectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface.withValues(
          alpha: 0.65,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark =
        theme.brightness == Brightness.dark;

    final borderColor = isDark
        ? colorScheme.onSurface.withValues(
            alpha: 0.12,
          )
        : AppColors.inputBorder;

    final iconColor = isDestructive
        ? Colors.red
        : AppColors.primary;

    final iconBackgroundColor = isDestructive
        ? Colors.red.withValues(
            alpha: 0.10,
          )
        : AppColors.primary.withValues(
            alpha: 0.10,
          );

    final titleColor = isDestructive
        ? Colors.red
        : colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Padding(
                padding:
                    const EdgeInsets.only(
                  top: 4,
                ),
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDestructive
                        ? Colors.red.withValues(
                            alpha: 0.70,
                          )
                        : colorScheme.onSurface
                            .withValues(
                            alpha: 0.60,
                          ),
                  ),
                ),
              ),
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons
                        .arrow_forward_ios_rounded,
                    size: 16,
                    color: isDestructive
                        ? Colors.red.withValues(
                            alpha: 0.70,
                          )
                        : colorScheme.onSurface
                            .withValues(
                            alpha: 0.60,
                          ),
                  )
                : null),
      ),
    );
  }
}