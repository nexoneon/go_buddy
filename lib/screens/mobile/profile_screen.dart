import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import 'main_home_screen.dart';

/// Mobile Profile Screen
///
/// Screen for new users to complete their profile after registration
class MobileProfileScreen extends StatefulWidget {
  const MobileProfileScreen({super.key});

  @override
  State<MobileProfileScreen> createState() => _MobileProfileScreenState();
}

class _MobileProfileScreenState extends State<MobileProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();

  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  String _selectedGender = 'Male';
  DateTime? _selectedDate;
  bool _isLoading = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final uid = _authService.currentUser?.uid;
      if (uid == null) {
        _showSnackBar('User not found. Please login again.', isSuccess: false);
        setState(() => _isLoading = false);
        return;
      }

      final success = await _userService.updateProfile(
        uid: uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        _showSnackBar('Profile completed successfully!', isSuccess: true);
        _navigateToHome();
      } else {
        _showSnackBar(
          'Failed to update profile. Please try again.',
          isSuccess: false,
        );
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainHomeScreen()),
    );
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess
              ? AppTheme.successColor
              : AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryVeryLight, AppTheme.backgroundColor],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: MobileTheme.pagePadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // Info Card
                  _buildInfoCard(),
                  const SizedBox(height: 32),
                  // Form Fields
                  _buildFormFields(),
                  const SizedBox(height: 32),
                  // Submit Button
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: MobileTheme.cardDecoration,
      child: Column(
        children: [
          Icon(
            Icons.person_add_rounded,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to Go Buddy!',
            style: MobileTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please complete your profile to get started',
            style: MobileTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: MobileTheme.cardPadding,
      decoration: MobileTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First Name
          TextFormField(
            controller: _firstNameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: MobileTheme.inputDecoration(
              labelText: 'First Name',
              hintText: 'Enter your first name',
              prefixIcon: const Icon(Icons.person_outline, size: 22),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Last Name
          TextFormField(
            controller: _lastNameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: MobileTheme.inputDecoration(
              labelText: 'Last Name',
              hintText: 'Enter your last name',
              prefixIcon: const Icon(Icons.person_outline, size: 22),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Gender Dropdown
          DropdownButtonFormField<String>(
            value: _selectedGender,
            isExpanded: true,
            decoration: MobileTheme.inputDecoration(
              labelText: 'Gender',
              prefixIcon: const Icon(Icons.wc_outlined, size: 22),
            ),
            items: _genders.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _selectedGender = value);
              }
            },
          ),
          const SizedBox(height: 16),

          // Date of Birth
          TextFormField(
            controller: _dobController,
            readOnly: true,
            onTap: _selectDate,
            decoration: MobileTheme.inputDecoration(
              labelText: 'Date of Birth',
              hintText: 'Select your date of birth',
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 22),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your date of birth';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Address
          TextFormField(
            controller: _addressController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            maxLines: 3,
            decoration: MobileTheme.inputDecoration(
              labelText: 'Address',
              hintText: 'Enter your address',
              prefixIcon: const Icon(Icons.location_on_outlined, size: 22),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: MobileTheme.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: MobileTheme.primaryButtonStyle,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Complete Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
