import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';
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
    print("[SplashScreen] App started. Checking for updates...");
    _checkForUpdate(); // Start checking for updates first
  }

  /// Check if app update is available
  Future<void> _checkForUpdate() async {
    try {
      AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      print("[UpdateCheck] Update availability: ${info.updateAvailability}");
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        print("[UpdateCheck] Update available. Showing update dialog...");
        _showUpdateDialog();
      } else {
        print("[UpdateCheck] No update available. Proceeding to login check...");
        _checkLoginStatus();
      }
    } catch (e) {
      print("[UpdateCheck] Error occurred while checking for updates: $e");
      _checkLoginStatus(); // If error occurs, continue normal flow
    }
  }

  /// Show Update Dialog
  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(TTexts.updateAvailable),
          content: const Text(TTexts.updateAvailableContent),
          actions: [
            TextButton(
              onPressed: () {
                print("[UpdateDialog] User skipped the update.");
                Navigator.pop(context);
                _checkLoginStatus();
              },
              child: const Text(TTexts.skip),
            ),
            TextButton(
              onPressed: () async {
                print("[UpdateDialog] User opted to update now.");
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
      print("[UpdateStart] Starting immediate update...");
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      print("[UpdateStart] Immediate update failed: $e");
      _checkLoginStatus(); // Continue app flow even if update fails
    }
  }

  /// Check Login Session
  Future<void> _checkLoginStatus() async {
    print("[LoginCheck] Checking saved login session...");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString("user_id");

    await Future.delayed(const Duration(seconds: 3)); // Splash delay

    if (userId != null && userId.isNotEmpty) {
      print("[LoginCheck] User ID found: $userId. Navigating to Dashboard.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      print("[LoginCheck] No user session found. Navigating to Login Screen.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
