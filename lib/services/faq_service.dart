import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/faq_model.dart';

class FAQService {
  final CollectionReference _faqCollection = FirebaseFirestore.instance
      .collection('faqs');

  // Get all FAQ items ordered by 'order' field
  Stream<List<FAQModel>> getFAQItems() {
    return _faqCollection.orderBy('order', descending: false).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return FAQModel.fromFirestore(doc);
      }).toList();
    });
  }

  // Add a new FAQ item
  Future<void> addFAQItem(FAQModel item) async {
    try {
      await _faqCollection.add(item.toFirestore());
    } catch (e) {
      debugPrint('Error adding FAQ item: $e');
      rethrow;
    }
  }

  // Update an existing FAQ item
  Future<void> updateFAQItem(FAQModel item) async {
    try {
      await _faqCollection.doc(item.id).update(item.toFirestore());
    } catch (e) {
      debugPrint('Error updating FAQ item: $e');
      rethrow;
    }
  }

  // Delete a FAQ item
  Future<void> deleteFAQItem(String id) async {
    try {
      await _faqCollection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting FAQ item: $e');
      rethrow;
    }
  }

  // Get the next order number
  Future<int> getNextOrder() async {
    try {
      final snapshot = await _faqCollection
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
