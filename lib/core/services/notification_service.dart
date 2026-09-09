import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../auth/repository/auth_repository.dart';
import '../../notifications/repository/notification_repository.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final AuthRepository _authRepository;
  final NotificationRepository
      _notificationRepository;

  final FlutterLocalNotificationsPlugin
      _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>?
      _tokenRefreshSubscription;

  StreamSubscription<RemoteMessage>?
      _foregroundMessageSubscription;

  StreamSubscription<RemoteMessage>?
      _notificationTapSubscription;

  bool _localNotificationsInitialized = false;

  static const AndroidNotificationChannel
      _channel = AndroidNotificationChannel(
    'shopflow_high_importance_channel',
    'ShopFlow Notifications',
    description:
        'This channel is used for ShopFlow notifications.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  NotificationService({
    FirebaseMessaging? firebaseMessaging,
    AuthRepository? authRepository,
    NotificationRepository?
        notificationRepository,
  })  : _firebaseMessaging =
            firebaseMessaging ??
                FirebaseMessaging.instance,
        _authRepository =
            authRepository ?? AuthRepository(),
        _notificationRepository =
            notificationRepository ??
                NotificationRepository();

  Future<void>
      initializeLocalNotifications() async {
    if (_localNotificationsInitialized) {
      return;
    }

    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings =
        InitializationSettings(
      android: androidSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          _handleLocalNotificationTap,
    );

    final androidImplementation =
        _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation
        ?.createNotificationChannel(
      _channel,
    );

    _localNotificationsInitialized = true;
  }

  Future<void>
      registerNotificationToken() async {
    final settings =
        await _firebaseMessaging
            .requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final isAllowed =
        settings.authorizationStatus ==
                AuthorizationStatus.authorized ||
            settings.authorizationStatus ==
                AuthorizationStatus.provisional;

    if (!isAllowed) {
      return;
    }

    final token =
        await _getNotificationToken();

    if (token == null) {
      return;
    }

    await _authRepository.saveFcmToken(
      token: token,
    );
  }

  Future<String?>
      _getNotificationToken() async {
    const maxAttempts = 3;

    for (int attempt = 0;
        attempt < maxAttempts;
        attempt++) {
      try {
        final token =
            await _firebaseMessaging
                .getToken();

        final normalizedToken =
            token?.trim() ?? '';

        if (normalizedToken.isNotEmpty) {
          return normalizedToken;
        }
      } catch (_) {}

      if (attempt < maxAttempts - 1) {
        await Future<void>.delayed(
          const Duration(seconds: 1),
        );
      }
    }

    return null;
  }

  void listenTokenRefresh() {
    _tokenRefreshSubscription?.cancel();

    _tokenRefreshSubscription =
        _firebaseMessaging
            .onTokenRefresh
            .listen(
      (token) async {
        final refreshedToken =
            token.trim();

        if (refreshedToken.isEmpty) {
          return;
        }

        try {
          await _authRepository
              .saveFcmToken(
            token: refreshedToken,
          );
        } catch (_) {}
      },
    );
  }

  void listenForegroundMessages() {
    _foregroundMessageSubscription?.cancel();

    _foregroundMessageSubscription =
        FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
  }

  Future<void>
      _handleForegroundMessage(
    RemoteMessage message,
  ) async {
    final notification =
        message.notification;

    if (notification == null) {
      return;
    }

    final title =
        notification.title
                    ?.trim()
                    .isNotEmpty ==
                true
            ? notification.title!.trim()
            : 'ShopFlow';

    final body =
        notification.body?.trim() ?? '';

    try {
      await showLocalNotification(
        title: title,
        body: body,
        payload: _buildPayload(
          message.data,
        ),
        notificationId:
            message.messageId?.hashCode,
      );
    } catch (_) {}

    await _saveNotificationHistory(
      title: title,
      body: body,
      type: _readString(
            message.data['type'],
          ) ??
          'general',
      orderId: _readString(
        message.data['orderId'],
      ),
    );
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? notificationId,
  }) async {
    if (!_localNotificationsInitialized) {
      await initializeLocalNotifications();
    }

    final notificationDetails =
        NotificationDetails(
      android:
          AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription:
            _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _localNotificationsPlugin.show(
      id: notificationId ??
          DateTime.now()
              .millisecondsSinceEpoch
              .remainder(100000),
      title: title,
      body: body,
      notificationDetails:
          notificationDetails,
      payload: payload,
    );
  }

  Future<void> showWelcomeNotification({
    required String userName,
  }) async {
    final name = userName.trim();

    const title =
        'Welcome to ShopFlow';

    final body = name.isEmpty
        ? 'Your ShopFlow account has been verified successfully.'
        : 'Hi $name, your ShopFlow account has been verified successfully.';

    await showLocalNotification(
      title: title,
      body: body,
      payload: 'welcome',
    );

    await _saveNotificationHistory(
      title: title,
      body: body,
      type: 'welcome',
    );
  }

  Future<void>
      showOrderPlacedNotification({
    required String orderId,
  }) async {
    final normalizedOrderId =
        orderId.trim();

    const title =
        'Order Placed Successfully';

    final body =
        'Your order #$normalizedOrderId has been placed successfully.';

    await showLocalNotification(
      title: title,
      body: body,
      payload:
          'order:$normalizedOrderId',
    );

    await _saveNotificationHistory(
      title: title,
      body: body,
      type: 'order_placed',
      orderId: normalizedOrderId,
    );
  }

  Future<void>
      showPaymentSuccessNotification({
    required String orderId,
  }) async {
    final normalizedOrderId =
        orderId.trim();

    const title =
        'Payment Successful';

    final body =
        'Payment for order #$normalizedOrderId was successful.';

    await showLocalNotification(
      title: title,
      body: body,
      payload:
          'payment_success:$normalizedOrderId',
    );

    await _saveNotificationHistory(
      title: title,
      body: body,
      type: 'payment_success',
      orderId: normalizedOrderId,
    );
  }

  Future<void>
      _saveNotificationHistory({
    required String title,
    required String body,
    required String type,
    String? orderId,
  }) async {
    try {
      await _notificationRepository
          .createNotification(
        title: title,
        body: body,
        type: type,
        orderId: orderId,
      );
    } catch (_) {}
  }

  void listenNotificationTap() {
    _notificationTapSubscription?.cancel();

    _notificationTapSubscription =
        FirebaseMessaging
            .onMessageOpenedApp
            .listen(
      _handleRemoteNotificationTap,
    );
  }

  Future<RemoteMessage?>
      getInitialMessage() {
    return _firebaseMessaging
        .getInitialMessage();
  }

  void _handleLocalNotificationTap(
    NotificationResponse response,
  ) {
    final payload =
        response.payload;

    if (payload == null ||
        payload.trim().isEmpty) {
      return;
    }
  }

  void _handleRemoteNotificationTap(
    RemoteMessage message,
  ) {
    if (message.data.isEmpty) {
      return;
    }
  }

  String? _buildPayload(
    Map<String, dynamic> data,
  ) {
    if (data.isEmpty) {
      return null;
    }

    final type =
        _readString(data['type']);

    final orderId =
        _readString(data['orderId']);

    if (type == null) {
      return null;
    }

    if (orderId == null) {
      return type;
    }

    return '$type:$orderId';
  }

  String? _readString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final text =
        value.toString().trim();

    return text.isEmpty
        ? null
        : text;
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription
        ?.cancel();

    await _foregroundMessageSubscription
        ?.cancel();

    await _notificationTapSubscription
        ?.cancel();

    _tokenRefreshSubscription = null;
    _foregroundMessageSubscription = null;
    _notificationTapSubscription = null;
  }
}