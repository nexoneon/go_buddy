import 'package:flutter/material.dart';
import '../config/config.dart';
import '../services/connectivity_service.dart';

/// No Internet Widget
///
/// Displays a banner or overlay when there's no internet connection
class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorColor.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
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
    );
  }
}

/// No Internet Overlay
///
/// Full screen overlay when there's no internet connection
class NoInternetOverlay extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetOverlay({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.errorBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 60,
                    color: AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  'Please check your internet connection and try again.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Retry Button
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Connectivity Wrapper
///
/// Wraps a widget and shows no internet banner when offline
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final bool showBanner;
  final bool showOverlay;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.showBanner = true,
    this.showOverlay = false,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _wasConnected = true; // Track if user was previously connected
  bool _showDisconnectedBanner = false; // Only show after a connection drop

  @override
  void initState() {
    super.initState();
    _wasConnected = _connectivityService.isConnected;
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

      // Only show banner if we were connected and now we're not
      if (_wasConnected && !isConnected) {
        setState(() {
          _showDisconnectedBanner = true;
        });
      }

      // Hide banner when reconnected
      if (!_wasConnected && isConnected) {
        setState(() {
          _showDisconnectedBanner = false;
        });
      }

      _wasConnected = isConnected;
    }
  }

  void _handleRetry() async {
    await _connectivityService.checkConnectivity();
    if (mounted) {
      setState(() {
        if (_connectivityService.isConnected) {
          _showDisconnectedBanner = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _connectivityService.isConnected;

    if (widget.showOverlay && _showDisconnectedBanner && !isConnected) {
      return NoInternetOverlay(onRetry: _handleRetry);
    }

    return Column(
      children: [
        // No Internet Banner - only show after connection drop
        if (widget.showBanner && _showDisconnectedBanner && !isConnected)
          const NoInternetBanner(),
        // Main Content
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Internet Check Mixin
///
/// Add this mixin to StatefulWidget states to easily check connectivity
mixin InternetCheckMixin<T extends StatefulWidget> on State<T> {
  final ConnectivityService _connectivity = ConnectivityService();

  bool get isConnected => _connectivity.isConnected;

  /// Show a snackbar if offline
  void showOfflineSnackbar() {
    if (!isConnected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('No internet connection'),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Check connectivity before performing an action
  Future<bool> checkBeforeAction() async {
    final connected = await _connectivity.checkConnectivity();
    if (!connected) {
      showOfflineSnackbar();
    }
    return connected;
  }
}
