import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final CollectionReference _categoriesCollection = FirebaseFirestore.instance
      .collection('categories');

  /// Get stream of all active categories
  Stream<List<CategoryModel>> getCategories() {
    return _categoriesCollection
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CategoryModel.fromFirestore(doc);
          }).toList();
        });
  }

  /// Get stream of all categories (including inactive) for Admin
  Stream<List<CategoryModel>> getAllCategories() {
    return _categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Add a new category
  Future<void> addCategory(CategoryModel category) async {
    await _categoriesCollection.add(category.toFirestore());
  }

  /// Update an existing category
  Future<void> updateCategory(CategoryModel category) async {
    await _categoriesCollection.doc(category.id).update(category.toFirestore());
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    await _categoriesCollection.doc(id).delete();
  }
}
