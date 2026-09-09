import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_common_header.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/constants/app_spacing.dart';
import '../model/notification_model.dart';
import '../viewmodel/notification_viewmodel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colorScheme.surface : AppColors.whiteColor;

    final viewModel = context.watch<NotificationViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppCommonHeader(
        title: AppLanguage.notifications[AppConstant.language],
        actions: [
          if (viewModel.unreadCount > 0)
            TextButton(
              onPressed: () => _markAllAsRead(viewModel),
              child: Text(
                AppLanguage.markAllRead[AppConstant.language],
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildBody(context, viewModel),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationViewModel viewModel) {
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null && viewModel.notifications.isEmpty) {
      return _buildErrorState(context, viewModel);
    }

    if (!viewModel.hasNotifications) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadNotifications,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: viewModel.notifications.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: AppSpacing.sm);
        },
        itemBuilder: (context, index) {
          final notification = viewModel.notifications[index];

          return _buildNotificationCard(context, viewModel, notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationViewModel viewModel,
    NotificationModel notification,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = notification.isRead
        ? isDark
              ? colorScheme.surface
              : AppColors.whiteColor
        : isDark
        ? colorScheme.primary.withValues(alpha: 0.12)
        : AppColors.lightPurple;

    final borderColor = notification.isRead
        ? isDark
              ? colorScheme.onSurface.withValues(alpha: 0.18)
              : AppColors.inputBorder
        : colorScheme.primary;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.error.withValues(alpha: 0.15)
              : Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.error),
      ),
      onDismissed: (_) {
        _deleteNotification(viewModel, notification);
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          if (!notification.isRead) {
            final success = await viewModel.markAsRead(
              notificationId: notification.id,
            );

            if (!success && mounted) {
              _showError(viewModel);
            }
          }

          if (!mounted) {
            return;
          }

          _handleNotificationTap(notification);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: notification.isRead ? 1 : 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(context, notification.type),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context, String type) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    IconData icon;

    switch (type) {
      case 'welcome':
        icon = Icons.celebration_outlined;
        break;

      case 'order':
      case 'order_placed':
        icon = Icons.shopping_bag_outlined;
        break;

      case 'payment_success':
        icon = Icons.check_circle_outline;
        break;

      default:
        icon = Icons.notifications_none;
    }

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : AppColors.whiteColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: colorScheme.primary, size: 24),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 70,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLanguage.noNotificationsYet[AppConstant.language],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLanguage.notificationsEmptyDescription[AppConstant.language],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    NotificationViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              viewModel.errorMessage ??
                  AppLanguage.unableToLoadNotificationsError[AppConstant
                      .language],
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: viewModel.loadNotifications,
              child: Text(AppLanguage.tryAgain[AppConstant.language]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAllAsRead(NotificationViewModel viewModel) async {
    final success = await viewModel.markAllAsRead();

    if (!mounted || success) {
      return;
    }

    _showError(viewModel);
  }

  Future<void> _deleteNotification(
    NotificationViewModel viewModel,
    NotificationModel notification,
  ) async {
    final success = await viewModel.deleteNotification(
      notificationId: notification.id,
    );

    if (!mounted || success) {
      return;
    }

    _showError(viewModel);
  }

  void _showError(NotificationViewModel viewModel) {
    final message = viewModel.errorMessage;

    if (message == null || message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

    viewModel.clearError();
  }

  void _handleNotificationTap(NotificationModel notification) {
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.isNegative || difference.inMinutes < 1) {
      return AppLanguage.justNow[AppConstant.language];
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} '
          '${AppLanguage.minuteAgo[AppConstant.language]}';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} '
          '${AppLanguage.hourAgo[AppConstant.language]}';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} '
          '${AppLanguage.daysAgo[AppConstant.language]}';
    }

    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
