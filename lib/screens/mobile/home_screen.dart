import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'main_home_screen.dart';

/// Mobile Home Screen (Splash Screen)
///
/// This is the initial splash screen for mobile applications (Android/iOS).
/// Checks if user is already logged in and navigates accordingly.
class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  static bool _hasNavigated = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Check auth state and navigate after animation
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    if (_hasNavigated) {
      debugPrint('🚀 [HomeScreen] Already navigated once, skipping splash logic');
      return;
    }

    // Wait for splash animation to complete (minimum 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    _hasNavigated = true;

    // Check if user is logged in
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      // Not logged in - go to login screen
      _navigateToLogin();
      return;
    }

    // User is logged in - check if user exists in Firestore
    final uid = currentUser.uid;
    final userExists = await _userService.userExists(uid);

    if (!userExists) {
      // New user - create user document and go to profile screen
      await _userService.createUser(
        uid: uid,
        phoneNumber: currentUser.phoneNumber ?? '',
      );
      _navigateToProfile();
      return;
    }

    // Existing user - get user data
    final user = await _userService.getUser(uid);

    if (user == null) {
      // Error loading user data - go to login
      debugPrint('❌ Error loading user data, redirecting to login');
      _navigateToLogin();
      return;
    }

    // Update last login
    await _userService.updateLastLogin(uid);

    // Check if profile is complete
    if (!user.isProfileComplete) {
      // Profile incomplete - go to profile screen
      _navigateToProfile();
    } else {
      // Profile complete - go to main home screen
      _navigateToMainHome();
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MobileLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToProfile() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MobileProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToMainHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainHomeScreen(),
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
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Container
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Orbiting Service Icons
                        ...List.generate(6, (index) {
                          // Calculate position in a circle
                          final radius = 140.0;
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(
                              milliseconds: 800 + (index * 200),
                            ),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              // Calculate final position
                              final x =
                                  radius *
                                  0.8 *
                                  value *
                                  (index == 0
                                      ? 0
                                      : (index == 1
                                            ? 0.866
                                            : (index == 2
                                                  ? 0.866
                                                  : (index == 3
                                                        ? 0
                                                        : (index == 4
                                                              ? -0.866
                                                              : -0.866)))));
                              final y =
                                  radius *
                                  0.8 *
                                  value *
                                  (index == 0
                                      ? -1
                                      : (index == 1
                                            ? -0.5
                                            : (index == 2
                                                  ? 0.5
                                                  : (index == 3
                                                        ? 1
                                                        : (index == 4
                                                              ? 0.5
                                                              : -0.5)))));

                              return Transform.translate(
                                offset: Offset(x, y),
                                child: Opacity(
                                  opacity: value.clamp(0.0, 1.0),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      [
                                        Icons.cleaning_services,
                                        Icons.plumbing,
                                        Icons.tv,
                                        Icons.local_shipping,
                                        Icons.format_paint,
                                        Icons.electrical_services,
                                      ][index],
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),

                        // Central Logo Container
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(51),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                              BoxShadow(
                                color: AppTheme.primaryColor.withAlpha(30),
                                blurRadius: 60,
                                spreadRadius: -10,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/app_icon.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 130),
                    // App Name
                    const Text(
                      '7 Pay Services',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      'Your Delivery Partner',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(204),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Loading Indicator
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
