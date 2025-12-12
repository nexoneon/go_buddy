import 'package:cloud_firestore/cloud_firestore.dart';

/// User Model
/// Represents the user profile stored in Firestore
class UserModel {
  final String uid;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final DateTime? lastLogin;
  final DateTime dateJoined;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.isActive = true,
    this.isStaff = false,
    this.isSuperuser = false,
    this.lastLogin,
    required this.dateJoined,
  });

  /// Check if profile is complete (has required fields filled)
  bool get isProfileComplete =>
      firstName != null &&
      firstName!.isNotEmpty &&
      lastName != null &&
      lastName!.isNotEmpty;

  /// Get full name
  String get fullName {
    if (firstName == null && lastName == null) return '';
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      phoneNumber: data['phone_number'] ?? '',
      firstName: data['first_name'],
      lastName: data['last_name'],
      profilePicture: data['profile_picture'],
      address: data['address'],
      dateOfBirth: data['date_of_birth'] != null
          ? (data['date_of_birth'] as Timestamp).toDate()
          : null,
      gender: data['gender'],
      isActive: data['is_active'] ?? true,
      isStaff: data['is_staff'] ?? false,
      isSuperuser: data['is_superuser'] ?? false,
      lastLogin: data['last_login'] != null
          ? (data['last_login'] as Timestamp).toDate()
          : null,
      dateJoined: data['date_joined'] != null
          ? (data['date_joined'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'address': address,
      'date_of_birth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'gender': gender,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'last_login': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'date_joined': Timestamp.fromDate(dateJoined),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    DateTime? lastLogin,
    DateTime? dateJoined,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicture: profilePicture ?? this.profilePicture,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      lastLogin: lastLogin ?? this.lastLogin,
      dateJoined: dateJoined ?? this.dateJoined,
    );
  }
}
