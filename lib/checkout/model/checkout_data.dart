import '../../cart/model/cart_item_model.dart';
import '../../home/model/product_model.dart';

enum CheckoutType {
  cart,
  buyNow,
}

class CheckoutData {
  final CheckoutType type;

  /// Checkout me jane wale final products.
  final List<CartItemModel> items;

  /// Buy Now ke case me direct product reference.
  final ProductModel? product;

  /// Buy Now selected quantity.
  final int quantity;

  const CheckoutData._({
    required this.type,
    required this.items,
    this.product,
    this.quantity = 1,
  });

  /// Cart checkout
  factory CheckoutData.cart({
    required List<CartItemModel> items,
  }) {
    return CheckoutData._(
      type: CheckoutType.cart,
      items: List<CartItemModel>.from(items),
    );
  }

  /// Product Details -> Buy Now
  factory CheckoutData.buyNow({
    required ProductModel product,
    required int quantity,
  }) {
    final cartItem = CartItemModel(
      product: product,
      quantity: quantity,
    );

    return CheckoutData._(
      type: CheckoutType.buyNow,
      items: [
        cartItem,
      ],
      product: product,
      quantity: quantity,
    );
  }

  bool get isCart {
    return type == CheckoutType.cart;
  }

  bool get isBuyNow {
    return type == CheckoutType.buyNow;
  }
}