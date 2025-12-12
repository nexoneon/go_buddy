import 'package:cloud_firestore/cloud_firestore.dart';

class SupportModel {
  final String id;
  final String type; // 'contact', 'hours', 'address'
  final String title;
  final String value;
  final String? subtitle;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportModel({
    required this.id,
    required this.type,
    required this.title,
    required this.value,
    this.subtitle,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportModel(
      id: doc.id,
      type: data['type'] ?? 'contact',
      title: data['title'] ?? '',
      value: data['value'] ?? '',
      subtitle: data['subtitle'],
      order: data['order'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'value': value,
      'subtitle': subtitle,
      'order': order,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  SupportModel copyWith({
    String? id,
    String? type,
    String? title,
    String? value,
    String? subtitle,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      value: value ?? this.value,
      subtitle: subtitle ?? this.subtitle,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
