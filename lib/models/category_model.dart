import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconCode; // Store icon code point as string or name
  final int color; // Store color as int (0xAARRGGBB)
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.color,
    this.isActive = true,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      iconCode: data['icon_code'] ?? '',
      color: data['color'] ?? 0xFF000000,
      isActive: data['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon_code': iconCode,
      'color': color,
      'is_active': isActive,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconCode,
    int? color,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
    );
  }
}
