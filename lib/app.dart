import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/onboarding/splash.dart';

import 'package:medicle_sales_rbsh/utils/anim/CustomPageTransition.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/theam/theme.dart';
import 'package:flutter/services.dart';


class App extends StatelessWidget {
  const App({super.key});



  @override
  Widget build(BuildContext context) {

    // Set status bar color globally
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: TColors.primary, // Change this to the color you want for the status bar
      statusBarIconBrightness: Brightness.light, // This makes the icons light (if you use a dark color for status bar)
    ));

    return GetMaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: SAppTheme.darkTheme,
      theme: SAppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      defaultTransition: Transition.noTransition, // Disable default transition
      customTransition: CustomPageTransition(), // Apply custom transition
    );
  }
}
