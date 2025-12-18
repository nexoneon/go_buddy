import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../config/config.dart';
import '../../../models/order_model.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Orders',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'All Orders'),
                Tab(text: 'Pending'),
                Tab(text: 'In Progress'),
                Tab(text: 'On Hold'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              children: [
                _buildOrdersTab(null), // All
                _buildOrdersTab('pending'),
                _buildOrdersTab('in_progress'),
                _buildOrdersTab('hold'),
                _buildOrdersTab('completed'),
                _buildOrdersTab('cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(String? statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('created_at', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var orders = snapshot.data?.docs ?? [];

        // Filter by status if specified
        if (statusFilter != null) {
          orders = orders.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == statusFilter;
          }).toList();
        }

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  statusFilter == null
                      ? 'No orders yet'
                      : 'No ${statusFilter.replaceAll('_', ' ')} orders',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderDoc = orders[index];
            final order = orderDoc.data() as Map<String, dynamic>;
            final currentStatus = OrderStatus.fromString(
              order['status'] ?? 'pending',
            );

            // Format Created At
            String createdDateStr = 'Unknown';
            if (order['created_at'] != null) {
              final timestamp = order['created_at'] as Timestamp;
              final date = timestamp.toDate();
              createdDateStr =
                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
            }

            // Format Booking/Schedule Date
            String scheduleDateStr = 'Not scheduled';
            if (order['booking_date'] != null) {
              final timestamp = order['booking_date'] as Timestamp;
              final date = timestamp.toDate();
              scheduleDateStr = '${date.day}/${date.month}/${date.year}';
            }

            // Booking Time
            final bookingTime = order['booking_time'] ?? 'No time';

            // Address
            final address = order['address'] ?? 'No address';

            // Rating
            final rating = order['rating']?.toDouble() ?? 0.0;

            // Order ID (short version)
            final orderId = orderDoc.id.length > 8
                ? orderDoc.id.substring(0, 8).toUpperCase()
                : orderDoc.id.toUpperCase();

            // Fetch user details
            final userId = order['user_id'] as String?;

            return FutureBuilder<DocumentSnapshot>(
              future: userId != null && userId.isNotEmpty
                  ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get()
                  : null,
              builder: (context, userSnapshot) {
                // Get user name from the fetched user document
                String userName = 'Unknown';
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData != null) {
                    final firstName = userData['first_name'] ?? '';
                    final lastName = userData['last_name'] ?? '';
                    final fullName = '$firstName $lastName'.trim();
                    userName = fullName.isNotEmpty ? fullName : 'Unknown';
                  }
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Order ID, service name, status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#$orderId',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order['service_name'] ?? 'Unknown Service',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${order['amount']?.toStringAsFixed(0) ?? '0'}',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  currentStatus,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getStatusColor(currentStatus),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<OrderStatus>(
                                  value: currentStatus,
                                  isDense: true,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: _getStatusColor(currentStatus),
                                    size: 20,
                                  ),
                                  items: OrderStatus.values.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        status.displayName,
                                        style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newStatus) async {
                                    if (newStatus != null &&
                                        newStatus != currentStatus) {
                                      await FirebaseFirestore.instance
                                          .collection('orders')
                                          .doc(orderDoc.id)
                                          .update({'status': newStatus.value});

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Status updated to ${newStatus.displayName}',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        // Customer info row
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildOrderInfoChip(
                              Icons.person,
                              userName,
                              Colors.blue,
                            ),
                            _buildOrderInfoChip(
                              Icons.phone,
                              order['user_phone'] ?? 'No phone',
                              Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Address row
                        _buildOrderInfoChip(
                          Icons.location_on,
                          address,
                          Colors.red,
                        ),
                        const SizedBox(height: 8),
                        // Schedule and Created time row
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildOrderInfoChip(
                              Icons.event,
                              'Schedule: $scheduleDateStr',
                              Colors.purple,
                            ),
                            _buildOrderInfoChip(
                              Icons.schedule,
                              'Time: $bookingTime',
                              Colors.orange,
                            ),
                            _buildOrderInfoChip(
                              Icons.access_time,
                              'Ordered: $createdDateStr',
                              Colors.grey,
                            ),
                          ],
                        ),
                        // Rating (only show if order is completed and has rating)
                        if (currentStatus == OrderStatus.completed &&
                            rating > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Rating: ${rating.toStringAsFixed(1)}/5',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Customer Instructions (if any)
                        if (order['customer_instructions'] != null &&
                            (order['customer_instructions'] as String)
                                .isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.message_outlined,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Customer Instructions:',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        order['customer_instructions']
                                            as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[800],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.purple;
      case OrderStatus.hold:
        return Colors.amber;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
