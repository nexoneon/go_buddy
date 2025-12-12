import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/config.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'web_admin_dashboard.dart';

/// Web Admin Login Screen
///
/// Phone number OTP authentication for admin access only
class WebAdminLoginScreen extends StatefulWidget {
  const WebAdminLoginScreen({super.key});

  @override
  State<WebAdminLoginScreen> createState() => _WebAdminLoginScreenState();
}

class _WebAdminLoginScreenState extends State<WebAdminLoginScreen> {
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

  @override
  void dispose() {
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

      // FIRST: Check if user exists and is admin BEFORE sending OTP
      final adminUser = await _userService.getUserByPhone(_fullPhoneNumber);

      if (adminUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No admin account found with this phone number';
        });
        return;
      }

      if (!adminUser.isSuperuser) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Access denied. This portal is for administrators only.';
        });
        return;
      }

      // User is admin, proceed with sending OTP
      await _authService.sendOTP(
        phoneNumber: _fullPhoneNumber,
        onCodeSent: (verificationId, resendToken) {
          setState(() {
            _isLoading = false;
            _showOtpField = true;
            _startResendCountdown();
          });
          _showMessage('OTP sent to $_fullPhoneNumber', isError: false);
        },
        onVerificationCompleted: (credential) async {
          setState(() => _isLoading = true);
          final success = await _authService.signInWithCredential(credential);
          setState(() => _isLoading = false);
          if (success && mounted) {
            await _checkAdminAndNavigate();
          }
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
          _showMessage(error, isError: true);
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
      onSuccess: () async {
        setState(() => _isLoading = false);
        await _checkAdminAndNavigate();
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
        _showMessage(error, isError: true);
      },
    );
  }

  Future<void> _checkAdminAndNavigate() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      _showMessage('Login failed. Please try again.', isError: true);
      return;
    }

    // Check if user exists in Firestore
    final userExists = await _userService.userExists(uid);

    if (!userExists) {
      // New user - but web is admin only
      await _authService.signOut();
      _showMessage('Access denied. Admin accounts only.', isError: true);
      return;
    }

    // Get user data
    final user = await _userService.getUser(uid);

    if (user == null) {
      _showMessage('Failed to load user data', isError: true);
      return;
    }

    // Check if user is admin (staff or superuser)
    if (!user.isStaff && !user.isSuperuser) {
      await _authService.signOut();
      _showMessage('Access denied. Admin privileges required.', isError: true);
      return;
    }

    // Update last login
    await _userService.updateLastLogin(uid);

    // Navigate to admin dashboard
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WebAdminDashboard()),
      );
    }
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

  void _showMessage(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? AppTheme.errorColor
              : AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.primaryLight],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 500,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white, // White background for the logo
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            8.0,
                          ), // Padding for the logo
                          child: Image.asset(
                            'assets/app_icon.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      _showOtpField ? 'Verify OTP' : '7 Pay Services Admin',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showOtpField
                          ? 'Enter the 6-digit code sent to $_fullPhoneNumber'
                          : 'Enter your mobile number to continue',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Form Fields
                    if (!_showOtpField) ...[
                      _buildPhoneField(),
                      const SizedBox(height: 24),
                      _buildSendOtpButton(),
                    ] else ...[
                      _buildOtpField(),
                      const SizedBox(height: 16),
                      _buildResendButton(),
                      const SizedBox(height: 24),
                      _buildVerifyButton(),
                    ],

                    // Error Message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: const TextStyle(fontSize: 18, letterSpacing: 1.5),
      decoration: InputDecoration(
        labelText: 'Mobile Number',
        hintText: 'Enter 10 digit number',
        prefixText: '$_selectedCountryCode ',
        prefixIcon: const Icon(Icons.phone_android),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
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
    );
  }

  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      style: const TextStyle(
        fontSize: 32,
        letterSpacing: 16,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: '• • • • • •',
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _showOtpField = false;
              _otpController.clear();
              _errorMessage = null;
              _resendCountdown = 0;
            });
          },
          child: const Text('Change Number'),
        ),
        TextButton(
          onPressed: (_isLoading || _resendCountdown > 0)
              ? null
              : _handleSendOTP,
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
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSendOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Get OTP',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleVerifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Verify & Login',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
