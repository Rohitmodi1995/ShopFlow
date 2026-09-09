import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/utils/validation.dart';
import '../model/user_profile_model.dart';
import '../repository/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier with ValidationClass {
  final ProfileRepository _profileRepository;

  ProfileViewModel({ProfileRepository? profileRepository})
    : _profileRepository = profileRepository ?? ProfileRepository();

  UserProfileModel? _profile;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  UserProfileModel? get profile => _profile;

  bool get isLoading => _isLoading;

  bool get isUpdating => _isUpdating;

  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    if (_isLoading) {
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      _profile = await _profileRepository.getProfile();
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToLoadProfileError[AppConstant.language];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({required String name}) async {
    if (_isUpdating) {
      return false;
    }

    final trimmedName = name.trim();

    final validationMessage = validateName(trimmedName);

    if (validationMessage != null) {
      _errorMessage = validationMessage;

      notifyListeners();

      return false;
    }

    _setUpdating(true);
    _errorMessage = null;

    try {
      await _profileRepository.updateProfile(name: trimmedName);

      if (_profile != null) {
        _profile = _profile!.copyWith(name: trimmedName);
      }

      return true;
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToUpdateProfileError[AppConstant.language];

      return false;
    } finally {
      _setUpdating(false);
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    notifyListeners();
  }

  void _setUpdating(bool value) {
    if (_isUpdating == value) {
      return;
    }

    _isUpdating = value;

    notifyListeners();
  }
}
