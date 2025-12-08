import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'config/config.dart';
import 'screens/web/web_screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Buddy',
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
      return const WebBootstrapScreen();
    } else {
      // Mobile platform: Show mobile bootstrap/home screen
      // TODO: Replace with MobileBootstrapScreen when ready
      return const _MobilePlaceholderScreen();
    }
  }
}

/// Placeholder screen for mobile until mobile screens are ready
class _MobilePlaceholderScreen extends StatelessWidget {
  const _MobilePlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Buddy'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Go Buddy Mobile',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Mobile version coming soon!',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
