import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../address/view/address_screen.dart'
    show AddressScreen;
import '../../../auth/repository/auth_repository.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_languages.dart';
import '../../constants/app_spacing.dart';
import '../../navigation/viewmodel/navigation_viewmodel.dart';
import '../../routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(
                    context: context,
                    icon: Icons.shopping_bag_outlined,
                    title: AppLanguage.myOrders[
                        AppConstant.language],
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushNamed(
                        context,
                        AppRoutes.myOrders,
                      );
                    },
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.favorite_border,
                    title: AppLanguage.myWishlist[
                        AppConstant.language],
                    onTap: () {
                      Navigator.pop(context);

                      context
                          .read<NavigationViewModel>()
                          .changeTab(2);
                    },
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.location_on_outlined,
                    title: AppLanguage.myAddresses[
                        AppConstant.language],
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddressScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.payment_outlined,
                    title: AppLanguage.paymentMethods[
                        AppConstant.language],
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushNamed(
                        context,
                        AppRoutes.paymentMethods,
                      );
                    },
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: AppLanguage.settings[
                        AppConstant.language],
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushNamed(
                        context,
                        AppRoutes.setting,
                      );
                    },
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: AppLanguage.helpSupport[
                        AppConstant.language],
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushNamed(
                        context,
                        AppRoutes.helpSupport,
                      );
                    },
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.info_outline,
                    title: AppLanguage.aboutUs[
                        AppConstant.language],
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushNamed(
                        context,
                        AppRoutes.aboutUs,
                      );
                    },
                  ),
                  const Divider(),
                  _drawerItem(
                    context: context,
                    icon: Icons.logout,
                    title: AppLanguage.logout[
                        AppConstant.language],
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary
                .withValues(alpha: 0.10),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 32,
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
                  userName.isNotEmpty
                      ? userName
                      : AppLanguage.defaultUser[
                          AppConstant.language],
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        colorScheme.onSurface,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                Text(
                  userEmail,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
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

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
  ) async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final colorScheme =
            Theme.of(dialogContext)
                .colorScheme;

        return AlertDialog(
          title: Text(
            AppLanguage.logout[
                AppConstant.language],
            style: TextStyle(
              color:
                  colorScheme.onSurface,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          content: Text(
            AppLanguage.logoutConfirmation[
                AppConstant.language],
            style: TextStyle(
              color: colorScheme.onSurface
                  .withValues(
                alpha: 0.75,
              ),
            ),
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
                    AppConstant.language],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                AppLanguage.logout[
                    AppConstant.language],
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true ||
        !context.mounted) {
      return;
    }

    await _logout(context);
  }

  Future<void> _logout(
    BuildContext context,
  ) async {
    try {
      final authRepository =
          AuthRepository();

      await authRepository.logout();

      if (!context.mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLanguage
                      .somethingWentWrongError[
                  AppConstant.language],
            ),
          ),
        );
    }
  }
}