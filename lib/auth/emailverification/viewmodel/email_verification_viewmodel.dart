import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_languages.dart';
import '../../../core/services/notification_service.dart';
import '../../repository/auth_repository.dart';

class EmailVerificationViewModel
    extends ChangeNotifier {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;

  EmailVerificationViewModel({
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

  Future<bool> checkVerification() async {
    _errorMessage = null;
    _setLoading(true);

    try {
      final isVerified =
          await _authRepository
              .isEmailVerified();

      if (!isVerified) {
        _errorMessage =
            AppLanguage.emailNotVerifiedText[
                AppConstant.language];

        return false;
      }

      await _authRepository
          .updateEmailVerificationStatus();

      await _showWelcomeNotification();

      return true;
    } catch (_) {
      _errorMessage =
          AppLanguage
                  .unableToVerifyEmailText[
              AppConstant.language];

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendEmail() async {
    _errorMessage = null;

    try {
      await _authRepository
          .sendEmailVerification();

      return true;
    } catch (_) {
      _errorMessage =
          AppLanguage
                  .unableToSendVerificationEmailText[
              AppConstant.language];

      return false;
    }
  }

  Future<void>
      _showWelcomeNotification() async {
    try {
      final userName =
          _authRepository.currentUserName;

      await _notificationService
          .showWelcomeNotification(
        userName: userName,
      );
    } catch (_) {

    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }
}