import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../local/hive_service.dart';
import '../local/user_session_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  static Future<void>? _googleSignInInitialization;

  bool _isInjectedGoogleSignInInitialized = false;

  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  bool get hasPasswordProvider {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return false;
    }

    return user.providerData.any(
      (provider) => provider.providerId == 'password',
    );
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  Future<UserCredential> loginWithGoogle() async {
    late final UserCredential credential;

    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();

      credential = await _firebaseAuth.signInWithPopup(googleProvider);
    } else {
      await _initializeGoogleSignIn();

      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'google-id-token-not-found',
          message: 'Google ID token could not be retrieved.',
        );
      }

      final googleCredential = GoogleAuthProvider.credential(idToken: idToken);

      credential = await _firebaseAuth.signInWithCredential(googleCredential);
    }

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'google-user-not-found',
        message: 'Google authenticated user could not be retrieved.',
      );
    }

    await _saveGoogleUser(user: user);

    return credential;
  }

  Future<UserCredential> signup({
    required String name,
    required String email,
    required String password,
    required String loginType,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Firebase user could not be created.',
      );
    }

    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    await user.updateDisplayName(trimmedName);

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': trimmedName,
      'email': trimmedEmail,
      'loginType': loginType,
      'isEmailVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;

    if (user == null || user.emailVerified) {
      return;
    }

    await user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  Future<void> updateEmailVerificationStatus() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).update({
      'isEmailVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-logged-in',
        message: 'No authenticated user found.',
      );
    }

    final email = user.email?.trim();

    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'email-not-found',
        message: 'Authenticated user email not found.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({String? currentPassword}) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-logged-in',
        message: 'No authenticated user found.',
      );
    }

    await _reauthenticateForDelete(
      user: user,
      currentPassword: currentPassword,
    );

    final uid = user.uid;

    await _deleteUserSubcollections(uid: uid);

    await _firestore.collection('users').doc(uid).delete();

    await user.delete();

    await _clearUserLocalData(uid: uid);

    await _signOutGoogleAccount();

    await UserSessionService.clearSession();
  }

  Future<void> _reauthenticateForDelete({
    required User user,
    String? currentPassword,
  }) async {
    final providers = user.providerData
        .map((provider) => provider.providerId)
        .toSet();

    if (providers.contains('password')) {
      await _reauthenticateWithPassword(
        user: user,
        currentPassword: currentPassword,
      );
      return;
    }

    if (providers.contains('google.com')) {
      await _reauthenticateWithGoogle(user: user);
      return;
    }

    throw FirebaseAuthException(
      code: 'reauthentication-provider-not-supported',
      message: 'No supported authentication provider found.',
    );
  }

  Future<void> _reauthenticateWithPassword({
    required User user,
    String? currentPassword,
  }) async {
    if (currentPassword == null || currentPassword.isEmpty) {
      throw FirebaseAuthException(
        code: 'current-password-required',
        message: 'Current password is required.',
      );
    }

    final email = user.email?.trim();

    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'email-not-found',
        message: 'Authenticated user email not found.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
  }

Future<void> _reauthenticateWithGoogle({
  required User user,
}) async {
  if (kIsWeb) {
    final googleProvider =
        GoogleAuthProvider();

    await user.reauthenticateWithPopup(
      googleProvider,
    );

    return;
  }

  await _initializeGoogleSignIn();

  final googleUser =
      await _googleSignIn.authenticate();

  final googleAuth =
      googleUser.authentication;

  final idToken =
      googleAuth.idToken;

  if (idToken == null ||
      idToken.isEmpty) {
    throw FirebaseAuthException(
      code: 'google-id-token-not-found',
      message:
          'Google ID token could not be retrieved.',
    );
  }

  final credential =
      GoogleAuthProvider.credential(
    idToken: idToken,
  );

  await user.reauthenticateWithCredential(
    credential,
  );
}
  Future<void> saveFcmToken({required String token}) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).update({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteUserSubcollections({required String uid}) async {
    final userReference = _firestore.collection('users').doc(uid);

    await _deleteCollection(userReference.collection('cart'));

    await _deleteCollection(userReference.collection('wishlist'));

    await _deleteCollection(userReference.collection('addresses'));

    await _deleteCollection(userReference.collection('notifications'));
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final snapshot = await collection.limit(400).get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();

      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();

      if (snapshot.docs.length < 400) {
        return;
      }
    }
  }

  Future<void> _clearUserLocalData({required String uid}) async {
    await HiveService.cartBox.delete('cart_items_$uid');

    await HiveService.productBox.delete('wishlist_product_ids_$uid');

    await HiveService.productBox.delete('notifications_$uid');

    await HiveService.userBox.delete('addresses_$uid');
  }

  Future<void> _initializeGoogleSignIn() async {
    final isDefaultInstance = identical(_googleSignIn, GoogleSignIn.instance);

    if (isDefaultInstance) {
      _googleSignInInitialization ??= _googleSignIn.initialize();

      await _googleSignInInitialization;

      return;
    }

    if (_isInjectedGoogleSignInInitialized) {
      return;
    }

    await _googleSignIn.initialize();

    _isInjectedGoogleSignInInitialized = true;
  }

  Future<void> _saveGoogleUser({required User user}) async {
    final userReference = _firestore.collection('users').doc(user.uid);

    final snapshot = await userReference.get();

    final name = user.displayName?.trim() ?? '';

    final email = user.email?.trim() ?? '';

    if (!snapshot.exists) {
      await userReference.set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'loginType': 'google',
        'isEmailVerified': user.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return;
    }

    await userReference.set({
      'name': name,
      'email': email,
      'loginType': 'google',
      'isEmailVerified': user.emailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

Future<void> _signOutGoogleAccount() async {
  if (kIsWeb) {
    return;
  }

  try {
    await _initializeGoogleSignIn();
    await _googleSignIn.signOut();
  } catch (_) {}
}

  Future<void> logout() async {
  try {
    await _firebaseAuth.signOut();

    if (!kIsWeb) {
      await _initializeGoogleSignIn();
      await _googleSignIn.signOut();
    }
  } finally {
    await UserSessionService.clearSession();
  }
}
}
