import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'web_admin_login.dart';
import 'web_admin_dashboard.dart';

/// Web Bootstrap Screen
///
/// Handles initial app loading, auth state checking, and routing
/// Only allows admin users (staff or superuser)
class WebBootstrapScreen extends StatefulWidget {
  const WebBootstrapScreen({super.key});

  @override
  State<WebBootstrapScreen> createState() => _WebBootstrapScreenState();
}

class _WebBootstrapScreenState extends State<WebBootstrapScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _loadingMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Update loading message
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _loadingMessage = 'Checking authentication...');
    }

    // Check if user is logged in
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      // Not logged in - go to login
      if (mounted) {
        setState(() => _loadingMessage = 'Redirecting to login...');
      }
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToLogin();
      return;
    }

    // User is logged in - check if admin
    if (mounted) {
      setState(() => _loadingMessage = 'Verifying admin access...');
    }

    final uid = currentUser.uid;
    final userExists = await _userService.userExists(uid);

    if (!userExists) {
      // User not in database - logout and redirect
      await _authService.signOut();
      _navigateToLogin();
      return;
    }

    // Get user data
    final user = await _userService.getUser(uid);

    if (user == null) {
      // Error loading user - logout and redirect
      await _authService.signOut();
      _navigateToLogin();
      return;
    }

    // Check if user is admin
    if (!user.isStaff && !user.isSuperuser) {
      // Not admin - logout and redirect
      await _authService.signOut();
      _navigateToLogin();
      return;
    }

    // Admin user - proceed to dashboard
    if (mounted) {
      setState(() => _loadingMessage = 'Loading dashboard...');
    }
    await Future.delayed(const Duration(milliseconds: 500));
    _navigateToDashboard();
  }

  void _navigateToLogin() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WebAdminLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToDashboard() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WebAdminDashboard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(77),
                            blurRadius: 40,
                            spreadRadius: 0,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 56,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // App Name
                    const Text(
                      'Go Buddy Admin',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    const Text(
                      'Admin Control Panel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Loading Indicator
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Loading Message
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _loadingMessage,
                        key: ValueKey(_loadingMessage),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
