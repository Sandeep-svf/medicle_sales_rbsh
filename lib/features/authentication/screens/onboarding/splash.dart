import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart'; // Import In-App Update package
import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../dashboard/screen/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkForUpdate(); // Start checking for updates first
  }

  /// Check if app update is available
  Future<void> _checkForUpdate() async {
    try {
      AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _showUpdateDialog(); // Show update prompt if needed
      } else {
        _checkLoginStatus(); // If no update, proceed to login check
      }
    } catch (e) {
      _checkLoginStatus(); // If error occurs, continue normal flow
    }
  }

  /// Show Update Dialog
  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing without action
      builder: (context) {
        return AlertDialog(
          title: const Text(TTexts.updateAvailable),
          content: const Text(TTexts.updateAvailableContent),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Allow skipping update
                _checkLoginStatus(); // Continue app flow
              },
              child: const Text(TTexts.skip),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _startImmediateUpdate();
              },
              child: const Text(TTexts.updateNow),
            ),
          ],
        );
      },
    );
  }

  /// Perform Immediate Update
  Future<void> _startImmediateUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      _checkLoginStatus(); // Continue app flow even if update fails
    }
  }

  /// Check Login Session
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString("user_id"); // Retrieve saved user ID

    await Future.delayed(const Duration(seconds: 3)); // Splash delay

    if (userId != null && userId.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            TImages.lightAppLogo,
            height: 150,
          ),
        ),
      ),
    );
  }
}
