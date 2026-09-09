import 'package:flutter/material.dart';

import '../service/payment_gateway.dart';
import '../service/razorpay_payment_service.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentGateway _paymentGateway;

  PaymentViewModel({
    PaymentGateway? paymentGateway,
  }) : _paymentGateway =
            paymentGateway ?? RazorpayPaymentService();

  bool _isProcessing = false;
  String? _errorMessage;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  void startPayment({
    required double amount,
    required String name,
    required String description,
    required String email,
    required String contact,
    String? razorpayOrderId,
    required void Function(
      PaymentSuccessResult result,
    )
    onSuccess,
    required void Function(
      String message,
    )
    onFailure,
  }) {
    if (_isProcessing) {
      return;
    }

    _errorMessage = null;
    _setProcessing(true);

    _paymentGateway.openCheckout(
      amount: amount,
      name: name,
      description: description,
      email: email,
      contact: contact,
      orderId: razorpayOrderId,
      onSuccess: (result) {
        _errorMessage = null;
        _setProcessing(false);
        onSuccess(result);
      },
      onFailure: (message) {
        _errorMessage = message;
        _setProcessing(false);
        onFailure(message);
      },
    );
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void _setProcessing(bool value) {
    if (_isProcessing == value) {
      return;
    }

    _isProcessing = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _paymentGateway.dispose();
    super.dispose();
  }
}