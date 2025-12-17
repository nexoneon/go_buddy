import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/category_service.dart';
import '../../services/service_service.dart';
import '../../services/favourite_service.dart';
import '../../services/connectivity_service.dart';
import '../../models/category_model.dart';
import '../../models/service_model.dart';
import '../../models/gallery_image_model.dart';
import '../../services/gallery_image_service.dart';
import '../../widgets/auto_scroll_banner.dart'; // Import AutoScrollBanner
import 'login_screen.dart';
import 'service_detail_screen.dart';
import 'my_orders_screen.dart';
import 'profile_screen.dart';
import 'help_screen.dart';
import 'address_list_screen.dart';
import 'raise_request_screen.dart';

/// Main Home Screen
///
/// Service booking home screen with categories and bottom navigation
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final CategoryService _categoryService = CategoryService();
  final ServiceService _serviceService = ServiceService();
  final FavouriteService _favouriteService = FavouriteService();
  final GalleryImageService _galleryImageService =
      GalleryImageService(); // Initialize Service
  final ConnectivityService _connectivityService = ConnectivityService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 2; // Home is selected by default
  bool _wasConnected = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _wasConnected = _connectivityService.isConnected;
    // Check if already offline when screen loads
    _isOffline = !_connectivityService.isConnected;
    _connectivityService.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (mounted) {
      final isConnected = _connectivityService.isConnected;

      // Show snackbar when connection drops
      if (_wasConnected && !isConnected) {
        setState(() => _isOffline = true);
        _showConnectivitySnackbar(false);
      }

      // Show snackbar when reconnected
      if (!_wasConnected && isConnected) {
        setState(() => _isOffline = false);
        _showConnectivitySnackbar(true);
      }

      _wasConnected = isConnected;
    }
  }

  void _showConnectivitySnackbar(bool isConnected) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(isConnected ? 'Back online!' : 'No internet connection'),
          ],
        ),
        backgroundColor: isConnected
            ? AppTheme.successColor
            : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isConnected ? 2 : 4),
      ),
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          MaterialPageRoute(builder: (context) => const MobileLoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Favourites';
      case 1:
        return 'My Orders';
      case 2:
        return 'Home';
      case 3:
        return 'Help & Support';
      case 4:
        return 'Settings';
      default:
        return '7 Pay Services';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _userService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(user),
      body: Column(
        children: [
          // Persistent No Internet Banner
          if (_isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.errorColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'No Internet Connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          // Main Content
          Expanded(child: _buildContentForIndex()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContentForIndex() {
    switch (_selectedIndex) {
      case 0:
        return _buildFavouritesPage(); // Favourites
      case 1:
        return MyOrdersScreen(); // My Orders
      case 2:
        return _buildBody(); // Home
      case 3:
        return const HelpScreen(); // Help
      case 4:
        return _buildSettingsPage(); // Settings
      default:
        return _buildBody();
    }
  }

  Widget _buildFavouritesPage() {
    final user = _userService.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Login to view favourites',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<ServiceModel>>(
      stream: _favouriteService.getFavouriteServices(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final favourites = snapshot.data ?? [];

        if (favourites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No favourites yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on any service to add it here',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favourites.length,
          itemBuilder: (context, index) {
            final service = favourites[index];
            return _buildFavouriteCard(service, user.uid);
          },
        );
      },
    );
  }

  Widget _buildFavouriteCard(ServiceModel service, String userId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Service Image/Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.build_outlined,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Service Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.note ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${service.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              // Remove from favourites button
              IconButton(
                onPressed: () async {
                  await _favouriteService.removeFromFavourites(
                    userId,
                    service.id,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Removed from favourites'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPage() {
    final user = _userService.currentUser;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF0D7377).withAlpha(51),
                    backgroundImage:
                        (user?.profilePicture != null &&
                            user!.profilePicture!.isNotEmpty)
                        ? NetworkImage(user.profilePicture!)
                        : null,
                    child:
                        (user?.profilePicture == null ||
                            user!.profilePicture!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF0D7377),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phoneNumber ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Settings Options
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Column(
              children: [
                // Profile Option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D7377).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF0D7377),
                    ),
                  ),
                  title: const Text(
                    'Profile',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('View and edit your profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MobileProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                // Manage Addresses Option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D7377).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF0D7377),
                    ),
                  ),
                  title: const Text(
                    'Manage Addresses',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Add or edit your addresses'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressListScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                // Support Option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D7377).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: Color(0xFF0D7377),
                    ),
                  ),
                  title: const Text(
                    'Support',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Raise a request'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RaiseRequestScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                // Logout Option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.logout, color: Colors.red),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text('Sign out of your account'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(user) {
    return AppBar(
      backgroundColor: const Color(0xFF0D7377),
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            backgroundImage:
                (user?.profilePicture != null &&
                    user!.profilePicture!.isNotEmpty)
                ? NetworkImage(user.profilePicture!)
                : null,
            child:
                (user?.profilePicture == null || user!.profilePicture!.isEmpty)
                ? Icon(Icons.person, color: AppTheme.primaryColor)
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'User',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _getScreenTitle(),
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //     icon: Container(
      //       padding: const EdgeInsets.all(8),
      //       decoration: BoxDecoration(
      //         color: Colors.white.withAlpha(51),
      //         borderRadius: BorderRadius.circular(12),
      //       ),
      //       child: const Icon(Icons.settings, color: Colors.white),
      //     ),
      //     onPressed: _handleLogout,
      //   ),
      //   const SizedBox(width: 8),
      // ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Promotional Banner
          _buildPromoBanner(),
          const SizedBox(height: 12),
          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 12),
          // Service Categories
          _buildCategoryGrid(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return StreamBuilder<List<GalleryImageModel>>(
      stream: _galleryImageService.getImages(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildStaticPromoBanner();
        }

        final images = snapshot.data!;

        // Use AutoScrollBanner with 3 seconds interval
        return AutoScrollBanner(
          images: images,
          interval: const Duration(seconds: 3),
        );
      },
    );
  }

  Widget _buildStaticPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD32F2F), Color(0xFFE57373)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_offer_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Washroom Cleaning',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          // Right button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEB3B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Order\nNow',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: 'Search categories...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<List<ServiceModel>>(
        stream: _serviceService.getServices(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading services'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allServices = snapshot.data ?? [];

          // Filter services based on search
          final services = _searchQuery.isEmpty
              ? allServices
              : allServices
                    .where((s) => s.name.toLowerCase().contains(_searchQuery))
                    .toList();

          if (services.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No services found for "$_searchQuery"',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          if (services.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No services available'),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceGridCard(service);
            },
          );
        },
      ),
    );
  }

  /// Build service card for grid display with rating
  Widget _buildServiceGridCard(ServiceModel service) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          service.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.build_outlined,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.build_outlined,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
              ),
            ),
            // Service Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Price and Discount
                    Row(
                      children: [
                        if (service.percentage != null &&
                            service.percentage! > 0) ...[
                          Text(
                            '₹${(service.price * (1 - service.percentage! / 100)).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '₹${service.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '₹${service.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    // Rating
                    Row(
                      children: [
                        if (service.rating > 0) ...[
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            service.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' (${service.ratingCount})',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.star_border,
                            color: Colors.grey[400],
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'No ratings',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (service.percentage != null &&
                            service.percentage! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(26),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${service.percentage!.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show services in a bottom sheet when category is tapped
  void _showServicesBottomSheet(CategoryModel category) {
    final user = _userService.currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(category.color).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildCategoryImage(category),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Select a service',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Services List
              Expanded(
                child: StreamBuilder<List<ServiceModel>>(
                  stream: _serviceService.getServicesByCategory(category.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final services = snapshot.data ?? [];

                    if (services.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No services in this category',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return _buildServiceCardInSheet(service, user);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a service card for the bottom sheet
  Widget _buildServiceCardInSheet(ServiceModel service, user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Close bottom sheet
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Service Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.build_outlined,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Service Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          service.accept ? Icons.check_circle : Icons.cancel,
                          color: service.accept ? Colors.green : Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.accept ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: service.accept ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (service.rating > 0) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            service.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Price and Book Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${service.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (service.accept)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Book',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category, int count) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showServicesBottomSheet(category);
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Image or Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(category.color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildCategoryImage(category),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count Services',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build category image widget - shows image if available, otherwise shows icon
  Widget _buildCategoryImage(CategoryModel category) {
    final imageUrl = category.imageUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icon on error
            return Icon(
              Icons.category_outlined,
              color: Color(category.color),
              size: 50,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(category.color),
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      );
    }

    // Default icon when no image
    return Icon(
      Icons.category_outlined,
      color: Color(category.color),
      size: 50,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF0D7377),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, color: Colors.red),
              activeIcon: Icon(Icons.favorite, color: Colors.red),
              label: 'Favourite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined, color: Colors.orange),
              activeIcon: Icon(Icons.shopping_bag, color: Colors.orange),
              label: 'My Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, color: Color(0xFF0D7377)),
              activeIcon: Icon(Icons.home, color: Color(0xFF0D7377)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help_outline, color: Colors.blue),
              activeIcon: Icon(Icons.help, color: Colors.blue),
              label: 'Help',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, color: Color(0xFF1a237e)),
              activeIcon: Icon(Icons.settings, color: Color(0xFF1a237e)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// ServiceCategory class removed as it is replaced by ServiceModel
