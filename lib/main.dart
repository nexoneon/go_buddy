import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/config.dart';
import 'screens/web/web_screens.dart';
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
      // Web platform: Show Bootstrap screen which handles auth routing
      return const ConnectivityWrapper(
        showBanner: true,
        child: WebBootstrapScreen(),
      );
    } else {
      // Mobile platform: Show MobileHomeScreen (Splash) → then navigates to LoginScreen
      return const ConnectivityWrapper(
        showBanner: true,
        child: MobileHomeScreen(),
      );
    }
  }
}
