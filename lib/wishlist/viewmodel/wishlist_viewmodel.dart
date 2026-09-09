import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../home/model/product_model.dart';
import '../../home/repository/home_repository.dart';
import '../repository/wishlist_repository.dart';

class WishlistViewModel extends ChangeNotifier {
  final WishlistRepository _wishlistRepository;
  final HomeRepository _homeRepository;

  WishlistViewModel({
    WishlistRepository? wishlistRepository,
    HomeRepository? homeRepository,
  }) : _wishlistRepository =
            wishlistRepository ?? WishlistRepository(),
       _homeRepository =
            homeRepository ?? HomeRepository();

  final List<ProductModel> _wishlistProducts = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get wishlistProducts =>
      List.unmodifiable(_wishlistProducts);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool isInWishlist(String productId) {
    return _wishlistProducts.any(
      (product) => product.id == productId,
    );
  }

  Future<void> loadWishlist() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final wishlistProductIds =
          await _wishlistRepository
              .getWishlistProductIds();

      final products =
          await _homeRepository.getProducts();

      _wishlistProducts
        ..clear()
        ..addAll(
          products.where(
            (product) =>
                wishlistProductIds.contains(
              product.id,
            ),
          ),
        );
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToLoadWishlistError[
            AppConstant.language
          ];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleWishlist(
    ProductModel product,
  ) async {
    _errorMessage = null;

    final isAlreadyInWishlist =
        isInWishlist(product.id);

    if (isAlreadyInWishlist) {
      await _removeFromWishlist(product);
    } else {
      await _addToWishlist(product);
    }
  }

  Future<void> _addToWishlist(
    ProductModel product,
  ) async {
    _wishlistProducts.add(product);
    notifyListeners();

    try {
      await _wishlistRepository
          .addToWishlist(
        product.id,
      );
    } catch (_) {
      _wishlistProducts.removeWhere(
        (item) => item.id == product.id,
      );

      _errorMessage =
          AppLanguage
                  .unableToUpdateWishlistError[
              AppConstant.language];

      notifyListeners();
    }
  }

  Future<void> _removeFromWishlist(
    ProductModel product,
  ) async {
    final index =
        _wishlistProducts.indexWhere(
      (item) => item.id == product.id,
    );

    if (index == -1) {
      return;
    }

    final removedProduct =
        _wishlistProducts[index];

    _wishlistProducts.removeAt(index);
    notifyListeners();

    try {
      await _wishlistRepository
          .removeFromWishlist(
        product.id,
      );
    } catch (_) {
      _wishlistProducts.insert(
        index,
        removedProduct,
      );

      _errorMessage =
          AppLanguage
                  .unableToUpdateWishlistError[
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

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }
}