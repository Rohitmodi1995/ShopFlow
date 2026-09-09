import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopflow/auth/login/viewmodel/login_viewmodel.dart';
import 'package:shopflow/auth/model/login_request.dart';
import 'package:shopflow/auth/repository/auth_repository.dart';
import 'package:shopflow/core/constants/app_constants.dart';
import 'package:shopflow/core/constants/app_languages.dart';
import 'package:shopflow/core/local/session_service.dart';
import 'package:shopflow/core/local/user_session_service.dart';
import 'package:shopflow/core/services/notification_service.dart';

class MockAuthRepository extends Mock
    implements AuthRepository {}

class MockNotificationService extends Mock
    implements NotificationService {}

class MockSessionService extends Mock
    implements SessionService {}

class MockUserCredential extends Mock
    implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late LoginViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockNotificationService mockNotificationService;
  late MockSessionService mockSessionService;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(
      const LoginRequest(
        email: '',
        password: '',
      ),
    );

    registerFallbackValue(
      LoginType.password,
    );
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockNotificationService =
        MockNotificationService();
    mockSessionService = MockSessionService();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();

    viewModel = LoginViewModel(
      authRepository: mockAuthRepository,
      notificationService:
          mockNotificationService,
      sessionService: mockSessionService,
    );
  });

  group('LoginViewModel', () {
    test(
      'initial state should be correct',
      () {
        expect(viewModel.isLoading, false);

        expect(
          viewModel.isPasswordVisible,
          false,
        );

        expect(
          viewModel.errorMessage,
          isNull,
        );
      },
    );

    test(
      'setPassword should toggle password visibility',
      () {
        expect(
          viewModel.isPasswordVisible,
          false,
        );

        viewModel.setPassword();

        expect(
          viewModel.isPasswordVisible,
          true,
        );

        viewModel.setPassword();

        expect(
          viewModel.isPasswordVisible,
          false,
        );
      },
    );

    test(
      'should return failed when Firebase throws invalid credential error',
      () async {
        when(
          () => mockAuthRepository.login(
            any(),
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'invalid-credential',
          ),
        );

        final result = await viewModel.login(
          email: 'test@gmail.com',
          password: '12345678',
        );

        expect(
          result,
          LoginResult.failed,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage.invalidCredentialError[
              AppConstant.language],
        );

        expect(
          viewModel.isLoading,
          false,
        );

        verify(
          () => mockAuthRepository.login(
            any(),
          ),
        ).called(1);
      },
    );

    test(
      'should return failed when Firebase throws network error',
      () async {
        when(
          () => mockAuthRepository.login(
            any(),
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'network-request-failed',
          ),
        );

        final result = await viewModel.login(
          email: 'test@gmail.com',
          password: '12345678',
        );

        expect(
          result,
          LoginResult.failed,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage.networkError[
              AppConstant.language],
        );

        expect(
          viewModel.isLoading,
          false,
        );
      },
    );

    test(
      'should return failed for unexpected exception',
      () async {
        when(
          () => mockAuthRepository.login(
            any(),
          ),
        ).thenThrow(
          Exception('Unexpected error'),
        );

        final result = await viewModel.login(
          email: 'test@gmail.com',
          password: '12345678',
        );

        expect(
          result,
          LoginResult.failed,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage.somethingWentWrongError[
              AppConstant.language],
        );

        expect(
          viewModel.isLoading,
          false,
        );
      },
    );

    test(
      'should return failed when credential user is null',
      () async {
        when(
          () => mockAuthRepository.login(
            any(),
          ),
        ).thenAnswer(
          (_) async => mockUserCredential,
        );

        when(
          () => mockUserCredential.user,
        ).thenReturn(null);

        final result = await viewModel.login(
          email: 'test@gmail.com',
          password: '12345678',
        );

        expect(
          result,
          LoginResult.failed,
        );

        expect(
          viewModel.errorMessage,
          AppLanguage.loginFailedError[
              AppConstant.language],
        );

        expect(
          viewModel.isLoading,
          false,
        );

        verifyNever(
          () => mockAuthRepository
              .isEmailVerified(),
        );

        verifyNever(
          () => mockSessionService.saveSession(
            uid: any(named: 'uid'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            isEmailVerified: any(
              named: 'isEmailVerified',
            ),
            loginType: any(
              named: 'loginType',
            ),
          ),
        );
      },
    );

    test(
      'should return emailNotVerified when email is not verified',
      () async {
        when(
          () => mockAuthRepository.login(
            any(),
          ),
        ).thenAnswer(
          (_) async => mockUserCredential,
        );

        when(
          () => mockUserCredential.user,
        ).thenReturn(mockUser);

        when(
          () => mockAuthRepository
              .isEmailVerified(),
        ).thenAnswer(
          (_) async => false,
        );

        final result = await viewModel.login(
          email: 'test@gmail.com',
          password: '12345678',
        );

        expect(
          result,
          LoginResult.emailNotVerified,
        );

        expect(
          viewModel.errorMessage,
          isNull,
        );

        expect(
          viewModel.isLoading,
          false,
        );

        verify(
          () => mockAuthRepository
              .isEmailVerified(),
        ).called(1);

        verifyNever(
          () => mockSessionService.saveSession(
            uid: any(named: 'uid'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            isEmailVerified: any(
              named: 'isEmailVerified',
            ),
            loginType: any(
              named: 'loginType',
            ),
          ),
        );

        verifyNever(
          () => mockNotificationService
              .registerNotificationToken(),
        );
      },
    );

    test(
      'should trim email before sending LoginRequest to repository',
      () async {
        when(
          () => mockAuthRepository.login(
            any(),
          ),
        ).thenAnswer(
          (_) async => mockUserCredential,
        );

        when(
          () => mockUserCredential.user,
        ).thenReturn(null);

        await viewModel.login(
          email: '  test@gmail.com  ',
          password: '12345678',
        );

        final captured = verify(
          () => mockAuthRepository.login(
            captureAny(),
          ),
        ).captured;

        final request =
            captured.single as LoginRequest;

        expect(
          request.email,
          'test@gmail.com',
        );

        expect(
          request.password,
          '12345678',
        );
      },
    );

    test(
      'should return success for verified user',
      () async {
        when(
          () => mockAuthRepository.login(
            any(),
          ),
        ).thenAnswer(
          (_) async => mockUserCredential,
        );

        when(
          () => mockUserCredential.user,
        ).thenReturn(mockUser);

        when(
          () => mockUser.uid,
        ).thenReturn('user_123');

        when(
          () => mockUser.displayName,
        ).thenReturn('Rohit');

        when(
          () => mockUser.email,
        ).thenReturn('rohit@gmail.com');

        when(
          () => mockAuthRepository
              .isEmailVerified(),
        ).thenAnswer(
          (_) async => true,
        );

        when(
          () => mockSessionService.saveSession(
            uid: any(named: 'uid'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            isEmailVerified: any(
              named: 'isEmailVerified',
            ),
            loginType: any(
              named: 'loginType',
            ),
          ),
        ).thenAnswer(
          (_) async {},
        );

        when(
          () => mockNotificationService
              .registerNotificationToken(),
        ).thenAnswer(
          (_) async {},
        );

        final result = await viewModel.login(
          email: 'rohit@gmail.com',
          password: '12345678',
        );

        expect(
          result,
          LoginResult.success,
        );

        expect(
          viewModel.errorMessage,
          isNull,
        );

        expect(
          viewModel.isLoading,
          false,
        );

        verify(
          () => mockAuthRepository.login(
            any(),
          ),
        ).called(1);

        verify(
          () => mockAuthRepository
              .isEmailVerified(),
        ).called(1);

        verify(
          () => mockSessionService.saveSession(
            uid: 'user_123',
            name: 'Rohit',
            email: 'rohit@gmail.com',
            isEmailVerified: true,
            loginType: LoginType.password,
          ),
        ).called(1);

        verify(
          () => mockNotificationService
              .registerNotificationToken(),
        ).called(1);
      },
    );

    test(
      'should still return success when notification registration fails',
      () async {
        when(
          () => mockAuthRepository.login(
            any(),
          ),
        ).thenAnswer(
          (_) async => mockUserCredential,
        );

        when(
          () => mockUserCredential.user,
        ).thenReturn(mockUser);

        when(
          () => mockUser.uid,
        ).thenReturn('user_123');

        when(
          () => mockUser.displayName,
        ).thenReturn('Rohit');

        when(
          () => mockUser.email,
        ).thenReturn('rohit@gmail.com');

        when(
          () => mockAuthRepository
              .isEmailVerified(),
        ).thenAnswer(
          (_) async => true,
        );

        when(
          () => mockSessionService.saveSession(
            uid: any(named: 'uid'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            isEmailVerified: any(
              named: 'isEmailVerified',
            ),
            loginType: any(
              named: 'loginType',
            ),
          ),
        ).thenAnswer(
          (_) async {},
        );

        when(
          () => mockNotificationService
              .registerNotificationToken(),
        ).thenThrow(
          Exception(
            'Notification registration failed',
          ),
        );

        final result = await viewModel.login(
          email: 'rohit@gmail.com',
          password: '12345678',
        );

        expect(
          result,
          LoginResult.success,
        );

        expect(
          viewModel.errorMessage,
          isNull,
        );

        expect(
          viewModel.isLoading,
          false,
        );

        verify(
          () => mockSessionService.saveSession(
            uid: 'user_123',
            name: 'Rohit',
            email: 'rohit@gmail.com',
            isEmailVerified: true,
            loginType: LoginType.password,
          ),
        ).called(1);

        verify(
          () => mockNotificationService
              .registerNotificationToken(),
        ).called(1);
      },
    );
  });
}