import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_languages.dart';
import '../../../core/services/notification_service.dart';
import '../../model/signup_request.dart';
import '../../model/user_model.dart';
import '../../repository/auth_repository.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;

  SignupViewModel({
    AuthRepository? authRepository,
    NotificationService? notificationService,
  })  : _authRepository =
            authRepository ?? AuthRepository(),
        _notificationService =
            notificationService ??
                NotificationService();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  bool get isPasswordVisible =>
      _isPasswordVisible;

  bool get isConfirmPasswordVisible =>
      _isConfirmPasswordVisible;

  String? get errorMessage =>
      _errorMessage;

  void setPassword() {
    _isPasswordVisible =
        !_isPasswordVisible;

    notifyListeners();
  }

  void setConfirmPassword() {
    _isConfirmPasswordVisible =
        !_isConfirmPasswordVisible;

    notifyListeners();
  }

  Future<UserModel?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    _setLoading(true);

    try {
      final request = SignupRequest(
        name: name.trim(),
        email: email.trim(),
        password: password,
        loginType: 'email',
      );

      final credential =
          await _authRepository.signup(
        request,
      );

      final firebaseUser =
          credential.user;

      if (firebaseUser == null) {
        _errorMessage =
            AppLanguage
                    .unableToCreateAccountError[
                AppConstant.language];

        return null;
      }

      await _authRepository
          .sendEmailVerification();

      await _registerNotificationToken();

      return UserModel(
        uid: firebaseUser.uid,
        name: request.name,
        email: request.email,
        loginType: request.loginType,
        isEmailVerified: false,
      );
    } on FirebaseAuthException catch (error) {
      _errorMessage =
          _getFirebaseError(
        error.code,
      );

      return null;
    } catch (_) {
      _errorMessage =
          AppLanguage
                  .somethingWentWrongError[
              AppConstant.language];

      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void>
      _registerNotificationToken() async {
    try {
      await _notificationService
          .registerNotificationToken();
    } catch (_) {
      // Notification token failure
      // should not fail signup.
    }
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
      case 'email-already-in-use':
        return AppLanguage
                .emailAlreadyInUseError[
            AppConstant.language];

      case 'invalid-email':
        return AppLanguage
                .invalidEmailError[
            AppConstant.language];

      case 'weak-password':
        return AppLanguage
                .weakPasswordError[
            AppConstant.language];

      case 'network-request-failed':
        return AppLanguage.networkError[
            AppConstant.language];

      default:
        return AppLanguage
                .signupFailedError[
            AppConstant.language];
    }
  }
}