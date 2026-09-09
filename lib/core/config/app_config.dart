class AppConfig {
  AppConfig._();

  static const String razorpayKeyId =
      String.fromEnvironment(
    'RAZORPAY_KEY_ID',
  );

  static bool get hasRazorpayKey =>
      razorpayKeyId.trim().isNotEmpty;
}