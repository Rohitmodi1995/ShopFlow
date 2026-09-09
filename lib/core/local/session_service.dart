import 'user_session_service.dart';

abstract class SessionService {
  Future<void> saveSession({
    required String uid,
    required String name,
    required String email,
    required bool isEmailVerified,
    required LoginType loginType,
  });
}

class HiveSessionService implements SessionService {
  @override
  Future<void> saveSession({
    required String uid,
    required String name,
    required String email,
    required bool isEmailVerified,
    required LoginType loginType,
  }) {
    return UserSessionService.saveSession(
      uid: uid,
      name: name,
      email: email,
      isEmailVerified: isEmailVerified,
      loginType: loginType,
    );
  }
}