import 'dart:convert';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/services/PushNotificationService.dart';
import 'package:medicle_sales_rbsh/services/background_service.dart';
import 'package:medicle_sales_rbsh/utils/LocationHelper/on_start.dart';
import 'package:provider/provider.dart';
import 'features/addClinic/controllers/ClinicListController.dart';
import 'features/salesActivity/controllers/SalesController.dart';
import 'app.dart'; // Import your App widget
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

// Import your background_service.dart where onStart() is defined
//import 'background_service.dart';

// Import your SalesController and App widget
/*
import 'path_to_your_sales_controller.dart';
import 'path_to_your_app.dart';
*/


/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'features/salesActivity/controllers/SalesController.dart';
import 'app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeBackgroundService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SalesController()),
      ],
      child: const App(),
    ),
  );
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'location_channel', // Required for Android 10+
      initialNotificationTitle: 'Tracking Location',
      initialNotificationContent: 'Location service is running',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(), // Not needed for Android-only
  );

  await service.startService();
}*/

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔄 BG Message: ${message.messageId}');
}

/*void main() async{

  *//*debugPrint('LocationTag: A.');
  WidgetsFlutterBinding.ensureInitialized();// Required for async operations before runApp
  debugPrint('LocationTag: Initializing background service...');
  await BackgroundLocationService.requestPermissions(); // Request permissions and start service
*//*

  *//*WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);*//*

  //  Initialize push notifications BEFORE runApp
  *//*await PushNotificationService().initialize();*//*

  debugPrint('LocationTag: B');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SalesController()),
      ],
      child: const App(),
    ),
  );
}*/


/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final service = FlutterBackgroundService();

    await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: true,
          notificationChannelId: 'my_foreground',
          initialNotificationTitle: 'App is running in background',
          initialNotificationContent: 'Fetching location...',
          foregroundServiceNotificationId: 888,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onStart,
          onBackground: onStart,
        ),
      );

    service.startService();
  } catch (e) {
    print(e);
  }

  debugPrint('LocationTag: B');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SalesController()),
      ],
      child: const App(),
    ),
  );
}*/




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /*try {
    // Initialize the background service
    final service = FlutterBackgroundService();

    // Request location permissions before starting the service
    await checkLocationPermissions();

    // Configure the background service for Android and iOS
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, // the function to run when service starts
        autoStart: true, // start automatically
        isForegroundMode: true, // foreground mode
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'App is running in background',
        initialNotificationContent: 'Fetching location...',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location], // Ensure location service is specified
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart, // the same onStart function can be used for iOS as well
        onBackground: onIosBackground, // action when app is in background
      ),
    );

    // Start the service
    service.startService();
  } catch (e) {
    printWithPrefix(e.toString());
  }*/

  debugPrint('LocationTag: B');

  // Start your app as usual
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SalesController()), // Example provider
      ],
      child: const App(),
    ),
  );
}

// Function to check and request permissions
Future<void> checkLocationPermissions() async {
  bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!isLocationServiceEnabled) {
    printWithPrefix("Location services are disabled.");
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    printWithPrefix("Location permission permanently denied.");
    return;
  }

  if (permission == LocationPermission.denied) {
    printWithPrefix("Location permission denied.");
    return;
  }

  if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
    printWithPrefix("Location permission granted.");
  }
}

// Function to handle onStart logic for background service
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Periodically bring service to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        service.setForegroundNotificationInfo(
          title: "My App Service",
          content: "Updated at ${DateTime.now()}",
        );
      }
    }

    debugPrint('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // Example for fetching device information
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );

    // Fetch location periodically and send to API
    if (!(await Geolocator.isLocationServiceEnabled())) {
      printWithPrefix('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        printWithPrefix('Location permission denied');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      printWithPrefix('Location permission permanently denied');
      return;
    }



    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      printWithPrefix('Background Position: ${position.latitude}, ${position.longitude}');

      final url = Uri.parse('https://api.gluckscare.com/api/locations');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // content type to JSON
        },
        body: json.encode({
          "latitude": position.latitude, // Pass as double
          "longitude": position.longitude, // Pass as double
          "userName": "John Doe",
          "userId": "507f1f77bcf86cd799439011"
        }),
      );

      printWithPrefix('API response: ${response.statusCode}');
      printWithPrefix('API response: ${response.body.toString()}');
    } catch (e) {
      printWithPrefix('Error during location fetch or API call: $e');
    }

  });
}

// Helper function to add a prefix to print statements
void printWithPrefix(String message) {
  final prefix = "[Location Service] ";
  print(prefix + message);
}





