import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/local/hive_service.dart';
import '../model/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  NotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _firebaseAuth =
            firebaseAuth ?? FirebaseAuth.instance;

  User get _currentUser {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw StateError(
        'User not logged in.',
      );
    }

    return user;
  }

  String get _cacheKey =>
      'notifications_${_currentUser.uid}';

  CollectionReference<Map<String, dynamic>>
      get _notificationCollection {
    return _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('notifications');
  }

  Future<String> createNotification({
    required String title,
    required String body,
    required String type,
    String? orderId,
  }) async {
    final document =
        _notificationCollection.doc();

    await document.set({
      'title': title.trim(),
      'body': body.trim(),
      'type': type.trim(),
      'orderId': orderId?.trim(),
      'isRead': false,
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    await _refreshCacheSafely();

    return document.id;
  }

  Future<List<NotificationModel>>
      getNotifications() async {
    try {
      final snapshot =
          await _notificationCollection
              .orderBy(
                'createdAt',
                descending: true,
              )
              .get();

      final notifications = snapshot.docs
          .map(
            (document) =>
                NotificationModel.fromMap(
              document.id,
              document.data(),
            ),
          )
          .toList();

      await _saveCacheSafely(
        notifications,
      );

      return notifications;
    } catch (_) {
      final cachedNotifications =
          _getCachedNotifications();

      if (cachedNotifications != null) {
        return cachedNotifications;
      }

      rethrow;
    }
  }

  Future<void> markAsRead({
    required String notificationId,
  }) async {
    final id = notificationId.trim();

    if (id.isEmpty) {
      return;
    }

    await _notificationCollection
        .doc(id)
        .update({
      'isRead': true,
    });

    await _updateCachedNotificationReadState(
      notificationId: id,
      isRead: true,
    );
  }

  Future<void> markAllAsRead() async {
    final snapshot =
        await _notificationCollection
            .where(
              'isRead',
              isEqualTo: false,
            )
            .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch =
        _firestore.batch();

    for (final document in snapshot.docs) {
      batch.update(
        document.reference,
        {
          'isRead': true,
        },
      );
    }

    await batch.commit();

    await _markAllCachedNotificationsAsRead();
  }

  Future<void> deleteNotification({
    required String notificationId,
  }) async {
    final id = notificationId.trim();

    if (id.isEmpty) {
      return;
    }

    await _notificationCollection
        .doc(id)
        .delete();

    await _removeCachedNotification(
      id,
    );
  }

  Future<void> clearNotifications() async {
    final snapshot =
        await _notificationCollection.get();

    if (snapshot.docs.isNotEmpty) {
      final batch =
          _firestore.batch();

      for (final document in snapshot.docs) {
        batch.delete(
          document.reference,
        );
      }

      await batch.commit();
    }

    await _clearCacheSafely();
  }

  Future<void> _refreshCacheSafely() async {
    try {
      final snapshot =
          await _notificationCollection
              .orderBy(
                'createdAt',
                descending: true,
              )
              .get();

      final notifications = snapshot.docs
          .map(
            (document) =>
                NotificationModel.fromMap(
              document.id,
              document.data(),
            ),
          )
          .toList();

      await _saveCacheSafely(
        notifications,
      );
    } catch (_) {
    }
  }

  Future<void> _saveCacheSafely(
    List<NotificationModel> notifications,
  ) async {
    try {
      final data = notifications
          .map(
            (notification) =>
                notification.toMap(),
          )
          .toList();

      await HiveService.productBox.put(
        _cacheKey,
        data,
      );
    } catch (_) {
    
    }
  }

  List<NotificationModel>?
      _getCachedNotifications() {
    try {
      final cachedData =
          HiveService.productBox.get(
        _cacheKey,
      );

      if (cachedData is! List) {
        return null;
      }

      final notifications =
          <NotificationModel>[];

      for (final item in cachedData) {
        if (item is! Map) {
          continue;
        }

        final map =
            Map<String, dynamic>.from(
          item,
        );

        final id =
            map['id']?.toString() ?? '';

        if (id.isEmpty) {
          continue;
        }

        notifications.add(
          NotificationModel.fromMap(
            id,
            map,
          ),
        );
      }

      return notifications;
    } catch (_) {
      return null;
    }
  }

  Future<void>
      _updateCachedNotificationReadState({
    required String notificationId,
    required bool isRead,
  }) async {
    final notifications =
        _getCachedNotifications();

    if (notifications == null) {
      return;
    }

    final updatedNotifications =
        notifications.map(
      (notification) {
        if (notification.id !=
            notificationId) {
          return notification;
        }

        return notification.copyWith(
          isRead: isRead,
        );
      },
    ).toList();

    await _saveCacheSafely(
      updatedNotifications,
    );
  }

  Future<void>
      _markAllCachedNotificationsAsRead() async {
    final notifications =
        _getCachedNotifications();

    if (notifications == null) {
      return;
    }

    final updatedNotifications =
        notifications
            .map(
              (notification) =>
                  notification.copyWith(
                isRead: true,
              ),
            )
            .toList();

    await _saveCacheSafely(
      updatedNotifications,
    );
  }

  Future<void> _removeCachedNotification(
    String notificationId,
  ) async {
    final notifications =
        _getCachedNotifications();

    if (notifications == null) {
      return;
    }

    final updatedNotifications =
        notifications
            .where(
              (notification) =>
                  notification.id !=
                  notificationId,
            )
            .toList();

    await _saveCacheSafely(
      updatedNotifications,
    );
  }

  Future<void> _clearCacheSafely() async {
    try {
      await HiveService.productBox.delete(
        _cacheKey,
      );
    } catch (_) {
    }
  }
}