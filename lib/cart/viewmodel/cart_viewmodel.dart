import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../home/model/product_model.dart';
import '../../home/repository/home_repository.dart';
import '../model/cart_item_model.dart';
import '../repository/cart_repository.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepository _cartRepository;
  final HomeRepository _homeRepository;

  CartViewModel({
    CartRepository? cartRepository,
    HomeRepository? homeRepository,
  })  : _cartRepository =
            cartRepository ?? CartRepository(),
        _homeRepository =
            homeRepository ?? HomeRepository();

  final List<CartItemModel> _cartItems = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<CartItemModel> get cartItems =>
      List.unmodifiable(_cartItems);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isEmpty => _cartItems.isEmpty;

  int get totalProducts => _cartItems.length;

  int get totalItems {
    return _cartItems.fold(
      0,
      (total, item) =>
          total + item.quantity,
    );
  }

  double get subTotal {
    return _cartItems.fold(
      0.0,
      (total, item) =>
          total + item.totalPrice,
    );
  }

  bool isInCart(
    String productId,
  ) {
    return _cartItems.any(
      (item) =>
          item.product.id == productId,
    );
  }

  int getProductQuantity(
    String productId,
  ) {
    final index =
        _cartItems.indexWhere(
      (item) =>
          item.product.id == productId,
    );

    if (index == -1) {
      return 0;
    }

    return _cartItems[index].quantity;
  }

  Future<void> loadCart() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final cartData =
          await _cartRepository
              .getCartItems();

      final products =
          await _homeRepository
              .getProducts();

      _cartItems.clear();

      for (final data in cartData) {
        final productId =
            data['productId']
                ?.toString();

        final quantityValue =
            data['quantity'];

        if (productId == null ||
            productId.isEmpty ||
            quantityValue == null) {
          continue;
        }

        final quantity =
            quantityValue is int
                ? quantityValue
                : int.tryParse(
                      quantityValue
                          .toString(),
                    ) ??
                    0;

        if (quantity <= 0) {
          continue;
        }

        final productIndex =
            products.indexWhere(
          (product) =>
              product.id == productId,
        );

        if (productIndex == -1) {
          continue;
        }

        final product =
            products[productIndex];

        final safeQuantity =
            quantity > product.stock
                ? product.stock
                : quantity;

        if (safeQuantity <= 0) {
          continue;
        }

        _cartItems.add(
          CartItemModel(
            product: product,
            quantity: safeQuantity,
          ),
        );
      }
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToLoadCartError[
            AppConstant.language
          ];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(
    ProductModel product, {
    int quantity = 1,
  }) async {
    _errorMessage = null;

    if (product.stock <= 0 ||
        quantity <= 0) {
      return;
    }

    final index =
        _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id,
    );

    if (index == -1) {
      final quantityToAdd =
          quantity > product.stock
              ? product.stock
              : quantity;

      _cartItems.add(
        CartItemModel(
          product: product,
          quantity: quantityToAdd,
        ),
      );

      notifyListeners();

      try {
        await _cartRepository
            .addOrUpdateCart(
          productId: product.id,
          quantity: quantityToAdd,
        );
      } catch (_) {
        _cartItems.removeWhere(
          (item) =>
              item.product.id ==
              product.id,
        );

        _errorMessage =
            AppLanguage
                    .unableToUpdateCartError[
                AppConstant.language];

        notifyListeners();
      }

      return;
    }

    final currentItem =
        _cartItems[index];

    final updatedQuantity =
        currentItem.quantity +
            quantity;

    final finalQuantity =
        updatedQuantity >
                product.stock
            ? product.stock
            : updatedQuantity;

    if (finalQuantity ==
        currentItem.quantity) {
      return;
    }

    final oldItem =
        _cartItems[index];

    _cartItems[index] =
        currentItem.copyWith(
      quantity: finalQuantity,
    );

    notifyListeners();

    try {
      await _cartRepository
          .addOrUpdateCart(
        productId: product.id,
        quantity: finalQuantity,
      );
    } catch (_) {
      _cartItems[index] = oldItem;

      _errorMessage =
          AppLanguage
                  .unableToUpdateCartError[
              AppConstant.language];

      notifyListeners();
    }
  }

  Future<void> increaseQuantity(
    String productId,
  ) async {
    _errorMessage = null;

    final index =
        _cartItems.indexWhere(
      (item) =>
          item.product.id == productId,
    );

    if (index == -1) {
      return;
    }

    final item =
        _cartItems[index];

    if (item.quantity >=
        item.product.stock) {
      return;
    }

    final oldItem = item;

    final newQuantity =
        item.quantity + 1;

    _cartItems[index] =
        item.copyWith(
      quantity: newQuantity,
    );

    notifyListeners();

    try {
      await _cartRepository
          .addOrUpdateCart(
        productId: productId,
        quantity: newQuantity,
      );
    } catch (_) {
      _cartItems[index] = oldItem;

      _errorMessage =
          AppLanguage
                  .unableToUpdateCartError[
              AppConstant.language];

      notifyListeners();
    }
  }

  Future<void> decreaseQuantity(
    String productId,
  ) async {
    _errorMessage = null;

    final index =
        _cartItems.indexWhere(
      (item) =>
          item.product.id == productId,
    );

    if (index == -1) {
      return;
    }

    final item =
        _cartItems[index];

    if (item.quantity <= 1) {
      return;
    }

    final oldItem = item;

    final newQuantity =
        item.quantity - 1;

    _cartItems[index] =
        item.copyWith(
      quantity: newQuantity,
    );

    notifyListeners();

    try {
      await _cartRepository
          .addOrUpdateCart(
        productId: productId,
        quantity: newQuantity,
      );
    } catch (_) {
      _cartItems[index] = oldItem;

      _errorMessage =
          AppLanguage
                  .unableToUpdateCartError[
              AppConstant.language];

      notifyListeners();
    }
  }

  Future<void> removeFromCart(
    String productId,
  ) async {
    _errorMessage = null;

    final index =
        _cartItems.indexWhere(
      (item) =>
          item.product.id == productId,
    );

    if (index == -1) {
      return;
    }

    final removedItem =
        _cartItems[index];

    _cartItems.removeAt(index);

    notifyListeners();

    try {
      await _cartRepository
          .removeFromCart(
        productId,
      );
    } catch (_) {
      _cartItems.insert(
        index,
        removedItem,
      );

      _errorMessage =
          AppLanguage
                  .unableToUpdateCartError[
              AppConstant.language];

      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _errorMessage = null;

    if (_cartItems.isEmpty) {
      return;
    }

    final oldItems =
        List<CartItemModel>.from(
      _cartItems,
    );

    _cartItems.clear();

    notifyListeners();

    try {
      await _cartRepository.clearCart();
    } catch (_) {
      _cartItems
        ..clear()
        ..addAll(oldItems);

      _errorMessage =
          AppLanguage
                  .unableToClearCartError[
              AppConstant.language];

      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }

  void _setLoading(
    bool value,
  ) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    notifyListeners();
  }
}