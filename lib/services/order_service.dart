import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import 'package:flutter/foundation.dart';

class OrderService {
  final CollectionReference _ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  // Create a new order
  Future<void> createOrder(OrderModel order) async {
    try {
      await _ordersCollection.add(order.toFirestore());
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  // Get orders for a specific user
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _ordersCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromFirestore(doc);
          }).toList();
        });
  }

  // Get all orders (for admin)
  Stream<List<OrderModel>> getAllOrders() {
    return _ordersCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromFirestore(doc);
          }).toList();
        });
  }

  // Check if user has an active/ongoing booking for a specific service
  // Returns true only if there's a pending, accepted, or in_progress order
  Stream<bool> hasUserBookedService(String userId, String serviceId) {
    return _ordersCollection
        .where('user_id', isEqualTo: userId)
        .where('service_id', isEqualTo: serviceId)
        .snapshots()
        .map((snapshot) {
          // Filter for active orders only (not completed or cancelled)
          final activeOrders = snapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] ?? '').toString().toLowerCase();
            // Only consider these statuses as "active" bookings
            return status != 'completed' && status != 'cancelled';
          });
          return activeOrders.isNotEmpty;
        });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _ordersCollection.doc(orderId).update({'status': newStatus});
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }
}
