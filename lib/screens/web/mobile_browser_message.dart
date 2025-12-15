import 'package:flutter/material.dart';
import '../../config/config.dart';
import 'web_screens.dart';
import '../../widgets/no_internet_widget.dart';

/// Mobile Browser Message Screen
///
/// Shows a message asking users to access the admin portal from a desktop
/// with an option to continue anyway
class MobileBrowserMessageScreen extends StatefulWidget {
  const MobileBrowserMessageScreen({super.key});

  @override
  State<MobileBrowserMessageScreen> createState() =>
      _MobileBrowserMessageScreenState();
}

class _MobileBrowserMessageScreenState
    extends State<MobileBrowserMessageScreen> {
  bool _continueAnyway = false;

  @override
  Widget build(BuildContext context) {
    // If user chose to continue, show the admin portal
    if (_continueAnyway) {
      return const ConnectivityWrapper(
        showBanner: true,
        child: WebBootstrapScreen(),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withAlpha(200),
              const Color(0xFF063D3F),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.desktop_windows_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Admin Portal',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Message
                  Text(
                    'For the best experience, please access the Admin Portal from a desktop or laptop computer.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withAlpha(220),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Continue Anyway Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _continueAnyway = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Continue to Admin Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Warning text
                  Text(
                    'Note: Some features may not work properly on small screens',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(180),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
