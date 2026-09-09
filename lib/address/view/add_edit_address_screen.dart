import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/address_model.dart';
import '../viewmodel/address_viewmodel.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _houseController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _pincodeController;

  bool _isDefault = false;

  bool get _isEditMode => widget.address != null;

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    _nameController = TextEditingController(text: address?.name ?? '');

    _phoneController = TextEditingController(text: address?.phone ?? '');

    _houseController = TextEditingController(text: address?.house ?? '');

    _streetController = TextEditingController(text: address?.street ?? '');

    _cityController = TextEditingController(text: address?.city ?? '');

    _stateController = TextEditingController(text: address?.state ?? '');

    _pincodeController = TextEditingController(text: address?.pincode ?? '');

    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Address' : 'Add Address')),
      body: SafeArea(
        child: Consumer<AddressViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter full name',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter name';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (value) {
                        final phone = value?.trim() ?? '';

                        if (phone.isEmpty) {
                          return 'Please enter phone number';
                        }

                        if (phone.length != 10) {
                          return 'Enter valid 10 digit phone number';
                        }

                        if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
                          return 'Enter valid phone number';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _houseController,
                      label: 'House / Flat Number',
                      hint: 'Enter house or flat number',
                      keyboardType: TextInputType.streetAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter house/flat number';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _streetController,
                      label: 'Street / Area',
                      hint: 'Enter street or area',
                      keyboardType: TextInputType.streetAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter street/area';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            hint: 'Enter city',
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter city';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _stateController,
                            label: 'State',
                            hint: 'Enter state',
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter state';
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _pincodeController,
                      label: 'Pincode',
                      hint: 'Enter pincode',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        final pincode = value?.trim() ?? '';

                        if (pincode.isEmpty) {
                          return 'Please enter pincode';
                        }

                        if (pincode.length != 6) {
                          return 'Enter valid 6 digit pincode';
                        }

                        if (!RegExp(r'^[0-9]+$').hasMatch(pincode)) {
                          return 'Enter valid pincode';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isDefault,
                      title: const Text('Set as default address'),
                      subtitle: widget.address?.isDefault == true
                          ? const Text('This is your current default address')
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: widget.address?.isDefault == true
                          ? null
                          : (value) {
                              setState(() {
                                _isDefault = value ?? false;
                              });
                            },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: viewModel.isSaving
                            ? null
                            : () {
                                _saveAddress(viewModel);
                              },
                        child: viewModel.isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isEditMode ? 'Update Address' : 'Save Address',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textInputAction: TextInputAction.next,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _saveAddress(AddressViewModel viewModel) async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final oldAddress = widget.address;

    final address = AddressModel(
      id: oldAddress?.id ?? '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      house: _houseController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      isDefault: _isDefault,
    );

    bool success;

    if (_isEditMode) {
      success = await viewModel.updateAddress(address);
    } else {
      success = await viewModel.addAddress(address);
    }

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Something went wrong.'),
        ),
      );

      return;
    }

    Navigator.pop(context);
  }
}
