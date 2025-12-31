import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/config.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/admin_model.dart';
import 'web_admin_dashboard.dart';
import 'web_admin_signup.dart';

/// Web Admin Login Screen
///
/// Email and password authentication for admin access only
class WebLoginScreen extends StatefulWidget {
  const WebLoginScreen({super.key});

  @override
  State<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // First, authenticate with Firebase
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
        onSuccess: () async {
          // Authentication successful, now check if admin exists in Firestore
          final uid = _authService.currentUser?.uid;

          if (uid == null) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Authentication failed. Please try again.';
            });
            return;
          }

          // Check if admin exists
          var admin = await _adminService.getAdmin(uid);

          if (admin == null) {
            // Admin doesn't exist in Firestore, create the admin document
            final newAdmin = AdminModel(
              uid: uid,
              email: email,
              isActive: true,
              isStaff: true,
              isSuperuser: true,
              dateJoined: DateTime.now(),
            );

            final success = await _adminService.createAdmin(newAdmin);
            if (!success) {
              setState(() {
                _isLoading = false;
                _errorMessage =
                    'Failed to create admin profile. Please try again.';
              });
              return;
            }
            admin = newAdmin;
          }

          // Check if admin is active
          if (!admin!.isActive) {
            await _authService.signOut();
            setState(() {
              _isLoading = false;
              _errorMessage = 'This admin account has been deactivated.';
            });
            return;
          }

          // Update last login
          await _adminService.updateLastLogin(uid);

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const WebAdminDashboard(),
              ),
            );
          }
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 1000;

          if (isWideScreen) {
            return Row(
              children: [
                // Hero Section (Left)
                Expanded(flex: 5, child: _buildHeroSection()),
                // Login Form Section (Right)
                Expanded(flex: 4, child: _buildLoginSection()),
              ],
            );
          } else {
            // Stacked layout for narrower screens
            return Stack(
              children: [
                // Background gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: WebTheme.heroGradient,
                  ),
                ),
                // Login form overlay
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: _buildLoginCard(),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: const BoxDecoration(gradient: WebTheme.heroGradient),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/app_icon.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Welcome text
                  const Text(
                    'Admin Portal\n7 Pay Services',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Manage orders, users, and services\nfrom your centralized dashboard.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Feature highlights
                  _buildFeatureItem(
                    Icons.dashboard_rounded,
                    'Complete Dashboard',
                  ),
                  const SizedBox(height: 14),
                  _buildFeatureItem(Icons.people_rounded, 'User Management'),
                  const SizedBox(height: 14),
                  _buildFeatureItem(
                    Icons.security_rounded,
                    'Secure Admin Access',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginSection() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: SingleChildScrollView(
          padding: WebTheme.pagePadding,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _buildLoginCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: WebTheme.cardPadding,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: WebTheme.cardRadius,
            boxShadow: WebTheme.elevatedShadow,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Admin Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Admin Access Only',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Text(
                  'Welcome Back',
                  style: WebTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in with your admin credentials',
                  style: WebTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: WebTheme.inputDecoration(
                    labelText: 'Email Address',
                    hintText: 'admin@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: WebTheme.inputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Error Message
                if (_errorMessage != null) ...[
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
                            style: const TextStyle(color: AppTheme.errorColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 16),

                // Sign In Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: WebTheme.primaryButtonStyle,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Security note
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text(
                      'Secure admin authentication',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sign Up Link
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text("Don't have an account? ", style: WebTheme.bodyMedium),
                //     TextButton(
                //       onPressed: () {
                //         Navigator.of(context).pushReplacement(
                //           MaterialPageRoute(
                //             builder: (context) => const WebAdminSignupScreen(),
                //           ),
                //         );
                //       },
                //       child: const Text(
                //         'Sign Up',
                //         style: TextStyle(fontWeight: FontWeight.w600),
                //       ),
                //     ),
                //   ],
                // ),

                // Privacy Policy & Terms Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        final uri = Uri.parse(
                          'https://sevenpayservices.com/privacy-policy-2',
                        );
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.grey[400])),
                    TextButton(
                      onPressed: () {
                        final uri = Uri.parse(
                          'https://sevenpayservices.com/terms-and-conditions',
                        );
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
