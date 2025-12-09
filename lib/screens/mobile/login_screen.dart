import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/config.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'profile_screen.dart';
import 'main_home_screen.dart';

/// Mobile Login Screen
///
/// Touch-optimized single-column login screen for mobile devices (Android/iOS).
/// Features phone number authentication with OTP verification via Firebase.
class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _showOtpField = false;
  String _selectedCountryCode = '+91';
  String? _errorMessage;
  int _resendCountdown = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Country codes list
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'country': 'IN', 'name': 'India'},
    // {'code': '+1', 'country': 'US', 'name': 'United States'},
    // {'code': '+44', 'country': 'UK', 'name': 'United Kingdom'},
    // {'code': '+971', 'country': 'AE', 'name': 'UAE'},
    // {'code': '+966', 'country': 'SA', 'name': 'Saudi Arabia'},
    // {'code': '+65', 'country': 'SG', 'name': 'Singapore'},
    // {'code': '+61', 'country': 'AU', 'name': 'Australia'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber =>
      '$_selectedCountryCode${_phoneController.text.trim()}';

  void _handleSendOTP() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _authService.sendOTP(
        phoneNumber: _fullPhoneNumber,
        onCodeSent: (verificationId, resendToken) {
          setState(() {
            _isLoading = false;
            _showOtpField = true;
            _startResendCountdown();
          });
          _showSnackBar('OTP sent to $_fullPhoneNumber', isSuccess: true);
        },
        onVerificationCompleted: (credential) async {
          // Auto-verification on Android
          setState(() => _isLoading = true);
          final success = await _authService.signInWithCredential(credential);
          setState(() => _isLoading = false);
          if (success && mounted) {
            _navigateToHome();
          }
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
          _showSnackBar(error, isSuccess: false);
        },
      );
    }
  }

  void _handleVerifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _authService.verifyOTP(
      otp: otp,
      onSuccess: () {
        setState(() => _isLoading = false);
        _navigateToHome();
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
        _showSnackBar(error, isSuccess: false);
      },
    );
  }

  void _startResendCountdown() {
    _resendCountdown = 30;
    _countdownTick();
  }

  void _countdownTick() {
    if (_resendCountdown > 0 && mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _resendCountdown--);
          _countdownTick();
        }
      });
    }
  }

  void _handleResendOTP() {
    if (_resendCountdown == 0) {
      _handleSendOTP();
    }
  }

  void _handleChangeNumber() {
    setState(() {
      _showOtpField = false;
      _otpController.clear();
      _errorMessage = null;
      _resendCountdown = 0;
    });
    _authService.resetVerification();
  }

  Future<void> _navigateToHome() async {
    final uid = _authService.currentUser?.uid;
    final phoneNumber = _authService.userPhone;

    if (uid == null || phoneNumber == null) {
      _showSnackBar('Login failed. Please try again.', isSuccess: false);
      return;
    }

    // Show loading
    _showSnackBar('Login successful! Loading...', isSuccess: true);

    // Check if user exists in Firestore
    final userExists = await _userService.userExists(uid);

    if (!userExists) {
      // New user - create user in Firestore
      await _userService.createUser(uid: uid, phoneNumber: phoneNumber);

      // Navigate to Profile Screen (initial setup mode)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const MobileProfileScreen(isInitialSetup: true),
          ),
        );
      }
    } else {
      // Existing user - get user data
      final user = await _userService.getUser(uid);

      // Update last login
      await _userService.updateLastLogin(uid);

      if (user == null) {
        _showSnackBar('Failed to load user data', isSuccess: false);
        return;
      }

      // Check if profile is complete
      if (!user.isProfileComplete) {
        // Navigate to Profile Screen to complete profile (initial setup mode)
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const MobileProfileScreen(isInitialSetup: true),
            ),
          );
        }
      } else {
        // Navigate to Main Home Screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainHomeScreen()),
          );
        }
      }
    }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryVeryLight, AppTheme.backgroundColor],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: MobileTheme.pagePadding,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Logo and Branding
                    _buildHeader(),
                    const SizedBox(height: 48),
                    // Login Form
                    _buildLoginForm(),
                    const SizedBox(height: 24),
                    // Terms & Privacy
                    _buildTermsText(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: MobileTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: MobileTheme.fabShadow,
          ),
          child: const Icon(
            Icons.rocket_launch_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        // Title
        Text(
          _showOtpField ? 'Verify OTP' : 'Welcome',
          style: MobileTheme.displayLarge.copyWith(color: AppTheme.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _showOtpField
              ? 'Enter the 6-digit code sent to\n$_fullPhoneNumber'
              : 'Enter your mobile number to continue',
          style: MobileTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: MobileTheme.cardPadding,
      decoration: MobileTheme.cardDecoration,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_showOtpField) ...[
              // Phone Number Field
              _buildPhoneField(),
              const SizedBox(height: 24),
              // Send OTP Button
              _buildSendOtpButton(),
            ] else ...[
              // OTP Field
              _buildOtpField(),
              const SizedBox(height: 16),
              // Resend & Change Number
              _buildOtpActions(),
              const SizedBox(height: 24),
              // Verify OTP Button
              _buildVerifyOtpButton(),
            ],
            // Error Message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: MobileTheme.labelLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Code Dropdown
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: PopupMenuButton<String>(
                initialValue: _selectedCountryCode,
                onSelected: (value) {
                  setState(() => _selectedCountryCode = value);
                },
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedCountryCode,
                        style: MobileTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 20),
                    ],
                  ),
                ),
                itemBuilder: (context) => _countryCodes.map((country) {
                  return PopupMenuItem<String>(
                    value: country['code'],
                    child: Row(
                      children: [
                        Text(
                          country['code']!,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          country['name']!,
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 12),
            // Phone Number Input
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: MobileTheme.inputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter 10 digit number',
                  prefixIcon: const Icon(Icons.phone_android_rounded, size: 22),
                ),
                style: MobileTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleSendOTP(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: MobileTheme.labelLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: MobileTheme.inputDecoration(
            labelText: 'OTP Code',
            hintText: '• • • • • •',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22),
          ),
          style: MobileTheme.displayMedium.copyWith(
            letterSpacing: 16,
            fontWeight: FontWeight.bold,
          ),
          onFieldSubmitted: (_) => _handleVerifyOTP(),
        ),
      ],
    );
  }

  Widget _buildOtpActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Change Number Button
        TextButton.icon(
          onPressed: _isLoading ? null : _handleChangeNumber,
          style: MobileTheme.textButtonStyle,
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Change Number'),
        ),
        // Resend OTP Button
        TextButton(
          onPressed: (_isLoading || _resendCountdown > 0)
              ? null
              : _handleResendOTP,
          style: MobileTheme.textButtonStyle,
          child: Text(
            _resendCountdown > 0
                ? 'Resend in ${_resendCountdown}s'
                : 'Resend OTP',
          ),
        ),
      ],
    );
  }

  Widget _buildSendOtpButton() {
    return SizedBox(
      height: MobileTheme.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSendOTP,
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
                  Text(
                    'Get OTP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildVerifyOtpButton() {
    return SizedBox(
      height: MobileTheme.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleVerifyOTP,
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
                  Icon(Icons.verified_user_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Verify & Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withAlpha(26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.errorColor.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: MobileTheme.bodyMedium.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: MobileTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
