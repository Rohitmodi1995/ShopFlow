import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_languages.dart';
import '../model/address_model.dart';
import '../repository/address_repository.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressRepository _addressRepository;

  AddressViewModel({AddressRepository? addressRepository})
    : _addressRepository = addressRepository ?? AddressRepository();

  final List<AddressModel> _addresses = [];

  bool _isLoading = false;
  bool _isSaving = false;

  String? _errorMessage;
  String? _selectedAddressId;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  String? get selectedAddressId => _selectedAddressId;

  bool get isEmpty => _addresses.isEmpty;

  AddressModel? get selectedAddress {
    if (_addresses.isEmpty) {
      return null;
    }

    if (_selectedAddressId != null) {
      final index = _addresses.indexWhere(
        (address) => address.id == _selectedAddressId,
      );

      if (index != -1) {
        return _addresses[index];
      }
    }

    final defaultIndex = _addresses.indexWhere((address) => address.isDefault);

    if (defaultIndex != -1) {
      return _addresses[defaultIndex];
    }

    return _addresses.first;
  }

  Future<void> loadAddresses() async {
    if (_isLoading) {
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _addressRepository.getAddresses();

      _addresses
        ..clear()
        ..addAll(result);

      _setInitialSelectedAddress();
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToLoadAddressesError[AppConstant.language];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    if (_isSaving) {
      return false;
    }

    _setSaving(true);
    _errorMessage = null;

    try {
      final shouldSetDefault = address.isDefault || _addresses.isEmpty;

      final addressId = await _addressRepository.addAddress(
        address.copyWith(isDefault: shouldSetDefault),
      );

      if (shouldSetDefault) {
        await _addressRepository.setDefaultAddress(addressId);

        _selectedAddressId = addressId;
      }

      await _reloadAddresses();

      return true;
    } catch (_) {
      _errorMessage = AppLanguage.unableToAddAddressError[AppConstant.language];

      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> updateAddress(AddressModel address) async {
    if (_isSaving) {
      return false;
    }

    _setSaving(true);
    _errorMessage = null;

    try {
      final oldAddressIndex = _addresses.indexWhere(
        (item) => item.id == address.id,
      );

      final wasDefault =
          oldAddressIndex != -1 && _addresses[oldAddressIndex].isDefault;

      final updatedAddress = address.copyWith(
        isDefault: wasDefault || address.isDefault,
      );

      await _addressRepository.updateAddress(updatedAddress);

      if (updatedAddress.isDefault) {
        await _addressRepository.setDefaultAddress(address.id);

        _selectedAddressId = address.id;
      }

      await _reloadAddresses();

      return true;
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToUpdateAddressError[AppConstant.language];

      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> deleteAddress(AddressModel address) async {
    if (_isSaving) {
      return false;
    }

    _setSaving(true);
    _errorMessage = null;

    try {
      await _addressRepository.deleteAddress(address.id);

      if (_selectedAddressId == address.id) {
        _selectedAddressId = null;
      }

      await _reloadAddresses();

      return true;
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToDeleteAddressError[AppConstant.language];

      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> setDefaultAddress(String addressId) async {
    if (_isSaving) {
      return false;
    }

    final exists = _addresses.any((address) => address.id == addressId);

    if (!exists) {
      return false;
    }

    _setSaving(true);
    _errorMessage = null;

    try {
      await _addressRepository.setDefaultAddress(addressId);

      _selectedAddressId = addressId;

      await _reloadAddresses();

      return true;
    } catch (_) {
      _errorMessage =
          AppLanguage.unableToSetDefaultAddressError[AppConstant.language];

      return false;
    } finally {
      _setSaving(false);
    }
  }

  void selectAddress(String addressId) {
    if (_selectedAddressId == addressId) {
      return;
    }

    final exists = _addresses.any((address) => address.id == addressId);

    if (!exists) {
      return;
    }

    _selectedAddressId = addressId;

    notifyListeners();
  }

  void clearSelection() {
    if (_selectedAddressId == null) {
      return;
    }

    _selectedAddressId = null;

    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }

  Future<void> _reloadAddresses() async {
    final result = await _addressRepository.getAddresses();

    _addresses
      ..clear()
      ..addAll(result);

    _setInitialSelectedAddress();

    notifyListeners();
  }

  void _setInitialSelectedAddress() {
    if (_addresses.isEmpty) {
      _selectedAddressId = null;
      return;
    }

    if (_selectedAddressId != null) {
      final exists = _addresses.any(
        (address) => address.id == _selectedAddressId,
      );

      if (exists) {
        return;
      }
    }

    final defaultIndex = _addresses.indexWhere((address) => address.isDefault);

    if (defaultIndex != -1) {
      _selectedAddressId = _addresses[defaultIndex].id;

      return;
    }

    _selectedAddressId = _addresses.first.id;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    notifyListeners();
  }

  void _setSaving(bool value) {
    if (_isSaving == value) {
      return;
    }

    _isSaving = value;

    notifyListeners();
  }
}
