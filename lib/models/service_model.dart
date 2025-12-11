import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final double price;
  final String categoryId;
  final bool isFavourite;
  final bool isActive;

  // Additional information fields
  final String? customerResponsibility;
  final String? providerResponsibility;
  final String? note;
  final String? goBuddyCares;
  final bool accept;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    this.categoryId = '',
    this.isFavourite = false,
    this.isActive = true,
    this.customerResponsibility,
    this.providerResponsibility,
    this.note,
    this.goBuddyCares,
    this.accept = true,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      categoryId: data['category_id'] ?? '',
      isFavourite: data['is_favourite'] ?? false,
      isActive: data['is_active'] ?? true,
      customerResponsibility: data['customer_responsibility'],
      providerResponsibility: data['provider_responsibility'],
      note: data['note'],
      goBuddyCares: data['go_buddy_cares'],
      accept: data['accept'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'category_id': categoryId,
      'is_favourite': isFavourite,
      'is_active': isActive,
      'customer_responsibility': customerResponsibility,
      'provider_responsibility': providerResponsibility,
      'note': note,
      'go_buddy_cares': goBuddyCares,
      'accept': accept,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    double? price,
    String? categoryId,
    bool? isFavourite,
    bool? isActive,
    String? customerResponsibility,
    String? providerResponsibility,
    String? note,
    String? goBuddyCares,
    bool? accept,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      isFavourite: isFavourite ?? this.isFavourite,
      isActive: isActive ?? this.isActive,
      customerResponsibility:
          customerResponsibility ?? this.customerResponsibility,
      providerResponsibility:
          providerResponsibility ?? this.providerResponsibility,
      note: note ?? this.note,
      goBuddyCares: goBuddyCares ?? this.goBuddyCares,
      accept: accept ?? this.accept,
    );
  }
}
