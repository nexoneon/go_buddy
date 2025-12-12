import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/support_ticket_model.dart';
import 'package:flutter/foundation.dart';

class SupportTicketService {
  final CollectionReference _ticketsCollection = FirebaseFirestore.instance
      .collection('support_tickets');

  // Create a new support ticket
  Future<void> createTicket(SupportTicketModel ticket) async {
    try {
      await _ticketsCollection.add(ticket.toFirestore());
    } catch (e) {
      debugPrint('Error creating support ticket: $e');
      rethrow;
    }
  }

  // Get tickets for a specific user
  Stream<List<SupportTicketModel>> getUserTickets(String userId) {
    return _ticketsCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SupportTicketModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get all tickets (for admin)
  Stream<List<SupportTicketModel>> getAllTickets() {
    return _ticketsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SupportTicketModel.fromFirestore(doc))
              .toList();
        });
  }

  // Update ticket status
  Future<void> updateTicketStatus(String ticketId, String newStatus) async {
    try {
      await _ticketsCollection.doc(ticketId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating ticket status: $e');
      rethrow;
    }
  }
}
