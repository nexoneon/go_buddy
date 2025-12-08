import 'package:flutter/foundation.dart';

/// Authentication Service
/// Handles user authentication state and login/logout functionality
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;
  bool _isInitialized = false;
  String? _userEmail;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  /// Initialize the auth service and check for existing session
  Future<void> initialize() async {
    // Simulate checking for existing session (e.g., from localStorage or Firebase)
    await Future.delayed(const Duration(milliseconds: 1500));

    // TODO: Replace with actual session check
    // For now, we'll default to not authenticated
    _isAuthenticated = false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual authentication logic
      // For demo, accept any non-empty credentials
      if (email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _userEmail = email;
        _userName = email.split('@').first;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    notifyListeners();
  }
}
