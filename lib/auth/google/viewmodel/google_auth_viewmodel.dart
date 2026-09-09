import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_languages.dart';
import '../../../core/local/user_session_service.dart';
import '../../../core/services/notification_service.dart';
import '../../repository/auth_repository.dart';

enum GoogleAuthResult {
  success,
  cancelled,
  failed,
}

class GoogleAuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;

  GoogleAuthViewModel({
    AuthRepository? authRepository,
    NotificationService? notificationService,
  })  : _authRepository =
            authRepository ?? AuthRepository(),
        _notificationService =
            notificationService ??
                NotificationService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  Future<GoogleAuthResult>
      signInWithGoogle() async {
    if (_isLoading) {
      return GoogleAuthResult.failed;
    }

    _errorMessage = null;
    _setLoading(true);

    try {
      final credential =
          await _authRepository
              .loginWithGoogle();

      final user = credential.user;

      if (user == null) {
        _errorMessage =
            AppLanguage.loginFailedError[
              AppConstant.language
            ];

        return GoogleAuthResult.failed;
      }

      final isNewUser =
          credential
              .additionalUserInfo
              ?.isNewUser ??
          false;

      await UserSessionService.saveSession(
        uid: user.uid,
        name:
            user.displayName?.trim() ?? '',
        email:
            user.email?.trim() ?? '',
        isEmailVerified:
            user.emailVerified,
        loginType: LoginType.google,
      );

      await _registerNotificationToken();

      if (isNewUser) {
        await _showWelcomeNotification(
          userName:
              user.displayName?.trim() ?? '',
        );
      }

      return GoogleAuthResult.success;
    } on GoogleSignInException catch (error) {
      if (error.code ==
          GoogleSignInExceptionCode
              .canceled) {
        return GoogleAuthResult.cancelled;
      }

      _errorMessage =
          AppLanguage.loginFailedError[
            AppConstant.language
          ];

      return GoogleAuthResult.failed;
    } on FirebaseAuthException catch (error) {
      _errorMessage =
          _getFirebaseError(error.code);

      return GoogleAuthResult.failed;
    } catch (_) {
      _errorMessage =
          AppLanguage
              .somethingWentWrongError[
            AppConstant.language
          ];

      return GoogleAuthResult.failed;
    } finally {
      _setLoading(false);
    }
  }

  Future<void>
      _registerNotificationToken() async {
    try {
      await _notificationService
          .registerNotificationToken();
    } catch (_) {}
  }

  Future<void> _showWelcomeNotification({
    required String userName,
  }) async {
    try {
      await _notificationService
          .showWelcomeNotification(
        userName: userName,
      );
    } catch (_) {}
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  String _getFirebaseError(
    String code,
  ) {
    switch (code) {
      case 'invalid-credential':
        return AppLanguage
            .invalidCredentialError[
          AppConstant.language
        ];

      case 'user-disabled':
        return AppLanguage
            .userDisabledError[
          AppConstant.language
        ];

      case 'too-many-requests':
        return AppLanguage
            .tooManyRequestsError[
          AppConstant.language
        ];

      case 'network-request-failed':
        return AppLanguage.networkError[
          AppConstant.language
        ];

      case 'account-exists-with-different-credential':
      case 'google-id-token-not-found':
      case 'google-user-not-found':
        return AppLanguage
            .loginFailedError[
          AppConstant.language
        ];

      default:
        return AppLanguage
            .loginFailedError[
          AppConstant.language
        ];
    }
  }
}