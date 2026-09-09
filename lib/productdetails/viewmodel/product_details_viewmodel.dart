import 'package:flutter/material.dart';

import '../../home/model/product_model.dart';

class ProductDetailsViewModel
    extends ChangeNotifier {
  ProductModel? _product;

  int _quantity = 1;
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;

  ProductModel? get product =>
      _product;

  int get quantity =>
      _quantity;

  int get currentImageIndex =>
      _currentImageIndex;

  bool get isDescriptionExpanded =>
      _isDescriptionExpanded;

  List<String> get productImages {
    final product = _product;

    if (product == null) {
      return [];
    }

    final images = product.images
        .map(
          (image) => image.trim(),
        )
        .where(
          (image) => image.isNotEmpty,
        )
        .toList();

    if (images.isNotEmpty) {
      return images;
    }

    final imageUrl =
        product.imageUrl.trim();

    if (imageUrl.isNotEmpty) {
      return [imageUrl];
    }

    return [];
  }

  void setProduct(
    ProductModel product,
  ) {
    _product = product;

    _quantity =
        product.stock > 0 ? 1 : 1;

    _currentImageIndex = 0;
    _isDescriptionExpanded = false;

    notifyListeners();
  }

  void setImageIndex(
    int index,
  ) {
    if (index < 0 ||
        index >= productImages.length) {
      return;
    }

    if (_currentImageIndex == index) {
      return;
    }

    _currentImageIndex = index;

    notifyListeners();
  }

  void toggleDescription() {
    _isDescriptionExpanded =
        !_isDescriptionExpanded;

    notifyListeners();
  }

  void increaseQuantity() {
    final product = _product;

    if (product == null ||
        product.stock <= 0) {
      return;
    }

    if (_quantity >= product.stock) {
      return;
    }

    _quantity++;

    notifyListeners();
  }

  void decreaseQuantity() {
    if (_quantity <= 1) {
      return;
    }

    _quantity--;

    notifyListeners();
  }
}