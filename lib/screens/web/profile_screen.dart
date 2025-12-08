import 'package:flutter/material.dart';

/// Web Profile Screen
///
/// This is the profile screen for web applications.
class WebProfileScreen extends StatelessWidget {
  const WebProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(child: Text('Web Profile Screen')),
    );
  }
}
