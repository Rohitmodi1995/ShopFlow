import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/local/hive_service.dart';
import '../model/banner_model.dart';
import '../model/category_model.dart';
import '../model/product_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore;

  static const String _bannersCacheKey =
      'home_banners';

  static const String _categoriesCacheKey =
      'home_categories';

  static const String _featuredProductsCacheKey =
      'featured_products';

  static const String _productsCacheKey =
      'all_products';

  HomeRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
           firestore ?? FirebaseFirestore.instance;

  Future<List<BannerModel>> getBanners() async {
    try {
      final snapshot = await _firestore
          .collection('banners')
          .where(
            'isActive',
            isEqualTo: true,
          )
          .orderBy('order')
          .get();

      final banners = snapshot.docs
          .map(
            (doc) => BannerModel.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      await _saveBanners(
        banners,
      );

      return banners;
    } catch (_) {
      if (_hasBannerCache) {
        return _getCachedBanners();
      }

      rethrow;
    }
  }

  Future<List<CategoryModel>>
  getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where(
            'isActive',
            isEqualTo: true,
          )
          .orderBy('order')
          .get();

      final categories = snapshot.docs
          .map(
            (doc) => CategoryModel.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      await _saveCategories(
        categories,
      );

      return categories;
    } catch (_) {
      if (_hasCategoryCache) {
        return _getCachedCategories();
      }

      rethrow;
    }
  }

  Future<List<ProductModel>>
  getFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where(
            'isActive',
            isEqualTo: true,
          )
          .where(
            'isFeatured',
            isEqualTo: true,
          )
          .get();

      final products = snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      await _saveFeaturedProducts(
        products,
      );

      return products;
    } catch (_) {
      if (_hasFeaturedProductsCache) {
        return _getCachedFeaturedProducts();
      }

      rethrow;
    }
  }

  Future<List<ProductModel>>
  getProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where(
            'isActive',
            isEqualTo: true,
          )
          .get();

      final products = snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      await _saveProducts(
        products,
      );

      return products;
    } catch (_) {
      if (_hasProductsCache) {
        return _getCachedProducts();
      }

      rethrow;
    }
  }

  bool get _hasBannerCache {
    return HiveService.bannerBox.containsKey(
      _bannersCacheKey,
    );
  }

  bool get _hasCategoryCache {
    return HiveService.categoryBox.containsKey(
      _categoriesCacheKey,
    );
  }

  bool get _hasFeaturedProductsCache {
    return HiveService.productBox.containsKey(
      _featuredProductsCacheKey,
    );
  }

  bool get _hasProductsCache {
    return HiveService.productBox.containsKey(
      _productsCacheKey,
    );
  }

  Future<void> _saveBanners(
    List<BannerModel> banners,
  ) async {
    final data = banners
        .map(
          (banner) => {
            'id': banner.id,
            ...banner.toMap(),
          },
        )
        .toList();

    await HiveService.bannerBox.put(
      _bannersCacheKey,
      data,
    );
  }

  List<BannerModel> _getCachedBanners() {
    final cachedData =
        HiveService.bannerBox.get(
      _bannersCacheKey,
    );

    if (cachedData is! List) {
      return [];
    }

    return cachedData
        .whereType<Map>()
        .map(
          (item) {
            final map =
                Map<String, dynamic>.from(
              item,
            );

            return BannerModel.fromMap(
              map['id']?.toString() ?? '',
              map,
            );
          },
        )
        .toList();
  }

  Future<void> _saveCategories(
    List<CategoryModel> categories,
  ) async {
    final data = categories
        .map(
          (category) => {
            'id': category.id,
            ...category.toMap(),
          },
        )
        .toList();

    await HiveService.categoryBox.put(
      _categoriesCacheKey,
      data,
    );
  }

  List<CategoryModel>
  _getCachedCategories() {
    final cachedData =
        HiveService.categoryBox.get(
      _categoriesCacheKey,
    );

    if (cachedData is! List) {
      return [];
    }

    return cachedData
        .whereType<Map>()
        .map(
          (item) {
            final map =
                Map<String, dynamic>.from(
              item,
            );

            return CategoryModel.fromMap(
              map['id']?.toString() ?? '',
              map,
            );
          },
        )
        .toList();
  }

  Future<void> _saveFeaturedProducts(
    List<ProductModel> products,
  ) async {
    final data = products
        .map(
          (product) => {
            'id': product.id,
            ...product.toMap(),
          },
        )
        .toList();

    await HiveService.productBox.put(
      _featuredProductsCacheKey,
      data,
    );
  }

  List<ProductModel>
  _getCachedFeaturedProducts() {
    final cachedData =
        HiveService.productBox.get(
      _featuredProductsCacheKey,
    );

    if (cachedData is! List) {
      return [];
    }

    return _mapCachedProducts(
      cachedData,
    );
  }

  Future<void> _saveProducts(
    List<ProductModel> products,
  ) async {
    final data = products
        .map(
          (product) => {
            'id': product.id,
            ...product.toMap(),
          },
        )
        .toList();

    await HiveService.productBox.put(
      _productsCacheKey,
      data,
    );
  }

  List<ProductModel> _getCachedProducts() {
    final cachedData =
        HiveService.productBox.get(
      _productsCacheKey,
    );

    if (cachedData is! List) {
      return [];
    }

    return _mapCachedProducts(
      cachedData,
    );
  }

  List<ProductModel> _mapCachedProducts(
    List cachedData,
  ) {
    return cachedData
        .whereType<Map>()
        .map(
          (item) {
            final map =
                Map<String, dynamic>.from(
              item,
            );

            return ProductModel.fromMap(
              map['id']?.toString() ?? '',
              map,
            );
          },
        )
        .toList();
  }
}