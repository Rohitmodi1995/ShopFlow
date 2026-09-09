import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/local/hive_service.dart';
import '../model/address_model.dart';

class AddressRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  AddressRepository({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String get _userId {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw StateError('Authenticated user required.');
    }

    return user.uid;
  }

  String get _cacheKey => 'addresses_$_userId';

  CollectionReference<Map<String, dynamic>> get _addressCollection {
    return _firestore.collection('users').doc(_userId).collection('addresses');
  }

  Future<List<AddressModel>> getAddresses() async {
    try {
      final snapshot = await _addressCollection
          .orderBy('createdAt', descending: true)
          .get();

      final addresses = snapshot.docs
          .map((document) => AddressModel.fromMap(document.id, document.data()))
          .toList();

      await _saveAddressesToCache(addresses);

      return addresses;
    } catch (_) {
      final cachedAddresses = _getAddressesFromCache();

      if (cachedAddresses.isNotEmpty) {
        return cachedAddresses;
      }

      rethrow;
    }
  }

  Future<String> addAddress(AddressModel address) async {
    final document = _addressCollection.doc();

    final addressToSave = address.copyWith(id: document.id);

    await document.set({
      ...addressToSave.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _addAddressToCache(addressToSave);

    return document.id;
  }

  Future<void> updateAddress(AddressModel address) async {
    await _addressCollection.doc(address.id).update({
      ...address.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _updateAddressInCache(address);
  }

  Future<void> deleteAddress(String addressId) async {
    final document = await _addressCollection.doc(addressId).get();

    if (!document.exists) {
      return;
    }

    final deletedAddress = AddressModel.fromMap(
      document.id,
      document.data() ?? <String, dynamic>{},
    );

    final snapshot = await _addressCollection.get();

    final remainingDocuments = snapshot.docs
        .where((item) => item.id != addressId)
        .toList();

    final batch = _firestore.batch();

    batch.delete(_addressCollection.doc(addressId));

    if (deletedAddress.isDefault && remainingDocuments.isNotEmpty) {
      final newDefaultId = remainingDocuments.first.id;

      for (final document in remainingDocuments) {
        batch.update(document.reference, {
          'isDefault': document.id == newDefaultId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();

    await _deleteAddressFromCache(
      addressId,
      deletedWasDefault: deletedAddress.isDefault,
    );
  }

  Future<void> setDefaultAddress(String addressId) async {
    final snapshot = await _addressCollection.get();

    final targetExists = snapshot.docs.any(
      (document) => document.id == addressId,
    );

    if (!targetExists) {
      throw StateError('Address not found.');
    }

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.update(document.reference, {
        'isDefault': document.id == addressId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    await _setDefaultAddressInCache(addressId);
  }

  Future<void> _saveAddressesToCache(List<AddressModel> addresses) async {
    try {
      final data = addresses
          .map((address) => {'id': address.id, ...address.toMap()})
          .toList();

      await HiveService.userBox.put(_cacheKey, data);
    } catch (_) {}
  }

  List<AddressModel> _getAddressesFromCache() {
    try {
      final cachedData = HiveService.userBox.get(_cacheKey);

      if (cachedData is! List) {
        return [];
      }

      return cachedData
          .whereType<Map>()
          .map((item) {
            final map = Map<String, dynamic>.from(item);

            final id = map['id']?.toString() ?? '';

            return AddressModel.fromMap(id, map);
          })
          .where((address) => address.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _addAddressToCache(AddressModel address) async {
    try {
      final addresses = _getAddressesFromCache();

      addresses.removeWhere((item) => item.id == address.id);

      addresses.insert(0, address);

      await _saveAddressesToCache(addresses);
    } catch (_) {}
  }

  Future<void> _updateAddressInCache(AddressModel address) async {
    try {
      final addresses = _getAddressesFromCache();

      final index = addresses.indexWhere((item) => item.id == address.id);

      if (index == -1) {
        return;
      }

      addresses[index] = address;

      await _saveAddressesToCache(addresses);
    } catch (_) {}
  }

  Future<void> _deleteAddressFromCache(
    String addressId, {
    required bool deletedWasDefault,
  }) async {
    try {
      final addresses = _getAddressesFromCache();

      addresses.removeWhere((address) => address.id == addressId);

      if (deletedWasDefault && addresses.isNotEmpty) {
        final newDefaultId = addresses.first.id;

        final updatedAddresses = addresses
            .map(
              (address) =>
                  address.copyWith(isDefault: address.id == newDefaultId),
            )
            .toList();

        await _saveAddressesToCache(updatedAddresses);

        return;
      }

      await _saveAddressesToCache(addresses);
    } catch (_) {}
  }

  Future<void> _setDefaultAddressInCache(String addressId) async {
    try {
      final addresses = _getAddressesFromCache();

      if (addresses.isEmpty) {
        return;
      }

      final updatedAddresses = addresses
          .map(
            (address) => address.copyWith(isDefault: address.id == addressId),
          )
          .toList();

      await _saveAddressesToCache(updatedAddresses);
    } catch (_) {}
  }
}
