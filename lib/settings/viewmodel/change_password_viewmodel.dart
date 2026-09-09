import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/auth_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  ChangePasswordViewModel({
    AuthRepository? authRepository,
  }) : _authRepository =
            authRepository ?? AuthRepository();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_isLoading) {
      return null;
    }

    _setLoading(true);

    try {
      await _authRepository.changePassword(
        currentPassword:
            currentPassword.trim(),
        newPassword:
            newPassword.trim(),
      );

      return null;
    } on FirebaseAuthException catch (error) {
      return _getFirebaseErrorMessage(
        error,
      );
    } catch (_) {
      return AppLanguage
          .unableToChangePasswordError[
        AppConstant.language
      ];
    } finally {
      _setLoading(false);
    }
  }

  String _getFirebaseErrorMessage(
    FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return AppLanguage
            .currentPasswordIncorrectError[
          AppConstant.language
        ];

      case 'weak-password':
        return AppLanguage
            .newPasswordTooWeakError[
          AppConstant.language
        ];

      case 'requires-recent-login':
        return AppLanguage
            .recentLoginRequiredError[
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

      default:
        return AppLanguage
            .unableToChangePasswordError[
          AppConstant.language
        ];
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