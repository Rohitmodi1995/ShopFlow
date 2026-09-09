import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../home/model/category_model.dart';
import '../../home/model/product_model.dart';
import '../../home/repository/home_repository.dart';

class CategoriesViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;

  CategoriesViewModel({
    HomeRepository? homeRepository,
  }) : _homeRepository =
            homeRepository ?? HomeRepository();

  static const String _allCategory = 'all';

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = _allCategory;

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get selectedCategory =>
      _selectedCategory;

  List<CategoryModel> get categories =>
      _categories;

  List<ProductModel> get products =>
      _products;

  List<ProductModel> get filteredProducts {
    if (_selectedCategory == _allCategory) {
      return _products;
    }

    return _products.where((product) {
      return product.categoryId ==
          _selectedCategory;
    }).toList();
  }

  Future<void> initialize() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final results = await Future.wait([
        _homeRepository.getCategories(),
        _homeRepository.getProducts(),
      ]);

      _categories =
          results[0] as List<CategoryModel>;

      _products =
          results[1] as List<ProductModel>;
    } catch (_) {
      _errorMessage =
          AppLanguage
                  .unableToLoadCategoriesError[
              AppConstant.language];
    } finally {
      _setLoading(false);
    }
  }

  void selectCategory(
    String categoryId,
  ) {
    final value = categoryId.trim();

    if (_selectedCategory == value) {
      return;
    }

    _selectedCategory = value;

    notifyListeners();
  }

  void selectAllCategories() {
    selectCategory(_allCategory);
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    notifyListeners();
  }
}