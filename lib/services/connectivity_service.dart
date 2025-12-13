import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity Service
///
/// Monitors internet connectivity status and provides real-time updates
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool _isInitialized = false;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];

  // Getters
  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;
  List<ConnectivityResult> get connectionStatus => _connectionStatus;

  /// Get connection type as string
  String get connectionType {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (_connectionStatus.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else {
      return 'No Connection';
    }
  }

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get initial connectivity status
      _connectionStatus = await _connectivity.checkConnectivity();
      _updateConnectionStatus(_connectionStatus);

      // Listen for connectivity changes
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          debugPrint('❌ Connectivity error: $error');
        },
      );

      _isInitialized = true;
      debugPrint('✅ Connectivity service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing connectivity service: $e');
      // Assume connected if we can't check
      _isConnected = true;
    }
  }

  /// Update connection status
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _connectionStatus = result;

    final wasConnected = _isConnected;
    _isConnected = !result.contains(ConnectivityResult.none);

    if (wasConnected != _isConnected) {
      debugPrint(
        _isConnected
            ? '✅ Internet connected ($connectionType)'
            : '❌ Internet disconnected',
      );
      notifyListeners();
    }
  }

  /// Check current connectivity (one-time check)
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return _isConnected;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');
      return true; // Assume connected on error
    }
  }

  /// Dispose the service
  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
    super.dispose();
  }
}
