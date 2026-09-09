class SignupRequest {
  final String name;
  final String email;
  final String password;
  final String loginType;

  const SignupRequest({
    required this.name,
    required this.email,
    required this.password,
    this.loginType = 'email',
  });
}