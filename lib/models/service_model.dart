import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String type;
  final bool isFavourite;
  final int orderCount;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.type,
    this.isFavourite = false,
    this.orderCount = 0,
    this.isActive = true,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['image_url'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      type: data['type'] ?? '',
      isFavourite: data['is_favourite'] ?? false,
      orderCount: data['order_count'] ?? 0,
      isActive: data['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'type': type,
      'is_favourite': isFavourite,
      'order_count': orderCount,
      'is_active': isActive,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    String? type,
    bool? isFavourite,
    int? orderCount,
    bool? isActive,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      type: type ?? this.type,
      isFavourite: isFavourite ?? this.isFavourite,
      orderCount: orderCount ?? this.orderCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
