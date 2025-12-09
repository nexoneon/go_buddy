import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';

import 'package:flutter/services.dart';
import '../../config/config.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/service_model.dart';
import '../../models/user_model.dart';
import '../../models/category_model.dart';
import '../../models/order_model.dart';
import '../../services/category_service.dart';
import 'web_admin_login.dart';

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
  final CategoryService _categoryService = CategoryService();
  int _selectedIndex = 0;

  final List<String> _menuItems = [
    'Dashboard',
    'Categories',
    'Services',
    'Orders',
    'Users',
    'Settings',
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

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                // Logo Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Go Buddy',
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
                        () => setState(() => _selectedIndex = index),
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
                          user?.firstName?.substring(0, 1).toUpperCase() ?? 'A',
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
                        icon: const Icon(Icons.logout, color: Colors.white70),
                        onPressed: _handleLogout,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7FA),
              child: _buildContent(),
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
            ? AppTheme.primaryColor.withAlpha(51)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        return Icons.settings;
      default:
        return Icons.dashboard;
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildCategories();
      case 2:
        return _buildServices();
      case 3:
        return _buildOrders();
      case 4:
        return _buildUsers();
      case 5:
        return _buildSettings();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Stats Cards with real data
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('services')
                .snapshots(),
            builder: (context, servicesSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .snapshots(),
                builder: (context, ordersSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, usersSnapshot) {
                      final servicesCount =
                          servicesSnapshot.data?.docs.length ?? 0;
                      final ordersCount = ordersSnapshot.data?.docs.length ?? 0;
                      final usersCount = usersSnapshot.data?.docs.length ?? 0;

                      // Calculate total revenue
                      double totalRevenue = 0;
                      if (ordersSnapshot.hasData) {
                        for (var doc in ordersSnapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] ?? '';
                          if (status == 'completed') {
                            totalRevenue += (data['amount'] ?? 0).toDouble();
                          }
                        }
                      }

                      return GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatCard(
                            'Total Services',
                            '$servicesCount',
                            Icons.inventory_2,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'Total Orders',
                            '$ordersCount',
                            Icons.shopping_cart,
                            Colors.green,
                          ),
                          _buildStatCard(
                            'Total Users',
                            '$usersCount',
                            Icons.people,
                            Colors.orange,
                          ),
                          _buildStatCard(
                            'Revenue',
                            '₹${totalRevenue.toStringAsFixed(0)}',
                            Icons.currency_rupee,
                            Colors.purple,
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
          // Recent Orders Section
          const Text(
            'Recent Orders',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('created_at', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No recent orders',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final order =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                    final status = OrderStatus.fromString(
                      order['status'] ?? 'pending',
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(
                          status,
                        ).withValues(alpha: 0.1),
                        child: Icon(
                          Icons.shopping_bag,
                          color: _getStatusColor(status),
                        ),
                      ),
                      title: Text(
                        order['service_name'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(order['user_phone'] ?? ''),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.displayName,
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Categories Management Section ---

  Widget _buildCategories() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              const Text(
                'Categories',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditCategoryDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<CategoryModel>>(
            stream: _categoryService.getAllCategories(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return const Center(
                  child: Text(
                    'No categories found. Add one!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 220,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(categories[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    // Try to parse icon hex/code
    // IconData iconData = Icons.category; // Unused
    // For simplicity we might just use a standard icon if we can't parse,
    // or let the user pick from a set.
    // Here we'll just use a circle with the color.

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withAlpha(26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(category.color).withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category, // Replace with dynamic icon later
              size: 32,
              color: Color(category.color),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: category.isActive
                  ? Colors.green.withAlpha(26)
                  : Colors.red.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: category.isActive ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _showAddEditCategoryDialog(category: category),
                icon: const Icon(Icons.edit, size: 20),
                color: Colors.blue,
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _deleteCategory(category.id),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red,
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddEditCategoryDialog({CategoryModel? category}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.name ?? '');
    // Simple color picker workaround: just inputs for now or preset
    Color selectedColor = category != null
        ? Color(category.color)
        : Colors.blue;
    bool isActive = category?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(category == null ? 'Add Category' : 'Edit Category'),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    // Color Picker (Simplified)
                    Row(
                      children: [
                        const Text('Color: '),
                        const SizedBox(width: 8),
                        ...[
                          Colors.blue,
                          Colors.red,
                          Colors.green,
                          Colors.orange,
                          Colors.purple,
                          Colors.teal,
                        ].map((c) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedColor = c),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: selectedColor == c
                                    ? Border.all(color: Colors.black, width: 2)
                                    : null,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                    ); // Close dialog first? Or valid logic

                    final newCategory = CategoryModel(
                      id: category?.id ?? '', // ID handled by firestore for add
                      name: nameController.text.trim(),
                      iconCode: '', // Default for now
                      color: selectedColor.value,
                      isActive: isActive,
                    );

                    try {
                      if (category == null) {
                        await _categoryService.addCategory(newCategory);
                      } else {
                        await _categoryService.updateCategory(newCategory);
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              category == null
                                  ? 'Category added successfully'
                                  : 'Category updated successfully',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteCategory(String id) async {
    // First check if any services use this category
    final servicesSnapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('category_id', isEqualTo: id)
        .get();

    if (servicesSnapshot.docs.isNotEmpty) {
      // Category has services assigned - show warning
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text('Cannot Delete'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This category is assigned to ${servicesSnapshot.docs.length} service(s):',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: servicesSnapshot.docs.map((doc) {
                        final data = doc.data();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data['name'] ?? 'Unknown Service',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please reassign or delete these services before deleting the category.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // No services assigned - proceed with delete confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _categoryService.deleteCategory(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // --- Services Management Section ---

  Widget _buildServices() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              const Text(
                'Services',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditServiceDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('services')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No services found. Add one!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 340, // Fixed height for consistency
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final service = ServiceModel.fromFirestore(docs[index]);
                  return _buildServiceCard(service);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Container(
              color: Colors.grey[100],
              child: service.imageUrl.isNotEmpty
                  ? Image.network(
                      service.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (service.isFavourite)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service.type,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${service.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service.orderCount}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showAddEditServiceDialog(service: service),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _deleteService(service.id),
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red[400],
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditServiceDialog({ServiceModel? service}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: service?.name ?? '');
    final imageUrlController = TextEditingController(
      text: service?.imageUrl ?? '',
    );
    final priceController = TextEditingController(
      text: service?.price.toString() ?? '',
    );
    final typeController = TextEditingController(text: service?.type ?? '');
    final orderCountController = TextEditingController(
      text: service?.orderCount.toString() ?? '0',
    );
    bool isFavourite = service?.isFavourite ?? false;
    String? selectedCategoryId = service?.categoryId.isNotEmpty == true
        ? service!.categoryId
        : null;
    // Uint8List? webImage;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Future<void> pickImage() async {
          //   try {
          //     final ImagePicker picker = ImagePicker();
          //     final XFile? image = await picker.pickImage(
          //       source: ImageSource.gallery,
          //     );
          //     if (image != null) {
          //       final bytes = await image.readAsBytes();
          //       setState(() {
          //         webImage = bytes;
          //         imageUrlController.text = 'Uploading...';
          //       });
          //     }
          //   } catch (e) {
          //     debugPrint('Error picking image: $e');
          //   }
          // }

          // Future<String?> uploadImage(String serviceName) async {
          //   if (webImage == null) return null;
          //   try {
          //     final fileName =
          //         '${serviceName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          //     final ref = FirebaseStorage.instance
          //         .ref()
          //         .child('service_images')
          //         .child(fileName);

          //     final metadata = SettableMetadata(contentType: 'image/jpeg');
          //     await ref.putData(webImage!, metadata);
          //     final url = await ref.getDownloadURL();
          //     return url;
          //   } catch (e) {
          //     debugPrint('Error uploading image: $e');
          //     return null;
          //   }
          // }

          return AlertDialog(
            title: Text(service == null ? 'Add Service' : 'Edit Service'),
            content: SizedBox(
              width: 500,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image Preview & Upload (Commented Out)
                      /*
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[400]!),
                            image:
                                webImage != null
                                    ? DecorationImage(
                                      image: MemoryImage(webImage!),
                                      fit: BoxFit.cover,
                                    )
                                    : (imageUrlController.text.isNotEmpty &&
                                            !imageUrlController.text.startsWith(
                                              'Uploading',
                                            )
                                        ? DecorationImage(
                                          image: NetworkImage(
                                            imageUrlController.text,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                        : null),
                          ),
                          child:
                              webImage == null &&
                                      imageUrlController.text.isEmpty
                                  ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Click to upload image',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      */
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Service Name',
                          hintText: 'e.g. AC Repair',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          hintText: 'https://...',
                          border: OutlineInputBorder(),
                        ),
                        // validator: (v) => v?.isEmpty == true ? 'Image URL is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (₹)',
                          hintText: 'e.g. 599',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) =>
                            v?.isEmpty == true ? 'Price is required' : null,
                      ),
                      const SizedBox(height: 16),
                      // Category Dropdown
                      StreamBuilder<List<CategoryModel>>(
                        stream: _categoryService.getAllCategories(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: LinearProgressIndicator(),
                            );
                          }
                          final categories = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField<String>(
                              value:
                                  categories.any(
                                    (c) => c.id == selectedCategoryId,
                                  )
                                  ? selectedCategoryId
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedCategoryId = val;
                                });
                              },
                              validator: (v) =>
                                  v == null ? 'Category is required' : null,
                            ),
                          );
                        },
                      ),
                      TextFormField(
                        controller: typeController,
                        decoration: const InputDecoration(
                          labelText: 'Service Type (Tag)',
                          hintText: 'e.g. Cleaning',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Type is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: orderCountController,
                        decoration: const InputDecoration(
                          labelText: 'Initial Order Count',
                          hintText: 'e.g. 0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Mark as Favourite'),
                        value: isFavourite,
                        onChanged: (val) => setState(() => isFavourite = val),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isUploading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() => isUploading = true);
                          String imageUrl = imageUrlController.text;

                          // Image upload logic commented out
                          /*
                            if (webImage != null) {
                              final url = await uploadImage(
                                nameController.text.trim(),
                              );
                              if (url != null) {
                                imageUrl = url;
                              } else {
                                setState(() => isUploading = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to upload image'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }
                            } else if (imageUrl.isEmpty || imageUrl == 'Uploading...') {
                               setState(() => isUploading = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select an image'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                            }
                            */

                          final newService = ServiceModel(
                            id: service?.id ?? '',
                            name: nameController.text.trim(),
                            imageUrl: imageUrl,
                            price: double.parse(priceController.text.trim()),
                            type: typeController.text.trim(),
                            categoryId: selectedCategoryId ?? '',
                            orderCount: int.parse(
                              orderCountController.text.trim(),
                            ),
                            isFavourite: isFavourite,
                          );

                          try {
                            if (service == null) {
                              // Create
                              await FirebaseFirestore.instance
                                  .collection('services')
                                  .add(newService.toFirestore());
                            } else {
                              // Update
                              await FirebaseFirestore.instance
                                  .collection('services')
                                  .doc(service.id)
                                  .update(newService.toFirestore());
                            }
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setState(() => isUploading = false);
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(service == null ? 'Add Service' : 'Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteService(String serviceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .delete();
    }
  }

  // --- End Services Management Section ---

  Widget _buildOrders() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Orders',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('created_at', descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = snapshot.data?.docs ?? [];

              if (orders.isEmpty) {
                return const Center(
                  child: Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final orderDoc = orders[index];
                  final order = orderDoc.data() as Map<String, dynamic>;
                  final currentStatus = OrderStatus.fromString(
                    order['status'] ?? 'pending',
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Order Number
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Service Info
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['service_name'] ?? 'Unknown Service',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${order['amount']?.toStringAsFixed(0) ?? '0'}',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Customer Info
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(order['user_phone'] ?? 'No phone'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(order['booking_time'] ?? ''),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Status Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                currentStatus,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor(currentStatus),
                              ),
                            ),
                            child: DropdownButton<OrderStatus>(
                              value: currentStatus,
                              underline: const SizedBox(),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: _getStatusColor(currentStatus),
                              ),
                              items: OrderStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status.displayName,
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.w600,
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

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Order status updated to ${newStatus.displayName}',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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

  Widget _buildUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          width: double.infinity,
          child: const Text(
            'Users Management',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        Colors.grey[100],
                      ),
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Joined')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: docs.map((doc) {
                        final user = UserModel.fromFirestore(doc);
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    backgroundImage:
                                        user.profilePicture != null &&
                                            user.profilePicture!.isNotEmpty
                                        ? NetworkImage(user.profilePicture!)
                                        : null,
                                    child:
                                        user.profilePicture == null ||
                                            user.profilePicture!.isEmpty
                                        ? Text(
                                            user.firstName?.isNotEmpty == true
                                                ? user.firstName![0]
                                                      .toUpperCase()
                                                : 'U',
                                            style: TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    user.fullName.isEmpty
                                        ? 'No Name'
                                        : user.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(user.phoneNumber)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: user.isSuperuser
                                      ? Colors.purple[50]
                                      : (user.isStaff
                                            ? Colors.blue[50]
                                            : Colors.grey[100]),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: user.isSuperuser
                                        ? Colors.purple[200]!
                                        : (user.isStaff
                                              ? Colors.blue[200]!
                                              : Colors.grey[300]!),
                                  ),
                                ),
                                child: Text(
                                  user.isSuperuser
                                      ? 'Super Admin'
                                      : (user.isStaff ? 'Admin' : 'User'),
                                  style: TextStyle(
                                    color: user.isSuperuser
                                        ? Colors.purple[700]
                                        : (user.isStaff
                                              ? Colors.blue[700]
                                              : Colors.grey[700]),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: user.isActive
                                      ? Colors.green[50]
                                      : Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  user.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: user.isActive
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${user.dateJoined.day}/${user.dateJoined.month}/${user.dateJoined.year}',
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  // TODO: Show user details/edit dialog
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return _buildComingSoon('Settings');
  }

  Widget _buildComingSoon(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '$title Coming Soon',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
