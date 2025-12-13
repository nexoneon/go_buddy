import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin Model
/// Represents the admin user stored in Firestore for web admin login
class AdminModel {
  final String uid;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final DateTime? lastLogin;
  final DateTime dateJoined;

  AdminModel({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.isActive = true,
    this.isStaff = false,
    this.isSuperuser = true,
    this.lastLogin,
    required this.dateJoined,
  });

  /// Get full name
  String get fullName {
    if (firstName == null && lastName == null) return '';
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// Create from Firestore document
  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      uid: doc.id,
      email: data['email'] ?? '',
      firstName: data['first_name'],
      lastName: data['last_name'],
      profilePicture: data['profile_picture'],
      isActive: data['is_active'] ?? true,
      isStaff: data['is_staff'] ?? false,
      isSuperuser: data['is_superuser'] ?? true,
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
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'last_login': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'date_joined': Timestamp.fromDate(dateJoined),
    };
  }

  /// Create a copy with updated fields
  AdminModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? profilePicture,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    DateTime? lastLogin,
    DateTime? dateJoined,
  }) {
    return AdminModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicture: profilePicture ?? this.profilePicture,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      lastLogin: lastLogin ?? this.lastLogin,
      dateJoined: dateJoined ?? this.dateJoined,
    );
  }
}
