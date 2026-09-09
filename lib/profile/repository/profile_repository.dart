import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/local/hive_service.dart';
import '../../core/local/user_session_service.dart';
import '../model/user_profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  static const String _profileCachePrefix =
      'user_profile';

  ProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore =
            firestore ??
                FirebaseFirestore.instance,
        _firebaseAuth =
            firebaseAuth ??
                FirebaseAuth.instance;

  User get _currentUser {
    final user =
        _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'User not logged in.',
      );
    }

    return user;
  }

  String get _profileCacheKey =>
      '${_profileCachePrefix}_${_currentUser.uid}';

  Future<UserProfileModel>
      getProfile() async {
    try {
      final user = _currentUser;

      final documentSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .get();

      if (!documentSnapshot.exists) {
        throw Exception(
          'User profile not found.',
        );
      }

      final data =
          documentSnapshot.data();

      if (data == null) {
        throw Exception(
          'User profile data is empty.',
        );
      }

      final profile =
          UserProfileModel.fromMap(
        data,
      );

      await _saveProfileCacheSafely(
        profile,
      );

      return profile;
    } catch (_) {
      final cachedProfile =
          _getCachedProfileSafely();

      if (cachedProfile != null) {
        return cachedProfile;
      }

      rethrow;
    }
  }

  Future<void> updateProfile({
    required String name,
  }) async {
    final trimmedName =
        name.trim();

    if (trimmedName.isEmpty) {
      throw Exception(
        'Name cannot be empty.',
      );
    }

    final user = _currentUser;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'name': trimmedName,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    await UserSessionService.updateName(
      trimmedName,
    );

    await _updateCachedNameSafely(
      trimmedName,
    );

    try {
      await user.updateDisplayName(
        trimmedName,
      );
    } catch (_) {}
  }

  Future<void> _saveProfileCacheSafely(
    UserProfileModel profile,
  ) async {
    try {
      await HiveService.userBox.put(
        _profileCacheKey,
        profile.toMap(),
      );
    } catch (_) {}
  }

  UserProfileModel?
      _getCachedProfileSafely() {
    try {
      if (!HiveService.userBox
          .containsKey(
        _profileCacheKey,
      )) {
        return null;
      }

      final cachedData =
          HiveService.userBox.get(
        _profileCacheKey,
      );

      if (cachedData is! Map) {
        return null;
      }

      final data =
          Map<String, dynamic>.from(
        cachedData,
      );

      return UserProfileModel.fromMap(
        data,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void>
      _updateCachedNameSafely(
    String name,
  ) async {
    try {
      final cachedData =
          HiveService.userBox.get(
        _profileCacheKey,
      );

      if (cachedData is! Map) {
        return;
      }

      final data =
          Map<String, dynamic>.from(
        cachedData,
      );

      data['name'] = name;

      await HiveService.userBox.put(
        _profileCacheKey,
        data,
      );
    } catch (_) {}
  }
}