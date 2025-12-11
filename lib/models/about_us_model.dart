import 'package:cloud_firestore/cloud_firestore.dart';

class AboutUsModel {
  final String id;
  final String header;
  final String description;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  AboutUsModel({
    required this.id,
    required this.header,
    required this.description,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AboutUsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AboutUsModel(
      id: doc.id,
      header: data['header'] ?? '',
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'header': header,
      'description': description,
      'order': order,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  AboutUsModel copyWith({
    String? id,
    String? header,
    String? description,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AboutUsModel(
      id: id ?? this.id,
      header: header ?? this.header,
      description: description ?? this.description,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
