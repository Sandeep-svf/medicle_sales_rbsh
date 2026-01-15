import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/TrackingOptimizedBgLocation/debug/debug_repository.dart';
import 'package:medicle_sales_rbsh/features/TrackingOptimizedBgLocation/debug/debug_screen.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/onboarding/splash.dart';

import 'package:medicle_sales_rbsh/utils/anim/CustomPageTransition.dart';
import 'package:medicle_sales_rbsh/utils/check_internet/network_monitor.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/theam/theme.dart';
import 'package:flutter/services.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    //  Start global network monitoring
    Future.microtask(() {
      NetworkMonitor().startMonitoring(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NetworkMonitor().stopMonitoring(); //  Stop when app closes
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      NetworkMonitor().stopMonitoring();
    } else if (state == AppLifecycleState.resumed) {
      NetworkMonitor().startMonitoring(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: TColors.primary,
      statusBarIconBrightness: Brightness.light,
    ));

    return GetMaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey, //  add this
      navigatorKey: GlobalKey<NavigatorState>(), // optional, keep if already there
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      darkTheme: SAppTheme.darkTheme,
      theme: SAppTheme.lightTheme,
      home: const SplashScreen(),
     // home:  DebugScreen(),
      defaultTransition: Transition.noTransition,
      customTransition: CustomPageTransition(),
    );
  }
}
