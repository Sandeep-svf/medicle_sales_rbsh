import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background color if needed
      body: Center(
        child: Image.asset(
          'assets/splash_logo.png', // Replace with your image path
          width: 200, // Adjust size if needed
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

