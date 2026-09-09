import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/auth_service.dart';
import '../model/login_request.dart';
import '../model/signup_request.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({
    AuthService? authService,
  }) : _authService =
            authService ?? AuthService();

  User? get currentUser =>
      _authService.currentUser;

  String get currentUserName =>
      _authService.currentUser
              ?.displayName
              ?.trim() ??
          '';

  bool get hasPasswordProvider =>
      _authService.hasPasswordProvider;

  Future<UserCredential> login(
    LoginRequest request,
  ) {
    return _authService.login(
      email: request.email,
      password: request.password,
    );
  }

  Future<UserCredential>
      loginWithGoogle() {
    return _authService
        .loginWithGoogle();
  }

  Future<UserCredential> signup(
    SignupRequest request,
  ) {
    return _authService.signup(
      name: request.name,
      email: request.email,
      password: request.password,
      loginType: request.loginType,
    );
  }

  Future<void>
      sendEmailVerification() {
    return _authService
        .sendEmailVerification();
  }

  Future<bool> isEmailVerified() {
    return _authService
        .isEmailVerified();
  }

  Future<void>
      updateEmailVerificationStatus() {
    return _authService
        .updateEmailVerificationStatus();
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) {
    return _authService
        .sendPasswordResetEmail(
      email: email,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> deleteAccount({
    String? currentPassword,
  }) {
    return _authService.deleteAccount(
      currentPassword: currentPassword,
    );
  }

  Future<void> saveFcmToken({
    required String token,
  }) {
    return _authService.saveFcmToken(
      token: token,
    );
  }

  Future<void> logout() {
    return _authService.logout();
  }
}