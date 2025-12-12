import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryImageModel {
  final String id;
  final String imageUrl;
  final String name;
  final DateTime uploadedAt;

  GalleryImageModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.uploadedAt,
  });

  factory GalleryImageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GalleryImageModel(
      id: doc.id,
      imageUrl: data['image_url'] ?? '',
      name: data['name'] ?? '',
      uploadedAt:
          (data['uploaded_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'image_url': imageUrl,
      'name': name,
      'uploaded_at': Timestamp.fromDate(uploadedAt),
    };
  }
}
