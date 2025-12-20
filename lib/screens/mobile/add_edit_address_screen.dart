import 'package:flutter/material.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import '../../services/auth_service.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;
  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController(text: 'Home');
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  final AddressService _addressService = AddressService();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _labelController.text = widget.address!.label;
      _addressLineController.text = widget.address!.addressLine;
      _cityController.text = widget.address!.city;
      _zipCodeController.text = widget.address!.zipCode;
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userId = AuthService().currentUser?.uid;
        if (userId == null) throw Exception('User not logged in');

        final newAddress = AddressModel(
          id:
              widget.address?.id ??
              '', // ID handled by service/firestore for new
          userId: userId,
          label: _labelController.text.trim(),
          addressLine: _addressLineController.text.trim(),
          city: _cityController.text.trim(),
          zipCode: _zipCodeController.text.trim(),
          isDefault: _isDefault,
          createdAt: DateTime.now(),
        );

        if (widget.address == null) {
          await _addressService.addAddress(userId, newAddress);
        } else {
          await _addressService.updateAddress(userId, newAddress);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
        backgroundColor: const Color(0xFF0D7377),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Label Section
                      Row(
                        children: [
                          _buildLabelChip('Home', Icons.home),
                          const SizedBox(width: 8),
                          _buildLabelChip('Work', Icons.work),
                          const SizedBox(width: 8),
                          _buildLabelChip('Other', Icons.location_on),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _labelController,
                        decoration: const InputDecoration(
                          labelText: 'Address Label (e.g. Home, Office)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressLineController,
                        decoration: const InputDecoration(
                          labelText: 'Address Line',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home_outlined),
                        ),
                        maxLines: 2,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_city),
                              ),
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _zipCodeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Zip Code',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.pin_drop),
                              ),
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Set as Default Address'),
                        value: _isDefault,
                        activeColor: const Color(0xFF0D7377),
                        onChanged: (val) => setState(() => _isDefault = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7377),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label, IconData icon) {
    final isSelected = _labelController.text == label;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : Colors.grey[600],
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF0D7377),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      onSelected: (selected) {
        if (selected) {
          setState(() => _labelController.text = label);
        }
      },
    );
  }
}
