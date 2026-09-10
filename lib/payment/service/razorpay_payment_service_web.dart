import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../../core/config/app_config.dart';
import 'payment_gateway.dart';

@JS('Razorpay')
extension type RazorpayJS._(JSObject _) implements JSObject {
  external factory RazorpayJS(JSObject options);

  external void open();
}

class RazorpayPaymentService implements PaymentGateway {
  bool _disposed = false;

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
    ) onSuccess,
    required void Function(
      String message,
    ) onFailure,
  }) {
    if (_disposed) {
      onFailure(
        'Unable to open payment gateway.',
      );
      return;
    }

    if (!AppConfig.hasRazorpayKey) {
      onFailure(
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
      'handler': ((JSObject response) {
        final paymentId =
            response.getProperty<JSAny?>(
              'razorpay_payment_id'.toJS,
            );

        final razorpayOrderId =
            response.getProperty<JSAny?>(
              'razorpay_order_id'.toJS,
            );

        final signature =
            response.getProperty<JSAny?>(
              'razorpay_signature'.toJS,
            );

        onSuccess(
          PaymentSuccessResult(
            paymentId: paymentId?.dartify()?.toString(),
            orderId:
                razorpayOrderId?.dartify()?.toString(),
            signature:
                signature?.dartify()?.toString(),
          ),
        );
      }).toJS,
      'modal': {
        'ondismiss': (() {
          onFailure(
            'Payment cancelled.',
          );
        }).toJS,
      },
    };

    if (orderId != null && orderId.trim().isNotEmpty) {
      options['order_id'] = orderId.trim();
    }

    try {
      final razorpay = RazorpayJS(
        options.jsify() as JSObject,
      );

      razorpay.open();
    } catch (_) {
      onFailure(
        'Unable to open payment gateway.',
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
  }
}