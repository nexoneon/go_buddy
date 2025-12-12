import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference _getAddressesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('addresses');
  }

  // Get addresses stream
  Stream<List<AddressModel>> getAddresses(String userId) {
    return _getAddressesCollection(
      userId,
    ).orderBy('created_at', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();
    });
  }

  // Add address
  Future<void> addAddress(String userId, AddressModel address) async {
    final batch = _firestore.batch();
    final colRef = _getAddressesCollection(userId);

    // If setting as default, unset others
    if (address.isDefault) {
      final querySnapshot = await colRef
          .where('is_default', isEqualTo: true)
          .get();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'is_default': false});
      }
    }

    final newDoc = colRef.doc(); // Generate ID
    batch.set(newDoc, {
      ...address.toFirestore(),
      'created_at': FieldValue.serverTimestamp(), // override local time
    });

    await batch.commit();
  }

  // Update address
  Future<void> updateAddress(String userId, AddressModel address) async {
    final batch = _firestore.batch();
    final colRef = _getAddressesCollection(userId);

    // If setting as default, unset others
    if (address.isDefault) {
      final querySnapshot = await colRef
          .where('is_default', isEqualTo: true)
          .get();
      for (var doc in querySnapshot.docs) {
        if (doc.id != address.id) {
          batch.update(doc.reference, {'is_default': false});
        }
      }
    }

    batch.update(colRef.doc(address.id), address.toFirestore());

    await batch.commit();
  }

  // Delete address
  Future<void> deleteAddress(String userId, String addressId) async {
    await _getAddressesCollection(userId).doc(addressId).delete();
  }

  // Set default address
  Future<void> setDefaultAddress(String userId, String addressId) async {
    final batch = _firestore.batch();
    final colRef = _getAddressesCollection(userId);

    // Unset all currently default
    final querySnapshot = await colRef
        .where('is_default', isEqualTo: true)
        .get();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'is_default': false});
    }

    // Set new default
    batch.update(colRef.doc(addressId), {'is_default': true});

    await batch.commit();
  }

  // Get Default or Latest Address
  Future<AddressModel?> getDefaultOrLatestAddress(String userId) async {
    final colRef = _getAddressesCollection(userId);

    // Try to get default
    final defaultSnap = await colRef
        .where('is_default', isEqualTo: true)
        .limit(1)
        .get();
    if (defaultSnap.docs.isNotEmpty) {
      return AddressModel.fromFirestore(defaultSnap.docs.first);
    }

    // Fallback to latest
    final latestSnap = await colRef
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();
    if (latestSnap.docs.isNotEmpty) {
      return AddressModel.fromFirestore(latestSnap.docs.first);
    }

    return null;
  }
}
