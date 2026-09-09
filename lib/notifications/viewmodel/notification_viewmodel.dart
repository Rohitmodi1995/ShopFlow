import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../model/notification_model.dart';
import '../repository/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _notificationRepository;

  NotificationViewModel({NotificationRepository? notificationRepository})
    : _notificationRepository =
          notificationRepository ?? NotificationRepository();

  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> _notifications = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  bool get hasNotifications => _notifications.isNotEmpty;

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  Future<void> loadNotifications() async {
    if (_isLoading) {
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      _notifications = await _notificationRepository.getNotifications();
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToLoadNotificationsError[AppConstant.language];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createNotification({
    required String title,
    required String body,
    required String type,
    String? orderId,
  }) async {
    _clearErrorWithoutNotify();

    try {
      await _notificationRepository.createNotification(
        title: title,
        body: body,
        type: type,
        orderId: orderId,
      );

      await loadNotifications();

      return true;
    } catch (_) {
      _setError(
        AppLanguage.unableToCreateNotificationError[AppConstant.language],
      );

      return false;
    }
  }

  Future<bool> markAsRead({required String notificationId}) async {
    final id = notificationId.trim();

    if (id.isEmpty) {
      return false;
    }

    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );

    if (index == -1) {
      return false;
    }

    if (_notifications[index].isRead) {
      return true;
    }

    _clearErrorWithoutNotify();

    final previousNotification = _notifications[index];

    _notifications[index] = previousNotification.copyWith(isRead: true);

    notifyListeners();

    try {
      await _notificationRepository.markAsRead(notificationId: id);

      return true;
    } catch (_) {
      final rollbackIndex = _notifications.indexWhere(
        (notification) => notification.id == id,
      );

      if (rollbackIndex != -1) {
        _notifications[rollbackIndex] = previousNotification;
      }

      _errorMessage =
          AppLanguage.unableToUpdateNotificationError[AppConstant.language];

      notifyListeners();

      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    if (unreadCount == 0) {
      return true;
    }

    _clearErrorWithoutNotify();

    final previousNotifications = List<NotificationModel>.from(_notifications);

    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();

    notifyListeners();

    try {
      await _notificationRepository.markAllAsRead();

      return true;
    } catch (_) {
      _notifications = previousNotifications;

      _errorMessage =
          AppLanguage.unableToMarkNotificationsReadError[AppConstant.language];

      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteNotification({required String notificationId}) async {
    final id = notificationId.trim();

    if (id.isEmpty) {
      return false;
    }

    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );

    if (index == -1) {
      return false;
    }

    _clearErrorWithoutNotify();

    final deletedNotification = _notifications[index];

    _notifications.removeAt(index);

    notifyListeners();

    try {
      await _notificationRepository.deleteNotification(notificationId: id);

      return true;
    } catch (_) {
      final restoreIndex = index.clamp(0, _notifications.length);

      _notifications.insert(restoreIndex, deletedNotification);

      _errorMessage =
          AppLanguage.unableToDeleteNotificationError[AppConstant.language];

      notifyListeners();

      return false;
    }
  }

  Future<bool> clearNotifications() async {
    if (_notifications.isEmpty) {
      return true;
    }

    _clearErrorWithoutNotify();

    final previousNotifications = List<NotificationModel>.from(_notifications);

    _notifications = [];

    notifyListeners();

    try {
      await _notificationRepository.clearNotifications();

      return true;
    } catch (_) {
      _notifications = previousNotifications;

      _errorMessage =
          AppLanguage.unableToClearNotificationsError[AppConstant.language];

      notifyListeners();

      return false;
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearErrorWithoutNotify() {
    _errorMessage = null;
  }
}
