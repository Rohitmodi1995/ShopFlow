import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_languages.dart';
import '../../repository/auth_repository.dart';

class ForgotPasswordViewModel
    extends ChangeNotifier {
  final AuthRepository _authRepository;

  ForgotPasswordViewModel({
    AuthRepository? authRepository,
  }) : _authRepository =
            authRepository ?? AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  Future<bool> sendPasswordResetEmail({
    required String email,
  }) async {
    _errorMessage = null;
    _setLoading(true);

    try {
      await _authRepository
          .sendPasswordResetEmail(
        email: email.trim(),
      );

      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage =
          _getFirebaseError(
        error.code,
      );

      return false;
    } catch (_) {
      _errorMessage =
          AppLanguage
                  .somethingWentWrongError[
              AppConstant.language];

      return false;
    } finally {
      _setLoading(false);
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
      case 'invalid-email':
        return AppLanguage
                .invalidEmailError[
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
                .unableToSendResetLinkText[
            AppConstant.language];
    }
  }
}