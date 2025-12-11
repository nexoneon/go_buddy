import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../config/config.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final OrderService _orderService = OrderService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Check if order is ongoing (not completed or cancelled)
  bool _isOngoing(OrderModel order) {
    final status = order.status.toLowerCase();
    return status != 'completed' && status != 'cancelled';
  }

  // Check if order is completed
  bool _isCompleted(OrderModel order) {
    final status = order.status.toLowerCase();
    return status == 'completed' || status == 'cancelled';
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0D7377),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (user == null)
            TextButton(
              onPressed: () {
                // Navigate to login
              },
              child: const Text(
                'LOGIN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0D7377),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFF0D7377),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'ON GOING'),
                Tab(text: 'COMPLETED'),
              ],
            ),
          ),
        ),
      ),
      body: user == null
          ? _buildNotLoggedIn()
          : StreamBuilder<List<OrderModel>>(
              stream: _orderService.getUserOrders(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allOrders = snapshot.data ?? [];
                final ongoingOrders = allOrders
                    .where((o) => _isOngoing(o))
                    .toList();
                final completedOrders = allOrders
                    .where((o) => _isCompleted(o))
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(ongoingOrders, isOngoing: true),
                    _buildOrdersList(completedOrders, isOngoing: false),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D7377).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.login_outlined,
              size: 60,
              color: Color(0xFF0D7377),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Please login to view your orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track and manage your bookings',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D7377),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Login Now',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, {required bool isOngoing}) {
    if (orders.isEmpty) {
      return _buildEmptyState(isOngoing: isOngoing);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildEmptyState({required bool isOngoing}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOngoing ? Icons.pending_actions_outlined : Icons.task_alt,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isOngoing ? 'No ongoing orders' : 'No completed orders',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOngoing
                ? 'Your active bookings will appear here'
                : 'Your completed bookings will appear here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final statusInfo = _getStatusInfo(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusInfo.color.withAlpha(15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(statusInfo.icon, color: statusInfo.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  statusInfo.label,
                  style: TextStyle(
                    color: statusInfo.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  '#${order.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Order content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Service icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D7377).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.build_outlined,
                        color: Color(0xFF0D7377),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.serviceName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${order.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Info row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value:
                            '${order.bookingDate.day}/${order.bookingDate.month}/${order.bookingDate.year}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: order.bookingTime,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: order.address,
                        isExpandable: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isExpandable = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            maxLines: isExpandable ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _StatusInfo(
          color: Colors.green,
          icon: Icons.check_circle,
          label: 'Completed',
        );
      case 'cancelled':
        return _StatusInfo(
          color: Colors.red,
          icon: Icons.cancel,
          label: 'Cancelled',
        );
      case 'confirmed':
      case 'accepted':
        return _StatusInfo(
          color: Colors.blue,
          icon: Icons.thumb_up,
          label: 'Confirmed',
        );
      case 'in_progress':
        return _StatusInfo(
          color: Colors.purple,
          icon: Icons.directions_run,
          label: 'In Progress',
        );
      case 'hold':
        return _StatusInfo(
          color: Colors.amber,
          icon: Icons.pause_circle,
          label: 'On Hold',
        );
      default:
        return _StatusInfo(
          color: Colors.orange,
          icon: Icons.pending,
          label: 'Pending',
        );
    }
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;
  final String label;

  _StatusInfo({required this.color, required this.icon, required this.label});
}
