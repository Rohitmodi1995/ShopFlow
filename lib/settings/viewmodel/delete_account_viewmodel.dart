import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/auth_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';

class DeleteAccountViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  DeleteAccountViewModel({
    AuthRepository? authRepository,
  }) : _authRepository =
            authRepository ?? AuthRepository();

  bool _isDeleting = false;
  String? _errorMessage;

  bool get isDeleting => _isDeleting;

  String? get errorMessage => _errorMessage;

  bool get hasPasswordProvider =>
      _authRepository.hasPasswordProvider;

  Future<bool> deleteAccount({
    String? currentPassword,
  }) async {
    if (_isDeleting) {
      return false;
    }

    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.deleteAccount(
        currentPassword: currentPassword,
      );

      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = _getFirebaseErrorMessage(
        error.code,
      );

      return false;
    } catch (_) {
      _errorMessage =
          AppLanguage.somethingWentWrongError[
        AppConstant.language
      ];

      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  String _getFirebaseErrorMessage(
    String errorCode,
  ) {
    switch (errorCode) {
      case 'requires-recent-login':
        return AppLanguage
                .deleteAccountRecentLoginRequired[
            AppConstant.language];

      case 'network-request-failed':
        return AppLanguage.networkError[
          AppConstant.language
        ];

      case 'user-not-logged-in':
      case 'user-not-found':
        return AppLanguage.usernotloggedinError[
          AppConstant.language
        ];

      case 'too-many-requests':
        return AppLanguage.tooManyRequestsError[
          AppConstant.language
        ];

      default:
        return AppLanguage.unableToDeleteAccount[
          AppConstant.language
        ];
    }
  }
}