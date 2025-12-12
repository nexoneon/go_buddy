import 'package:flutter/material.dart';

/// Web Home Screen
///
/// This is the main home screen for web applications.
class WebHomeScreen extends StatelessWidget {
  const WebHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('7 Pay Services - Web'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(child: Text('Web Home Screen')),
    );
  }
}
