import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

/// Service for managing user favourites
class FavouriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the favourites collection reference for a user
  CollectionReference _getUserFavouritesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('favourites');
  }

  /// Add a service to user's favourites
  Future<void> addToFavourites(String userId, ServiceModel service) async {
    await _getUserFavouritesCollection(userId).doc(service.id).set({
      'service_id': service.id,
      'service_name': service.name,
      'service_price': service.price,
      'service_note': service.note,
      'added_at': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a service from user's favourites
  Future<void> removeFromFavourites(String userId, String serviceId) async {
    await _getUserFavouritesCollection(userId).doc(serviceId).delete();
  }

  /// Check if a service is in user's favourites
  Future<bool> isFavourite(String userId, String serviceId) async {
    final doc = await _getUserFavouritesCollection(userId).doc(serviceId).get();
    return doc.exists;
  }

  /// Stream to check if a service is in favourites (real-time)
  Stream<bool> isFavouriteStream(String userId, String serviceId) {
    return _getUserFavouritesCollection(
      userId,
    ).doc(serviceId).snapshots().map((doc) => doc.exists);
  }

  /// Get all user's favourite service IDs
  Stream<List<String>> getFavouriteIds(String userId) {
    return _getUserFavouritesCollection(userId)
        .orderBy('added_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Get all user's favourite services as ServiceModel list
  Stream<List<ServiceModel>> getFavouriteServices(String userId) {
    return _getUserFavouritesCollection(userId)
        .orderBy('added_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final List<ServiceModel> services = [];

          for (final doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final serviceId = data['service_id'] as String;

            // Fetch the actual service to get latest data
            final serviceDoc = await _firestore
                .collection('services')
                .doc(serviceId)
                .get();

            if (serviceDoc.exists) {
              services.add(ServiceModel.fromFirestore(serviceDoc));
            }
          }

          return services;
        });
  }

  /// Toggle favourite status
  Future<bool> toggleFavourite(String userId, ServiceModel service) async {
    final isFav = await isFavourite(userId, service.id);

    if (isFav) {
      await removeFromFavourites(userId, service.id);
      return false;
    } else {
      await addToFavourites(userId, service);
      return true;
    }
  }
}
