import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

enum LoginType {
  password,
  google,
}

class UserSessionService {
  static Box get _box =>
      Hive.box(HiveBoxes.userBox);

  static const String _isLoggedInKey =
      'isLoggedIn';

  static const String _uidKey = 'uid';
  static const String _nameKey = 'name';
  static const String _emailKey = 'email';

  static const String _isEmailVerifiedKey =
      'isEmailVerified';

  static const String _loginTypeKey =
      'loginType';

  static Future<void> saveSession({
    required String uid,
    required String name,
    required String email,
    required bool isEmailVerified,
    required LoginType loginType,
  }) async {
    await _box.putAll({
      _isLoggedInKey: true,
      _uidKey: uid.trim(),
      _nameKey: name.trim(),
      _emailKey: email.trim(),
      _isEmailVerifiedKey:
          isEmailVerified,
      _loginTypeKey: loginType.name,
    });
  }

  static bool get isLoggedIn =>
      _box.get(
        _isLoggedInKey,
        defaultValue: false,
      ) as bool;

  static String get uid =>
      _box.get(
        _uidKey,
        defaultValue: '',
      ) as String;

  static String get name =>
      _box.get(
        _nameKey,
        defaultValue: '',
      ) as String;

  static String get email =>
      _box.get(
        _emailKey,
        defaultValue: '',
      ) as String;

  static bool get isEmailVerified =>
      _box.get(
        _isEmailVerifiedKey,
        defaultValue: false,
      ) as bool;

  static LoginType? get loginType {
    final value = _box.get(
      _loginTypeKey,
      defaultValue: '',
    ) as String;

    for (final type in LoginType.values) {
      if (type.name == value) {
        return type;
      }
    }

    return null;
  }

  static bool get isGoogleLogin =>
      loginType == LoginType.google;

  static bool get isPasswordLogin =>
      loginType == LoginType.password;

  static Future<void> updateName(
    String name,
  ) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return;
    }

    await _box.put(
      _nameKey,
      trimmedName,
    );
  }

  static Future<void>
      updateEmailVerification(
    bool isVerified,
  ) async {
    await _box.put(
      _isEmailVerifiedKey,
      isVerified,
    );
  }

  static Future<void> clearSession() async {
    await _box.clear();
  }
}