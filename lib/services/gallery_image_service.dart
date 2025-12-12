import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/gallery_image_model.dart';

class GalleryImageService {
  final CollectionReference _galleryCollection = FirebaseFirestore.instance
      .collection('gallery_images');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get stream of all gallery images
  Stream<List<GalleryImageModel>> getImages() {
    return _galleryCollection
        .orderBy('uploaded_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return GalleryImageModel.fromFirestore(doc);
          }).toList();
        });
  }

  /// Upload image to Firebase Storage and add to Firestore
  Future<void> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath = 'gallery/$timestamp\_$fileName';

      // Upload to Storage
      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/png',
        ), // Defaulting to png, but could be dynamic
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Add to Firestore
      final newImage = GalleryImageModel(
        id: '', // Firestore will generate ID
        imageUrl: downloadUrl,
        name: fileName,
        uploadedAt: DateTime.now(),
      );

      await _galleryCollection.add(newImage.toFirestore());
    } catch (e) {
      print('Error uploading gallery image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete image from Firestore and Storage
  Future<void> deleteImage(GalleryImageModel image) async {
    try {
      // Delete from Storage
      if (image.imageUrl.isNotEmpty) {
        try {
          final Reference ref = _storage.refFromURL(image.imageUrl);
          await ref.delete();
        } catch (e) {
          print('Error deleting from storage (might remain orphan): $e');
        }
      }

      // Delete from Firestore
      await _galleryCollection.doc(image.id).delete();
    } catch (e) {
      print('Error deleting gallery image: $e');
      throw Exception('Failed to delete image: $e');
    }
  }
}
