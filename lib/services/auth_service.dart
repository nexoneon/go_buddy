import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Authentication Service
/// Handles user authentication state and Firebase phone authentication
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;
  String? _phoneNumber;
  String? _errorMessage;

  // Getters
  bool get isAuthenticated => _auth.currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  User? get currentUser => _auth.currentUser;
  String? get userPhone => _auth.currentUser?.phoneNumber ?? _phoneNumber;
  String? get userName => _auth.currentUser?.displayName;
  String? get errorMessage => _errorMessage;
  String? get verificationId => _verificationId;
  bool get isVerifying => _verificationId != null;

  /// Initialize the auth service
  Future<void> initialize() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });

    _isInitialized = true;
    notifyListeners();
  }

  /// Send OTP to phone number
  /// [phoneNumber] should include country code, e.g., "+91XXXXXXXXXX"
  Future<bool> sendOTP({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String errorMessage) onError,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _phoneNumber = phoneNumber;
      notifyListeners();

      debugPrint('📱 Sending OTP to: $phoneNumber');

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          debugPrint('✅ Auto-verification completed');
          _isLoading = false;
          notifyListeners();
          onVerificationCompleted(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Verification failed: ${e.code} - ${e.message}');
          _isLoading = false;
          _errorMessage = _getErrorMessage(e.code);
          notifyListeners();
          onError('${_errorMessage!} (${e.code})');
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint(
            '📨 OTP Code sent successfully! VerificationId: $verificationId',
          );
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isLoading = false;
          notifyListeners();
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏰ Auto-retrieval timeout');
          _verificationId = verificationId;
          notifyListeners();
        },
        forceResendingToken: _resendToken,
      );

      return true;
    } catch (e) {
      debugPrint('🔥 Exception in sendOTP: $e');
      _isLoading = false;
      _errorMessage = 'Failed to send OTP: ${e.toString()}';
      notifyListeners();
      onError(_errorMessage!);
      return false;
    }
  }

  /// Verify OTP and sign in
  Future<bool> verifyOTP({
    required String otp,
    required Function() onSuccess,
    required Function(String errorMessage) onError,
  }) async {
    if (_verificationId == null) {
      onError('Verification session expired. Please request OTP again.');
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // Sign in with credential
      await _auth.signInWithCredential(credential);

      _isLoading = false;
      _verificationId = null;
      notifyListeners();
      onSuccess();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      onError(_errorMessage!);
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Verification failed. Please try again.';
      notifyListeners();
      onError(_errorMessage!);
      return false;
    }
  }

  /// Sign in with credential (for auto-verification)
  Future<bool> signInWithCredential(PhoneAuthCredential credential) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithCredential(credential);

      _isLoading = false;
      _verificationId = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Sign in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
    _phoneNumber = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Delete the current user's account
  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      if (e.code == 'requires-recent-login') {
        _errorMessage =
            'This operation is sensitive and requires recent authentication. Please log in again before retrying this action.';
      }
      notifyListeners();
      debugPrint('❌ Error deleting account: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete account. Please try again.';
      notifyListeners();
      debugPrint('❌ Error deleting account: $e');
      return false;
    }
  }

  /// Sign in with email and password (for admin web login)
  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
    required Function() onSuccess,
    required Function(String errorMessage) onError,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🔐 Signing in with email: $email');

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _isLoading = false;
      notifyListeners();
      onSuccess();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getEmailErrorMessage(e.code);
      notifyListeners();
      onError(_errorMessage!);
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Sign in failed. Please try again.';
      notifyListeners();
      onError(_errorMessage!);
      return false;
    }
  }

  /// Get user-friendly error message for email auth
  String _getEmailErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Sign in failed. Please check your credentials.';
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please check and try again.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'session-expired':
        return 'Session expired. Please request OTP again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset verification state
  void resetVerification() {
    _verificationId = null;
    _resendToken = null;
    _errorMessage = null;
    notifyListeners();
  }
}
