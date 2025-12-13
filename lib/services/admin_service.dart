import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/admin_model.dart';

/// Admin Service
/// Handles all admin-related Firestore operations (separate from regular users)
class AdminService extends ChangeNotifier {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'admins';

  AdminModel? _currentAdmin;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AdminModel? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get admin by UID
  Future<AdminModel?> getAdmin(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _firestore.collection(_collection).doc(uid).get();

      _isLoading = false;
      notifyListeners();

      if (doc.exists) {
        _currentAdmin = AdminModel.fromFirestore(doc);
        return _currentAdmin;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting admin: $e');
      _isLoading = false;
      _errorMessage = 'Failed to get admin data';
      notifyListeners();
      return null;
    }
  }

  /// Check if admin exists in Firestore
  Future<bool> adminExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ Error checking admin existence: $e');
      return false;
    }
  }

  /// Get admin by email (for verification before login)
  Future<AdminModel?> getAdminByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return AdminModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      debugPrint('❌ Error getting admin by email: $e');
      return null;
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'last_login': Timestamp.now(),
      });
      debugPrint('✅ Admin last login updated for: $uid');
    } catch (e) {
      debugPrint('❌ Error updating admin last login: $e');
    }
  }

  /// Create new admin in Firestore
  Future<bool> createAdmin(AdminModel admin) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection(_collection)
          .doc(admin.uid)
          .set(admin.toFirestore());

      _currentAdmin = admin;
      _isLoading = false;
      notifyListeners();

      debugPrint('✅ New admin created: ${admin.uid}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating admin: $e');
      _isLoading = false;
      _errorMessage = 'Failed to create admin account';
      notifyListeners();
      return false;
    }
  }

  /// Update admin profile
  Future<bool> updateAdmin({
    required String uid,
    String? firstName,
    String? lastName,
    String? profilePicture,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updates = <String, dynamic>{};
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (profilePicture != null) updates['profile_picture'] = profilePicture;

      await _firestore.collection(_collection).doc(uid).update(updates);

      // Update local admin
      if (_currentAdmin != null) {
        _currentAdmin = _currentAdmin!.copyWith(
          firstName: firstName ?? _currentAdmin!.firstName,
          lastName: lastName ?? _currentAdmin!.lastName,
          profilePicture: profilePicture ?? _currentAdmin!.profilePicture,
        );
      }

      _isLoading = false;
      notifyListeners();

      debugPrint('✅ Admin updated: $uid');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating admin: $e');
      _isLoading = false;
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  /// Clear current admin (on logout)
  void clearAdmin() {
    _currentAdmin = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
