import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'login_screen.dart';

/// Main Home Screen
///
/// The main home screen shown after successful login with complete profile
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
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

  @override
  Widget build(BuildContext context) {
    final user = _userService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Buddy'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryVeryLight, AppTheme.backgroundColor],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: MobileTheme.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Welcome Card
                _buildWelcomeCard(user),
                const SizedBox(height: 24),
                // User Info Card
                _buildUserInfoCard(user),
                const SizedBox(height: 24),
                // Coming Soon Card
                _buildComingSoonCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: MobileTheme.primaryGradient,
        borderRadius: MobileTheme.cardRadius,
        boxShadow: MobileTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 32,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: MobileTheme.labelLarge.copyWith(
                        color: Colors.white.withAlpha(204),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.fullName ?? 'User',
                      style: MobileTheme.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: MobileTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile Information', style: MobileTheme.headlineMedium),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.person_outline, 'Name', user?.fullName ?? 'N/A'),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.phone_outlined,
            'Phone',
            user?.phoneNumber ?? 'N/A',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Address',
            user?.address ?? 'N/A',
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.wc_outlined, 'Gender', user?.gender ?? 'N/A'),
          if (user?.dateOfBirth != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.cake_outlined,
              'Date of Birth',
              '${user!.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppTheme.primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: MobileTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: MobileTheme.bodyLarge.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: MobileTheme.cardDecoration,
      child: Column(
        children: [
          Icon(
            Icons.construction_rounded,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'More Features Coming Soon!',
            style: MobileTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re working hard to bring you amazing features.',
            style: MobileTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
