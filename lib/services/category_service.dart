import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/category_model.dart';

class CategoryService {
  final CollectionReference _categoriesCollection = FirebaseFirestore.instance
      .collection('categories');
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  /// Upload category image to Firebase Storage and return the download URL
  Future<String> uploadCategoryImage(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      // Create a unique file name with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath = 'categories/${timestamp}_$fileName';

      print('Uploading image to: $storagePath');

      // Upload image to Firebase Storage
      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/png'),
      );

      // Wait for upload to complete and get download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully. URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete category image from Firebase Storage
  Future<void> deleteCategoryImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        final Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      // Image might not exist, ignore error
      print('Failed to delete image: $e');
    }
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
