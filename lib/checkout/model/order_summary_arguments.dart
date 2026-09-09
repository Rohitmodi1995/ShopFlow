import '../../address/model/address_model.dart';
import 'checkout_data.dart';

class OrderSummaryArguments {
  final AddressModel address;
  final CheckoutData checkoutData;

  const OrderSummaryArguments({
    required this.address,
    required this.checkoutData,
  });
}