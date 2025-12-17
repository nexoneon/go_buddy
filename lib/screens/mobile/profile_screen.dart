import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/config.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import 'main_home_screen.dart';

/// Mobile Profile Screen
///
/// Screen for new users to complete their profile after registration
/// or for existing users to edit their profile from settings
class MobileProfileScreen extends StatefulWidget {
  /// If true, this is first-time setup - user cannot leave without saving
  /// If false, this is editing from settings - back button and nav bar are shown
  final bool isInitialSetup;

  const MobileProfileScreen({super.key, this.isInitialSetup = false});

  @override
  State<MobileProfileScreen> createState() => _MobileProfileScreenState();
}

class _MobileProfileScreenState extends State<MobileProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();

  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedGender = 'Male';
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Profile picture state
  Uint8List? _selectedImageBytes;
  String? _existingProfilePicture;
  bool _isUploadingImage = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      final user = await _userService.getUser(uid);
      if (user != null && mounted) {
        setState(() {
          _firstNameController.text = user.firstName ?? '';
          _lastNameController.text = user.lastName ?? '';
          _existingProfilePicture = user.profilePicture;
          if (user.dateOfBirth != null) {
            _selectedDate = user.dateOfBirth;
            _dobController.text =
                '${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}';
          }
          if (user.gender != null && _genders.contains(user.gender)) {
            _selectedGender = user.gender!;
          }
          _isLoadingData = false;
        });
      } else {
        setState(() => _isLoadingData = false);
      }
    } else {
      setState(() => _isLoadingData = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  /// Show options to pick image from gallery or camera
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Choose Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  if (_existingProfilePicture != null ||
                      _selectedImageBytes != null)
                    _buildImageOption(
                      icon: Icons.delete,
                      label: 'Remove',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _removeImage();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (color ?? const Color(0xFF0D7377)).withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: color ?? const Color(0xFF0D7377),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isSuccess: false);
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _existingProfilePicture = null;
    });
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

      try {
        String? profilePictureUrl;

        // Get original profile picture to check if we need to delete it
        final currentUser = _userService.currentUser;
        final originalProfilePicture = currentUser?.profilePicture;

        // Upload new profile picture if selected
        if (_selectedImageBytes != null) {
          setState(() => _isUploadingImage = true);

          // Delete old picture if exists
          if (originalProfilePicture != null &&
              originalProfilePicture.isNotEmpty) {
            await _userService.deleteProfilePicture(originalProfilePicture);
          }

          profilePictureUrl = await _userService.uploadProfilePicture(
            uid,
            _selectedImageBytes!,
          );
          setState(() => _isUploadingImage = false);

          if (profilePictureUrl == null) {
            _showSnackBar('Failed to upload profile picture', isSuccess: false);
          }
        } else if (_existingProfilePicture == null &&
            originalProfilePicture != null) {
          // User removed the picture without adding new one
          await _userService.deleteProfilePicture(originalProfilePicture);
          profilePictureUrl = ''; // Set to empty to clear it
        }

        final success = await _userService.updateProfile(
          uid: uid,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          profilePicture: profilePictureUrl,
          dateOfBirth: _selectedDate,
          gender: _selectedGender,
        );

        setState(() => _isLoading = false);

        if (success && mounted) {
          _showSnackBar('Profile saved successfully!', isSuccess: true);
          if (widget.isInitialSetup) {
            _navigateToHome();
          }
        } else {
          _showSnackBar(
            'Failed to update profile. Please try again.',
            isSuccess: false,
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _isUploadingImage = false;
        });
        _showSnackBar('Error: $e', isSuccess: false);
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

  int _selectedIndex = 4; // Settings is selected

  void _onNavItemTapped(int index) {
    // Only allow navigation if not initial setup
    if (!widget.isInitialSetup && index != 4) {
      // Navigate back to main screen with the selected tab
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent back button on initial setup
      canPop: !widget.isInitialSetup,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.isInitialSetup) {
          // Show message that profile must be completed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete your profile to continue'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(
            widget.isInitialSetup ? 'Complete Profile' : 'Edit Profile',
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF0D7377),
          foregroundColor: Colors.white,
          // Hide back button for initial setup
          automaticallyImplyLeading: !widget.isInitialSetup,
          leading: widget.isInitialSetup
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainHomeScreen(),
                    ),
                  ),
                ),
        ),
        body: _isLoadingData
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D7377)),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // Info Card
                        _buildInfoCard(),
                        const SizedBox(height: 24),
                        // Form Fields
                        _buildFormFields(),
                        const SizedBox(height: 24),
                        // Submit Button
                        _buildSubmitButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
        // Hide bottom nav for initial setup
        bottomNavigationBar: widget.isInitialSetup ? null : _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF0D7377),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favourite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'My Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help_outline),
              activeIcon: Icon(Icons.help),
              label: 'Help',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture with edit overlay
            GestureDetector(
              onTap: _showImagePickerOptions,
              child: Stack(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF0D7377).withAlpha(51),
                    backgroundImage: _selectedImageBytes != null
                        ? MemoryImage(_selectedImageBytes!)
                        : (_existingProfilePicture != null &&
                              _existingProfilePicture!.isNotEmpty)
                        ? NetworkImage(_existingProfilePicture!)
                              as ImageProvider
                        : null,
                    child:
                        (_selectedImageBytes == null &&
                            (_existingProfilePicture == null ||
                                _existingProfilePicture!.isEmpty))
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF0D7377),
                          )
                        : null,
                  ),
                  // Camera overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D7377),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _isUploadingImage
                            ? Icons.hourglass_top
                            : Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to change photo',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isInitialSetup
                  ? 'Complete Your Profile'
                  : 'Edit Your Profile',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Update your personal information',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First Name
            TextFormField(
              controller: _firstNameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter your first name',
                prefixIcon: Icon(Icons.person_outline, size: 22),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
                prefixIcon: Icon(Icons.person_outline, size: 22),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc_outlined, size: 22),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                hintText: 'Select your date of birth',
                prefixIcon: Icon(Icons.calendar_today_outlined, size: 22),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your date of birth';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D7377),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
