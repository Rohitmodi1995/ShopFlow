import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/config/app_config.dart';
import 'payment_gateway.dart';

class RazorpayPaymentService implements PaymentGateway {
  late final Razorpay _razorpay;

  void Function(PaymentSuccessResult result)? _onSuccess;
  void Function(String message)? _onFailure;

  RazorpayPaymentService() {
    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

  @override
  void openCheckout({
    required double amount,
    required String name,
    required String description,
    required String email,
    required String contact,
    String? orderId,
    required void Function(
      PaymentSuccessResult result,
    )
    onSuccess,
    required void Function(
      String message,
    )
    onFailure,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;

    if (!AppConfig.hasRazorpayKey) {
      _onFailure?.call(
        'Razorpay Key ID is not configured.',
      );
      return;
    }

    final options = <String, dynamic>{
      'key': AppConfig.razorpayKeyId,
      'amount': (amount * 100).round(),
      'currency': 'INR',
      'name': name,
      'description': description,
      'prefill': {
        'email': email,
        'contact': contact,
      },
      'theme': {
        'color': '#673AB7',
      },
    };

    if (orderId != null &&
        orderId.trim().isNotEmpty) {
      options['order_id'] = orderId.trim();
    }

    try {
      _razorpay.open(options);
    } catch (_) {
      _onFailure?.call(
        'Unable to open payment gateway.',
      );
    }
  }

  void _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) {
    final result = PaymentSuccessResult(
      paymentId: response.paymentId,
      orderId: response.orderId,
      signature: response.signature,
    );

    _onSuccess?.call(result);
  }

  void _handlePaymentError(
    PaymentFailureResponse response,
  ) {
    _onFailure?.call(
      response.message ??
          'Payment failed. Please try again.',
    );
  }

  void _handleExternalWallet(
    ExternalWalletResponse response,
  ) {}

  @override
  void dispose() {
    _razorpay.clear();

    _onSuccess = null;
    _onFailure = null;
  }
}