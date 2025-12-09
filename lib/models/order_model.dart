import 'package:cloud_firestore/cloud_firestore.dart';

/// Order status types
enum OrderStatus {
  pending,
  accepted,
  inProgress,
  hold,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.hold:
        return 'On Hold';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.hold:
        return 'hold';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return OrderStatus.accepted;
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'hold':
        return OrderStatus.hold;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final String serviceImageUrl;
  final double amount;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final DateTime bookingDate;
  final String bookingTime;
  final String address;
  final String userPhone;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.serviceImageUrl,
    required this.amount,
    required this.status,
    required this.bookingDate,
    required this.bookingTime,
    required this.address,
    required this.userPhone,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      serviceId: data['service_id'] ?? '',
      serviceName: data['service_name'] ?? '',
      serviceImageUrl: data['service_image_url'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      bookingDate: (data['booking_date'] as Timestamp).toDate(),
      bookingTime: data['booking_time'] ?? '',
      address: data['address'] ?? '',
      userPhone: data['user_phone'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'service_id': serviceId,
      'service_name': serviceName,
      'service_image_url': serviceImageUrl,
      'amount': amount,
      'status': status,
      'booking_date': Timestamp.fromDate(bookingDate),
      'booking_time': bookingTime,
      'address': address,
      'user_phone': userPhone,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? serviceName,
    String? serviceImageUrl,
    double? amount,
    String? status,
    DateTime? bookingDate,
    String? bookingTime,
    String? address,
    String? userPhone,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceImageUrl: serviceImageUrl ?? this.serviceImageUrl,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      address: address ?? this.address,
      userPhone: userPhone ?? this.userPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
