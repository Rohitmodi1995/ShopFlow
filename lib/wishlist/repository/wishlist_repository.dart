import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/local/hive_service.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  static const String _wishlistCachePrefix =
      'wishlist_product_ids';

  WishlistRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore =
           firestore ?? FirebaseFirestore.instance,
       _firebaseAuth =
           firebaseAuth ?? FirebaseAuth.instance;

  String get _userId {
    final userId =
        _firebaseAuth.currentUser?.uid;

    if (userId == null ||
        userId.trim().isEmpty) {
      throw Exception(
        'User not logged in',
      );
    }

    return userId;
  }

  String get _wishlistCacheKey =>
      '${_wishlistCachePrefix}_$_userId';

  CollectionReference<Map<String, dynamic>>
  get _wishlistCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist');
  }

  Future<void> addToWishlist(
    String productId,
  ) async {
    await _wishlistCollection
        .doc(productId)
        .set({
      'productId': productId,
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    await _addToCache(
      productId,
    );
  }

  Future<void> removeFromWishlist(
    String productId,
  ) async {
    await _wishlistCollection
        .doc(productId)
        .delete();

    await _removeFromCache(
      productId,
    );
  }

  Future<List<String>>
  getWishlistProductIds() async {
    try {
      final snapshot =
          await _wishlistCollection
              .orderBy(
                'createdAt',
                descending: true,
              )
              .get();

      final productIds = snapshot.docs
          .map(
            (doc) => doc
                .data()['productId']
                ?.toString(),
          )
          .whereType<String>()
          .where(
            (productId) =>
                productId.isNotEmpty,
          )
          .toList();

      await _saveWishlistCache(
        productIds,
      );

      return productIds;
    } catch (_) {
      if (_hasWishlistCache) {
        return _getCachedWishlist();
      }

      rethrow;
    }
  }

  Future<bool> isInWishlist(
    String productId,
  ) async {
    try {
      final document =
          await _wishlistCollection
              .doc(productId)
              .get();

      return document.exists;
    } catch (_) {
      if (!_hasWishlistCache) {
        rethrow;
      }

      return _getCachedWishlist()
          .contains(productId);
    }
  }

  bool get _hasWishlistCache {
    return HiveService.productBox
        .containsKey(
      _wishlistCacheKey,
    );
  }

  Future<void> _saveWishlistCache(
    List<String> productIds,
  ) async {
    await HiveService.productBox.put(
      _wishlistCacheKey,
      productIds,
    );
  }

  List<String> _getCachedWishlist() {
    final cachedData =
        HiveService.productBox.get(
      _wishlistCacheKey,
    );

    if (cachedData is! List) {
      return [];
    }

    return cachedData
        .map(
          (item) => item.toString(),
        )
        .where(
          (productId) =>
              productId.isNotEmpty,
        )
        .toList();
  }

  Future<void> _addToCache(
    String productId,
  ) async {
    final productIds =
        _getCachedWishlist();

    productIds.remove(productId);
    productIds.insert(
      0,
      productId,
    );

    await _saveWishlistCache(
      productIds,
    );
  }

  Future<void> _removeFromCache(
    String productId,
  ) async {
    final productIds =
        _getCachedWishlist();

    productIds.removeWhere(
      (id) => id == productId,
    );

    await _saveWishlistCache(
      productIds,
    );
  }
}