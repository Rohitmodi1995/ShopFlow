import '../../core/local/user_session_service.dart';

enum SplashDestination {
  login,
  home,
}

class SplashViewModel {
  SplashDestination getDestination() {
    final isLoggedIn =
        UserSessionService.isLoggedIn;

    final isVerified =
        UserSessionService.isEmailVerified;

    if (!isLoggedIn || !isVerified) {
      return SplashDestination.login;
    }

    return SplashDestination.home;
  }
}