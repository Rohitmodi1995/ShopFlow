import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_languages.dart';
import '../../../core/local/session_service.dart';
import '../../../core/local/user_session_service.dart';
import '../../../core/services/notification_service.dart';
import '../../model/login_request.dart';
import '../../repository/auth_repository.dart';

enum LoginResult {
  success,
  emailNotVerified,
  failed,
}

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;
  final SessionService _sessionService;

  LoginViewModel({
    AuthRepository? authRepository,
    NotificationService? notificationService,
    SessionService? sessionService,
  })  : _authRepository =
            authRepository ?? AuthRepository(),
        _notificationService =
            notificationService ?? NotificationService(),
        _sessionService =
            sessionService ?? HiveSessionService();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  bool get isPasswordVisible =>
      _isPasswordVisible;

  String? get errorMessage =>
      _errorMessage;

  void setPassword() {
    _isPasswordVisible =
        !_isPasswordVisible;

    notifyListeners();
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    _setLoading(true);

    try {
      final request = LoginRequest(
        email: email.trim(),
        password: password,
      );

      final credential =
          await _authRepository.login(
        request,
      );

      final user = credential.user;

      if (user == null) {
        _errorMessage =
            AppLanguage.loginFailedError[
                AppConstant.language];

        return LoginResult.failed;
      }

      final isVerified =
          await _authRepository
              .isEmailVerified();

      if (!isVerified) {
        return LoginResult
            .emailNotVerified;
      }

      await _saveUserSession(
        user: user,
        isEmailVerified: true,
      );

      await _registerNotificationToken();

      return LoginResult.success;
    } on FirebaseAuthException catch (error) {
      _errorMessage =
          _getFirebaseError(
        error.code,
      );

      return LoginResult.failed;
    } catch (_) {
      _errorMessage =
          AppLanguage
                  .somethingWentWrongError[
              AppConstant.language];

      return LoginResult.failed;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveUserSession({
    required User user,
    required bool isEmailVerified,
  }) async {
    await _sessionService.saveSession(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      isEmailVerified: isEmailVerified,
      loginType: LoginType.password,
    );
  }

  Future<void>
      _registerNotificationToken() async {
    try {
      await _notificationService
          .registerNotificationToken();
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
      case 'invalid-email':
        return AppLanguage
                .invalidEmailError[
            AppConstant.language];

      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return AppLanguage
                .invalidCredentialError[
            AppConstant.language];

      case 'user-disabled':
        return AppLanguage
                .userDisabledError[
            AppConstant.language];

      case 'too-many-requests':
        return AppLanguage
                .tooManyRequestsError[
            AppConstant.language];

      case 'network-request-failed':
        return AppLanguage.networkError[
            AppConstant.language];

      default:
        return AppLanguage
                .loginFailedError[
            AppConstant.language];
    }
  }
}