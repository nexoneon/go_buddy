import 'package:flutter/material.dart';

/// Mobile Home Screen
///
/// This is the main home screen for mobile applications (Android/iOS).
class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Buddy - Mobile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(child: Text('Mobile Home Screen')),
    );
  }
}
