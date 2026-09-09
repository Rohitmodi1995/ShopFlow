import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../../core/local/user_session_service.dart';
import '../model/banner_model.dart';
import '../model/category_model.dart';
import '../model/product_model.dart';
import '../repository/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;

  HomeViewModel({
    HomeRepository? homeRepository,
  }) : _homeRepository =
           homeRepository ?? HomeRepository();

  bool _isLoading = false;
  String? _errorMessage;

  int _currentBannerIndex = 0;
  String _selectedCategory = 'all';

  String _userName = '';
  String _userEmail = '';

  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get currentBannerIndex =>
      _currentBannerIndex;

  String get selectedCategory =>
      _selectedCategory;

  String get userName => _userName;

  String get userEmail => _userEmail;

  List<BannerModel> get banners =>
      _banners;

  List<CategoryModel> get categories =>
      _categories;

  List<ProductModel> get products =>
      _products;

  List<ProductModel> get filteredProducts {
    if (_selectedCategory == 'all') {
      return _products;
    }

    return _products.where((product) {
      return product.categoryId
              .trim()
              .toLowerCase() ==
          _selectedCategory;
    }).toList();
  }

  Future<void> initialize() async {
    _loadUserData();

    await loadHomeData();
  }

  void _loadUserData() {
    _userName = UserSessionService.name;
    _userEmail = UserSessionService.email;
  }

  Future<void> loadHomeData() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      final results = await Future.wait([
        _homeRepository.getBanners(),
        _homeRepository.getCategories(),
        _homeRepository
            .getFeaturedProducts(),
      ]);

      _banners =
          results[0] as List<BannerModel>;

      _categories =
          results[1] as List<CategoryModel>;

      _products =
          results[2] as List<ProductModel>;
    } catch (_) {
      _errorMessage =
          AppLanguage
              .unableToLoadHomeDataError[
            AppConstant.language
          ];
    } finally {
      _setLoading(false);
    }
  }

  void setBannerIndex(int index) {
    if (_currentBannerIndex == index) {
      return;
    }

    _currentBannerIndex = index;

    notifyListeners();
  }

  void selectCategory(String category) {
    final value =
        category.trim().toLowerCase();

    if (_selectedCategory == value) {
      return;
    }

    _selectedCategory = value;

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