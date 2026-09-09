import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/repository/auth_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/local/hive_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SettingsViewModel({
    AuthRepository? authRepository,
  }) : _authRepository =
            authRepository ?? AuthRepository();

  static const String _darkModeKey =
      'darkModeEnabled';

  static const String _notificationsKey =
      'notificationsEnabled';

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _isInitialized = false;
  bool _isDeletingAccount = false;

  String? _deleteAccountError;

  bool get notificationsEnabled =>
      _notificationsEnabled;

  bool get darkModeEnabled =>
      _darkModeEnabled;

  bool get isInitialized =>
      _isInitialized;

  bool get isDeletingAccount =>
      _isDeletingAccount;

  String? get deleteAccountError =>
      _deleteAccountError;

  bool get hasPasswordProvider =>
      _authRepository.hasPasswordProvider;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      _darkModeEnabled =
          HiveService.getSetting<bool>(
        _darkModeKey,
        defaultValue: false,
      );

      _notificationsEnabled =
          HiveService.getSetting<bool>(
        _notificationsKey,
        defaultValue: true,
      );
    } catch (_) {
      _darkModeEnabled = false;
      _notificationsEnabled = true;
    }

    _isInitialized = true;

    notifyListeners();
  }

  Future<void> toggleDarkMode(
    bool value,
  ) async {
    if (_darkModeEnabled == value) {
      return;
    }

    final previousValue =
        _darkModeEnabled;

    _darkModeEnabled = value;
    notifyListeners();

    try {
      await HiveService.saveSetting<bool>(
        _darkModeKey,
        value,
      );
    } catch (_) {
      _darkModeEnabled =
          previousValue;

      notifyListeners();
    }
  }

  Future<void> toggleNotifications(
    bool value,
  ) async {
    if (_notificationsEnabled == value) {
      return;
    }

    final previousValue =
        _notificationsEnabled;

    _notificationsEnabled = value;
    notifyListeners();

    try {
      await HiveService.saveSetting<bool>(
        _notificationsKey,
        value,
      );
    } catch (_) {
      _notificationsEnabled =
          previousValue;

      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    if (_isDeletingAccount) {
      return false;
    }

    _isDeletingAccount = true;
    _deleteAccountError = null;

    notifyListeners();

    try {
      await _authRepository.deleteAccount();

      return true;
    } on FirebaseAuthException catch (error) {
      _deleteAccountError =
          _getDeleteAccountErrorMessage(
        error.code,
      );

      return false;
    } catch (_) {
      _deleteAccountError =
          AppLanguage
              .somethingWentWrongError[
            AppConstant.language
          ];

      return false;
    } finally {
      _isDeletingAccount = false;

      notifyListeners();
    }
  }

  String _getDeleteAccountErrorMessage(
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
        return AppLanguage
                .usernotloggedinError[
            AppConstant.language];

      case 'too-many-requests':
        return AppLanguage
                .tooManyRequestsError[
            AppConstant.language];

      default:
        return AppLanguage
                .unableToDeleteAccount[
            AppConstant.language];
    }
  }
}