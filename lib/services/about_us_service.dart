import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/about_us_model.dart';

class AboutUsService {
  final CollectionReference _aboutUsCollection = FirebaseFirestore.instance
      .collection('about_us');

  // Get all about us items ordered by 'order' field
  Stream<List<AboutUsModel>> getAboutUsItems() {
    return _aboutUsCollection
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AboutUsModel.fromFirestore(doc);
          }).toList();
        });
  }

  // Add a new about us item
  Future<void> addAboutUsItem(AboutUsModel item) async {
    try {
      await _aboutUsCollection.add(item.toFirestore());
    } catch (e) {
      debugPrint('Error adding about us item: $e');
      rethrow;
    }
  }

  // Update an existing about us item
  Future<void> updateAboutUsItem(AboutUsModel item) async {
    try {
      await _aboutUsCollection.doc(item.id).update(item.toFirestore());
    } catch (e) {
      debugPrint('Error updating about us item: $e');
      rethrow;
    }
  }

  // Delete an about us item
  Future<void> deleteAboutUsItem(String id) async {
    try {
      await _aboutUsCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting about us item: $e');
      rethrow;
    }
  }

  // Get the next order number
  Future<int> getNextOrder() async {
    try {
      final snapshot = await _aboutUsCollection
          .orderBy('order', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        return 1;
      }
      final lastOrder =
          (snapshot.docs.first.data() as Map<String, dynamic>)['order'] ?? 0;
      return lastOrder + 1;
    } catch (e) {
      debugPrint('Error getting next order: $e');
      return 1;
    }
  }
}
