import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'web_admin_login.dart';
import 'dashboard_tabs/dashboard_tab.dart';
import 'dashboard_tabs/categories_tab.dart';
import 'dashboard_tabs/services_tab.dart';
import 'dashboard_tabs/orders_tab.dart';
import 'dashboard_tabs/users_tab.dart';
import 'dashboard_tabs/images_tab.dart';
import 'dashboard_tabs/user_support_tab.dart';
import 'dashboard_tabs/help_tab.dart';

/// Web Admin Dashboard
///
/// Admin panel for managing services and viewing orders with auto-refresh
class WebAdminDashboard extends StatefulWidget {
  const WebAdminDashboard({super.key});

  @override
  State<WebAdminDashboard> createState() => _WebAdminDashboardState();
}

class _WebAdminDashboardState extends State<WebAdminDashboard> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  int _selectedIndex = 0;
  bool _isSidebarOpen = true; // Sidebar toggle state

  final List<String> _menuItems = [
    'Dashboard',
    'Categories',
    'Services',
    'Orders',
    'Users',
    'Images',
    'User Support',
    'Help',
    //'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      await _userService.getUser(uid);
      if (mounted) setState(() {});
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      _userService.clearUser();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WebAdminLoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _userService.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar - collapsible
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarOpen ? 260 : 0,
            child: _isSidebarOpen
                ? Container(
                    width: 260,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Logo Header with close button for small screens
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.asset(
                                      'assets/app_icon.jpg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '7 Pay Services',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Admin Panel',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSmallScreen)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () =>
                                      setState(() => _isSidebarOpen = false),
                                ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 1),
                        // Menu Items
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: _menuItems.length,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedIndex == index;
                              return _buildMenuItem(
                                _menuItems[index],
                                _getMenuIcon(index),
                                isSelected,
                                () {
                                  setState(() => _selectedIndex = index);
                                  if (isSmallScreen) {
                                    setState(() => _isSidebarOpen = false);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        // User Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(26),
                            border: const Border(
                              top: BorderSide(color: Colors.white24),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  user?.firstName
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      'A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.fullName ?? 'Admin',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      user?.phoneNumber ?? '',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white70,
                                ),
                                onPressed: _handleLogout,
                                tooltip: 'Logout',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar with hamburger menu
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Hamburger Menu Button
                      IconButton(
                        icon: Icon(
                          _isSidebarOpen ? Icons.menu_open : Icons.menu,
                          color: const Color(0xFF1E293B),
                        ),
                        onPressed: () =>
                            setState(() => _isSidebarOpen = !_isSidebarOpen),
                        tooltip: _isSidebarOpen ? 'Close Menu' : 'Open Menu',
                      ),
                      const SizedBox(width: 8),
                      // Current page title
                      Text(
                        _menuItems[_selectedIndex],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      // Quick actions
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => setState(() {}),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),
                // Content area
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F7FA),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withAlpha(25) // Glass effect
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.white24) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }

  IconData _getMenuIcon(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.category; // Categories
      case 2:
        return Icons.inventory_2; // Services
      case 3:
        return Icons.shopping_cart;
      case 4:
        return Icons.people;
      case 5:
        return Icons.image;
      case 6:
        return Icons.support_agent; // User Support
      case 7:
        return Icons.help_outline; // Help
      // case 8:
      //   return Icons.settings;
      default:
        return Icons.dashboard;
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardTab();
      case 1:
        return const CategoriesTab();
      case 2:
        return const ServicesTab();
      case 3:
        return const OrdersTab();
      case 4:
        return const UsersTab();
      case 5:
        return const ImagesTab();
      case 6:
        return const UserSupportTab();
      case 7:
        return const HelpTab();
      // case 8:
      //   return _buildSettings();
      default:
        return const DashboardTab();
    }
  }
}
