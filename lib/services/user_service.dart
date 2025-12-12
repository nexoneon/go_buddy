import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// User Service
/// Handles all user-related Firestore operations
class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _collection = 'users';

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isProfileComplete => _currentUser?.isProfileComplete ?? false;

  /// Get user by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _firestore.collection(_collection).doc(uid).get();

      _isLoading = false;
      notifyListeners();

      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        return _currentUser;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user: $e');
      _isLoading = false;
      _errorMessage = 'Failed to get user data';
      notifyListeners();
      return null;
    }
  }

  /// Check if user exists in Firestore
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ Error checking user existence: $e');
      return false;
    }
  }

  /// Get user by phone number (for admin verification before OTP)
  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('phone_number', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return UserModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      debugPrint('❌ Error getting user by phone: $e');
      return null;
    }
  }

  /// Create new user in Firestore
  Future<UserModel?> createUser({
    required String uid,
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      final user = UserModel(
        uid: uid,
        phoneNumber: phoneNumber,
        dateJoined: now,
        lastLogin: now,
      );

      await _firestore.collection(_collection).doc(uid).set(user.toFirestore());

      _currentUser = user;
      _isLoading = false;
      notifyListeners();

      debugPrint('✅ New user created: $uid');
      return user;
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      _isLoading = false;
      _errorMessage = 'Failed to create user';
      notifyListeners();
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updates = <String, dynamic>{};

      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (profilePicture != null) updates['profile_picture'] = profilePicture;
      if (address != null) updates['address'] = address;
      if (dateOfBirth != null)
        updates['date_of_birth'] = Timestamp.fromDate(dateOfBirth);
      if (gender != null) updates['gender'] = gender;

      await _firestore.collection(_collection).doc(uid).update(updates);

      // Refresh current user
      await getUser(uid);

      _isLoading = false;
      notifyListeners();

      debugPrint('✅ Profile updated for: $uid');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      _isLoading = false;
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'last_login': Timestamp.now(),
      });
      debugPrint('✅ Last login updated for: $uid');
    } catch (e) {
      debugPrint('❌ Error updating last login: $e');
    }
  }

  /// Upload profile picture to Firebase Storage and return the download URL
  Future<String?> uploadProfilePicture(String uid, Uint8List imageBytes) async {
    try {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath = 'profile_pictures/${uid}_$timestamp.jpg';

      debugPrint('Uploading profile picture to: $storagePath');

      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Profile picture uploaded. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Error uploading profile picture: $e');
      return null;
    }
  }

  /// Delete profile picture from Firebase Storage
  Future<void> deleteProfilePicture(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        final Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
        debugPrint('✅ Profile picture deleted');
      }
    } catch (e) {
      debugPrint('❌ Error deleting profile picture: $e');
    }
  }

  /// Clear current user (on logout)
  void clearUser() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
