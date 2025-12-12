import 'package:flutter/material.dart';
import '../../config/config.dart';

/// Web Dashboard Screen (Admin Panel)
///
/// Admin-only dashboard with sidebar navigation, analytics cards,
/// and data visualization. Optimized for web/desktop interfaces.
class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  int _selectedNavIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(Icons.dashboard_rounded, 'Dashboard'),
    _NavItem(Icons.shopping_bag_rounded, 'Orders'),
    _NavItem(Icons.inventory_2_rounded, 'Products'),
    _NavItem(Icons.people_rounded, 'Customers'),
    _NavItem(Icons.local_shipping_rounded, 'Drivers'),
    _NavItem(Icons.store_rounded, 'Stores'),
    _NavItem(Icons.bar_chart_rounded, 'Analytics'),
    _NavItem(Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(),
          // Main Content Area
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: Column(
                children: [
                  // Top Header Bar
                  _buildTopBar(),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: WebTheme.pagePadding,
                      child: _buildDashboardContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: WebTheme.sidebarWidth,
      decoration: WebTheme.sidebarDecoration,
      child: Column(
        children: [
          // Logo Section
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: WebTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '7 Pay Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                return _buildNavItem(index);
              },
            ),
          ),

          // User Section
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WebTheme.sidebarItemHover,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor,
                  child: const Text(
                    'AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin User',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'admin@gobuddy.com',
                        style: TextStyle(
                          color: WebTheme.sidebarTextMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.logout_rounded,
                  color: WebTheme.sidebarTextMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = index == _selectedNavIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => setState(() => _selectedNavIndex = index),
          borderRadius: BorderRadius.circular(10),
          hoverColor: WebTheme.sidebarItemHover,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? WebTheme.sidebarItemActive.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(
                      color: WebTheme.sidebarItemActive.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isSelected
                      ? WebTheme.sidebarItemActive
                      : WebTheme.sidebarTextMuted,
                ),
                const SizedBox(width: 14),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : WebTheme.sidebarText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: WebTheme.topNavHeight,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Page Title
          Text(
            _navItems[_selectedNavIndex].label,
            style: WebTheme.headlineMedium,
          ),
          const Spacer(),

          // Search Bar
          Container(
            width: 300,
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppTheme.textTertiary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: AppTheme.textTertiary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Notifications
          _buildIconButton(Icons.notifications_outlined, badge: 3),
          const SizedBox(width: 8),
          // Messages
          _buildIconButton(Icons.chat_bubble_outline, badge: 5),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {int? badge}) {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 22),
        ),
        if (badge != null)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards Row
        _buildStatsRow(),
        const SizedBox(height: 32),

        // Charts and Tables Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Chart
            Expanded(flex: 3, child: _buildRevenueChart()),
            const SizedBox(width: 24),
            // Recent Activity
            Expanded(flex: 2, child: _buildRecentActivity()),
          ],
        ),
        const SizedBox(height: 32),

        // Recent Orders Table
        _buildRecentOrders(),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Orders',
            '1,284',
            '+12.5%',
            Icons.shopping_bag_rounded,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            'Revenue',
            '₹4,52,300',
            '+8.2%',
            Icons.currency_rupee_rounded,
            AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            'Active Customers',
            '856',
            '+23.1%',
            Icons.people_rounded,
            AppTheme.accentPurple,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            'Deliveries Today',
            '42',
            '-5.3%',
            Icons.local_shipping_rounded,
            AppTheme.accentOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
  ) {
    final isPositive = change.startsWith('+');

    return Container(
      padding: WebTheme.cardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: WebTheme.cardRadius,
        boxShadow: WebTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPositive ? AppTheme.successBg : AppTheme.errorBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: isPositive
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPositive
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(value, style: WebTheme.displayMedium.copyWith(fontSize: 28)),
          const SizedBox(height: 4),
          Text(title, style: WebTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: WebTheme.cardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: WebTheme.cardRadius,
        boxShadow: WebTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Revenue Overview', style: WebTheme.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('This Month', style: WebTheme.bodyMedium),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Chart placeholder
          Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 48,
                    color: AppTheme.primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Revenue Chart',
                    style: WebTheme.bodyLarge.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      _Activity(
        'New order received',
        '#ORD-2024-001',
        '2 min ago',
        Icons.shopping_bag_rounded,
        AppTheme.primaryColor,
      ),
      _Activity(
        'Payment confirmed',
        '₹1,250',
        '15 min ago',
        Icons.check_circle_rounded,
        AppTheme.successColor,
      ),
      _Activity(
        'New customer signup',
        'john@email.com',
        '1 hour ago',
        Icons.person_add_rounded,
        AppTheme.accentPurple,
      ),
      _Activity(
        'Order delivered',
        '#ORD-2024-098',
        '2 hours ago',
        Icons.local_shipping_rounded,
        AppTheme.secondaryColor,
      ),
      _Activity(
        'Stock low alert',
        'Product #142',
        '3 hours ago',
        Icons.warning_rounded,
        AppTheme.warningColor,
      ),
    ];

    return Container(
      padding: WebTheme.cardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: WebTheme.cardRadius,
        boxShadow: WebTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Activity', style: WebTheme.titleLarge),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map((a) => _buildActivityItem(a)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(_Activity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activity.icon, color: activity.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: WebTheme.labelLarge),
                Text(activity.subtitle, style: WebTheme.bodySmall),
              ],
            ),
          ),
          Text(activity.time, style: WebTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Container(
      padding: WebTheme.cardPadding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: WebTheme.cardRadius,
        boxShadow: WebTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Orders', style: WebTheme.titleLarge),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Order'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildTableHeader('Order ID', 2),
                _buildTableHeader('Customer', 3),
                _buildTableHeader('Items', 1),
                _buildTableHeader('Total', 2),
                _buildTableHeader('Status', 2),
                _buildTableHeader('Actions', 1),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Table Rows
          _buildOrderRow('#ORD-001', 'Rahul Kumar', 3, 1250, 'Delivered'),
          _buildOrderRow('#ORD-002', 'Priya Singh', 5, 2340, 'In Transit'),
          _buildOrderRow('#ORD-003', 'Arun Patel', 2, 890, 'Processing'),
          _buildOrderRow('#ORD-004', 'Meera Sharma', 1, 450, 'Pending'),
          _buildOrderRow('#ORD-005', 'Vikram Reddy', 4, 1780, 'Delivered'),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: WebTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildOrderRow(
    String orderId,
    String customer,
    int items,
    int total,
    String status,
  ) {
    Color statusColor;
    Color statusBg;

    switch (status) {
      case 'Delivered':
        statusColor = AppTheme.successColor;
        statusBg = AppTheme.successBg;
        break;
      case 'In Transit':
        statusColor = AppTheme.infoColor;
        statusBg = AppTheme.infoBg;
        break;
      case 'Processing':
        statusColor = AppTheme.warningColor;
        statusBg = AppTheme.warningBg;
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusBg = AppTheme.surfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(orderId, style: WebTheme.labelLarge)),
          Expanded(
            flex: 3,
            child: Text(
              customer,
              style: WebTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
            ),
          ),
          Expanded(flex: 1, child: Text('$items', style: WebTheme.bodyMedium)),
          Expanded(flex: 2, child: Text('₹$total', style: WebTheme.labelLarge)),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_horiz_rounded,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem(this.icon, this.label);
}

class _Activity {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  _Activity(this.title, this.subtitle, this.time, this.icon, this.color);
}
