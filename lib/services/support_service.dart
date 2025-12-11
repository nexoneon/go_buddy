import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/support_model.dart';

class SupportService {
  final CollectionReference _supportCollection = FirebaseFirestore.instance
      .collection('support');

  // Get all support items ordered by 'order' field
  Stream<List<SupportModel>> getSupportItems() {
    return _supportCollection
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SupportModel.fromFirestore(doc);
          }).toList();
        });
  }

  // Add a new support item
  Future<void> addSupportItem(SupportModel item) async {
    try {
      await _supportCollection.add(item.toFirestore());
    } catch (e) {
      debugPrint('Error adding support item: $e');
      rethrow;
    }
  }

  // Update an existing support item
  Future<void> updateSupportItem(SupportModel item) async {
    try {
      await _supportCollection.doc(item.id).update(item.toFirestore());
    } catch (e) {
      debugPrint('Error updating support item: $e');
      rethrow;
    }
  }

  // Delete a support item
  Future<void> deleteSupportItem(String id) async {
    try {
      await _supportCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting support item: $e');
      rethrow;
    }
  }

  // Get the next order number
  Future<int> getNextOrder() async {
    try {
      final snapshot = await _supportCollection
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
