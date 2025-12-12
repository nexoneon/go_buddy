import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String userId;
  final String label; // e.g., 'Home', 'Work', 'Other'
  final String addressLine;
  final String city;
  final String zipCode;
  final bool isDefault;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.addressLine,
    required this.city,
    required this.zipCode,
    this.isDefault = false,
    required this.createdAt,
  });

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      label: data['label'] ?? 'Home',
      addressLine: data['address_line'] ?? '',
      city: data['city'] ?? '',
      zipCode: data['zip_code'] ?? '',
      isDefault: data['is_default'] ?? false,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'label': label,
      'address_line': addressLine,
      'city': city,
      'zip_code': zipCode,
      'is_default': isDefault,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  String get fullAddress => '$addressLine, $city - $zipCode';
}
