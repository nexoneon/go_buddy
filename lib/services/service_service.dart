import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceService {
  final CollectionReference _servicesCollection = FirebaseFirestore.instance
      .collection('services');

  /// Get stream of all services
  Stream<List<ServiceModel>> getServices() {
    return _servicesCollection
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ServiceModel.fromFirestore(doc);
          }).toList();
        });
  }

  /// Get stream of services by category
  Stream<List<ServiceModel>> getServicesByCategory(String categoryId) {
    return _servicesCollection
        .where('is_active', isEqualTo: true)
        .where('category_id', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ServiceModel.fromFirestore(doc);
          }).toList();
        });
  }

  /// Get specific service by ID
  Future<ServiceModel?> getServiceById(String id) async {
    try {
      final doc = await _servicesCollection.doc(id).get();
      if (doc.exists) {
        return ServiceModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting service: $e');
      return null;
    }
  }
}
