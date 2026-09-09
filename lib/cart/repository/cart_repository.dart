import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/local/hive_service.dart';

class CartRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  static const String _cartCachePrefix = 'cart_items';

  CartRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String get _userId {
    final userId = _firebaseAuth.currentUser?.uid;

    if (userId == null || userId.trim().isEmpty) {
      throw Exception('User not logged in');
    }

    return userId;
  }

  String get _cartCacheKey => '${_cartCachePrefix}_$_userId';

  CollectionReference<Map<String, dynamic>> get _cartCollection {
    return _firestore.collection('users').doc(_userId).collection('cart');
  }

  Future<void> addOrUpdateCart({
    required String productId,
    required int quantity,
  }) async {
    if (productId.trim().isEmpty || quantity <= 0) {
      return;
    }

    await _cartCollection.doc(productId).set({
      'productId': productId,
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _addOrUpdateCache(productId: productId, quantity: quantity);
  }

  Future<void> removeFromCart(String productId) async {
    await _cartCollection.doc(productId).delete();

    await _removeFromCache(productId);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final snapshot = await _cartCollection
          .orderBy('updatedAt', descending: true)
          .get();

      final cartItems = snapshot.docs
          .map((doc) {
            final data = doc.data();

            return <String, dynamic>{
              'productId': data['productId']?.toString() ?? doc.id,
              'quantity': _parseQuantity(data['quantity']),
            };
          })
          .where(
            (item) =>
                (item['productId'] as String).isNotEmpty &&
                (item['quantity'] as int) > 0,
          )
          .toList();

      await _saveCartCache(cartItems);

      return cartItems;
    } catch (_) {
      if (_hasCartCache) {
        return _getCachedCart();
      }

      rethrow;
    }
  }

  Future<void> clearCart() async {
    final snapshot = await _cartCollection.get();

    if (snapshot.docs.isNotEmpty) {
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }

    await _saveCartCache(const []);
  }

  bool get _hasCartCache {
    return HiveService.cartBox.containsKey(_cartCacheKey);
  }

  Future<void> _saveCartCache(List<Map<String, dynamic>> cartItems) async {
    await HiveService.cartBox.put(_cartCacheKey, cartItems);
  }

  List<Map<String, dynamic>> _getCachedCart() {
    final cachedData = HiveService.cartBox.get(_cartCacheKey);

    if (cachedData is! List) {
      return [];
    }

    return cachedData
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);

          return <String, dynamic>{
            'productId': map['productId']?.toString() ?? '',
            'quantity': _parseQuantity(map['quantity']),
          };
        })
        .where(
          (item) =>
              (item['productId'] as String).isNotEmpty &&
              (item['quantity'] as int) > 0,
        )
        .toList();
  }

  Future<void> _addOrUpdateCache({
    required String productId,
    required int quantity,
  }) async {
    final cartItems = _getCachedCart();

    final index = cartItems.indexWhere(
      (item) => item['productId'] == productId,
    );

    final cartItem = <String, dynamic>{
      'productId': productId,
      'quantity': quantity,
    };

    if (index == -1) {
      cartItems.insert(0, cartItem);
    } else {
      cartItems[index] = cartItem;
    }

    await _saveCartCache(cartItems);
  }

  Future<void> _removeFromCache(String productId) async {
    final cartItems = _getCachedCart();

    cartItems.removeWhere((item) => item['productId'] == productId);

    await _saveCartCache(cartItems);
  }

  int _parseQuantity(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
