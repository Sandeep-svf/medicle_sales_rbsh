import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    checkLoginStatus();
  }

  /// Check if user is logged in or not
  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString("user_id"); // Retrieve saved user ID

    await Future.delayed(const Duration(seconds: 3)); // Delay for splash effect

    if (userId != null && userId.isNotEmpty) {
      //  Navigate to Dashboard if user is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      //  Navigate to Login Screen if user is not logged in
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
