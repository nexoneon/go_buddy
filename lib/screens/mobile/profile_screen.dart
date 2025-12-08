import 'package:flutter/material.dart';

/// Mobile Profile Screen
///
/// This is the profile screen for mobile applications (Android/iOS).
class MobileProfileScreen extends StatelessWidget {
  const MobileProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(child: Text('Mobile Profile Screen')),
    );
  }
}
