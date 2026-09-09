abstract class PaymentGateway {
  void openCheckout({
    required double amount,
    required String name,
    required String description,
    required String email,
    required String contact,
    String? orderId,
    required void Function(PaymentSuccessResult result) onSuccess,
    required void Function(String message) onFailure,
  });

  void dispose();
}

class PaymentSuccessResult {
  final String? paymentId;
  final String? orderId;
  final String? signature;

  const PaymentSuccessResult({this.paymentId, this.orderId, this.signature});
}
