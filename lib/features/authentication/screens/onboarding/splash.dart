import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';

import '../../../../utils/constants/image_strings.dart';

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
        child:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image(
            image: AssetImage(
                 TImages.lightAppLogo),
            height: 150,
          ),
        ),
      ),
    );
  }
}

