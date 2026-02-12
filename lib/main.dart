import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/config.dart';
import 'screens/web/web_screens.dart';
import 'screens/web/mobile_browser_message.dart';
import 'screens/mobile/home_screen.dart';
import 'services/connectivity_service.dart';
import 'widgets/no_internet_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Connectivity Service
  await ConnectivityService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Minimum width for web admin portal (in logical pixels)
  static const double minWebWidth = 900;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '7 Pay Services',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: _getHomeScreen(),
    );
  }

  /// Returns the appropriate home screen based on the platform
  Widget _getHomeScreen() {
    if (kIsWeb) {
      return const _WebScreenSizeWrapper();
    } else {
      // For mobile, use the Splash Screen as the entry point
      // It handles its own navigation logic to Login or Home
      return const ConnectivityWrapper(
        showBanner: true,
        child: MobileHomeScreen(),
      );
    }
  }
}

/// Wrapper widget that checks screen size on web platform
class _WebScreenSizeWrapper extends StatelessWidget {
  const _WebScreenSizeWrapper();

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for accurate screen size detection
    final screenWidth = MediaQuery.of(context).size.width;

    // Check if screen width is too small for admin portal
    if (screenWidth < MyApp.minWebWidth) {
      // Show message for mobile browsers
      return const MobileBrowserMessageScreen();
    }

    // Desktop size - show admin portal
    return const ConnectivityWrapper(
      showBanner: true,
      child: WebBootstrapScreen(),
    );
  }
}
