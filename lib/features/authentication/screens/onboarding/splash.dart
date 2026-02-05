/*import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
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
 AuthManager authManager = AuthManager();
      await authManager.logout();

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
}*/

/*import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';

import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/image_strings.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';
import 'package:medicle_sales_rbsh/features/dashboard/screen/dashboard.dart';
import 'package:medicle_sales_rbsh/services/LocationController.dart';

const _bgPortName = 'bg_location_port';
final ValueNotifier<LocationDto?> lastLocation = ValueNotifier<LocationDto?>(null);
Timer? _tick;
LocationDto? _lastFix;

// 🔹 Common debug prefix
const String debugPrefix = 'AppDebug';

@pragma('vm:entry-point')
void initCallback(dynamic _) {
  _tick?.cancel();
  _tick = Timer.periodic(const Duration(seconds: 1), (_) {
    final l = _lastFix;
    if (l != null) {
      print('BG Tick: lat=${l.latitude}, lng=${l.longitude}, acc=${l.accuracy}', name: debugPrefix);
      final locationController = LocationController(l.latitude, l.longitude);
      locationController.sendLocationData();
    }
  });
}

@pragma('vm:entry-point')
void locationCallback(LocationDto data) {
  _lastFix = data;
  print('BG Location Callback: lat=${data.latitude}, lng=${data.longitude}, acc=${data.accuracy}', name: debugPrefix);
  IsolateNameServer.lookupPortByName(_bgPortName)?.send(data);
}

@pragma('vm:entry-point')
void disposeCallback() {
  _tick?.cancel();
  print('BG disposed', name: debugPrefix);
}

@pragma('vm:entry-point')
void notificationCallback() {
  print('Notification tapped', name: debugPrefix);
}

void _registerBgPort(void Function(LocationDto) onLocation) {
  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping(_bgPortName);
  IsolateNameServer.registerPortWithName(port.sendPort, _bgPortName);

  port.listen((msg) {
    if (msg is LocationDto) {
      lastLocation.value = msg;
      print('BG port received: lat=${msg.latitude}, lng=${msg.longitude}', name: debugPrefix);
      onLocation(msg);
    }
  });
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    print('SplashScreen started', name: debugPrefix);
    await _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      print('Update Availability: ${info.updateAvailability}', name: debugPrefix);
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _showUpdateDialog();
      } else {
        _showDisclosureAndPermissions();
      }
    } catch (e) {
      print('Update check failed: $e', name: debugPrefix);
      _showDisclosureAndPermissions();
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(TTexts.updateAvailable),
        content: const Text(TTexts.updateAvailableContent),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDisclosureAndPermissions();
            },
            child: const Text(TTexts.skip),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await InAppUpdate.performImmediateUpdate();
              } catch (_) {
                _showDisclosureAndPermissions();
              }
            },
            child: const Text(TTexts.updateNow),
          ),
        ],
      ),
    );
  }

  Future<void> _showDisclosureAndPermissions() async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Location Access Required"),
        content: const Text(
          "Gluckscare collects your location even when the app is closed or not in use. "
              "We use this data to track your sales visits and provide accurate reporting. "
              "Your location is never shared with third parties.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Continue"),
          ),
        ],
      ),
    ) ?? false;

    if (!accepted) {
      print('User denied disclosure. Exiting...', name: debugPrefix);
      exit(0);
    }

    await _requestPermissionsAndStart();
    _checkLoginStatus();
  }

  Future<void> _requestPermissionsAndStart() async {
    print('Requesting permissions...', name: debugPrefix);
    final fg = await Permission.location.request();
    if (!fg.isGranted) return _showDisclosureAndPermissions();

    final bg = await Permission.locationAlways.request();
    if (!bg.isGranted) return _showDisclosureAndPermissions();

    final nt = await Permission.notification.request();
    print('Permissions granted -> fg:${fg.isGranted}, bg:${bg.isGranted}, notif:${nt.isGranted}', name: debugPrefix);

    try {
      await BackgroundLocator.initialize();
      await BackgroundLocator.registerLocationUpdate(
        locationCallback,
        initCallback: initCallback,
        disposeCallback: disposeCallback,
        androidSettings: const AndroidSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          interval: 1000,
          distanceFilter: 0,
          client: LocationClient.google,
          androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: 'Location tracking',
            notificationTitle: 'Background Location Running',
            notificationMsg: 'App uses your location in the background for tracking.',
            notificationTapCallback: notificationCallback,
          ),
        ),
        iosSettings: const IOSSettings(),
        autoStop: false,
      );
      print('BackgroundLocator initialized', name: debugPrefix);
    } catch (e) {
      print('BackgroundLocator failed: $e', name: debugPrefix);
    }

    _registerBgPort((_) {});
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");

    await Future.delayed(const Duration(seconds: 2));

    if (userId != null && userId.isNotEmpty) {
      print('User logged in: $userId -> Dashboard', name: debugPrefix);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    } else {
      print('No session found -> LoginScreen', name: debugPrefix);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          TImages.lightAppLogo,
          height: 150,
        ),
      ),
    );
  }
}*/


/*
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';

import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';
import '../../../../utils/device/movementdetector.dart';
import '../../../dashboard/screen/dashboard.dart';
import '../../../../services/LocationController.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/text_strings.dart';

// Globals
const _bgPortName = 'bg_location_port';
final ValueNotifier<LocationDto?> lastLocation = ValueNotifier<LocationDto?>(null);
Timer? _tick;
LocationDto? _lastFix;

@pragma('vm:entry-point')
void initCallback(dynamic _) {
  _tick?.cancel();
  late MovementDetector movementDetector;
  bool isMoving = false;

  _tick = Timer.periodic(const Duration(seconds: 1), (_) {
    final l = _lastFix;
    if (l != null) {
      print('AppDebug: BG Tick lat=${l.latitude}, lng=${l.longitude}, acc=${l.accuracy}');
      LocationController(l.latitude, l.longitude).sendLocationData();
      movementDetector = MovementDetector(
        onMovement: (moving) {
         // setState(() => isMoving = moving);
          print(moving ? " Phone moving" : " Phone still");
          print("sensor_of_phone $isMoving");
        },
      );
      movementDetector.start();
    }
  });
}

@pragma('vm:entry-point')
void locationCallback(LocationDto data) {
  _lastFix = data;
  IsolateNameServer.lookupPortByName(_bgPortName)?.send(data);
}

@pragma('vm:entry-point')
void disposeCallback() => _tick?.cancel();

@pragma('vm:entry-point')
void notificationCallback() {
  print('AppDebug: Notification tapped');
}

void _registerBgPort(void Function(LocationDto) onLocation) {
  print('AppDebug: BG port register event fireed.');
  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping(_bgPortName);
  IsolateNameServer.registerPortWithName(port.sendPort, _bgPortName);

  port.listen((msg) {
    if (msg is LocationDto) {
      lastLocation.value = msg;
      print('AppDebug: BG port received lat=${msg.latitude}, lng=${msg.longitude}');
      onLocation(msg);
    }
  });
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    print('AppDebug: Splash started');

    // 1️⃣ Check if location permissions are already granted
    final fgStatus = await Permission.location.status;
    final bgStatus = await Permission.locationAlways.status;

    if (!fgStatus.isGranted || !bgStatus.isGranted) {
      // Show disclosure only if permissions are NOT granted
      print('AppDebug: Permissions not granted, showing disclosure');
      await _showDisclosureDialog();
    } else {
      print('AppDebug: Permissions already granted, skipping disclosure');
      await _initBackgroundLocator();
      _checkForUpdateAndLogin();
    }
  }

  Future<void> _showDisclosureDialog() async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Location Access Required"),
        content: const Text(
            "Gluckscare collects your location even when the app is closed or not in use. "
                "We use this data to track your sales visits and provide accurate reporting. "
                "Your location is never shared with third parties."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Continue")),
        ],
      ),
    ) ?? false;

    if (!accepted) exit(0);

    print('AppDebug: User accepted disclosure, requesting permissions');
    await _requestPermissionsAndStart();
    _checkForUpdateAndLogin();
  }

  Future<void> _requestPermissionsAndStart() async {
    final fg = await Permission.location.request();
    if (!fg.isGranted) return _showDisclosureDialog();

    final bg = await Permission.locationAlways.request();
    if (!bg.isGranted) return _showDisclosureDialog();

    await _initBackgroundLocator();
  }

  Future<void> _initBackgroundLocator() async {
    try {
      await BackgroundLocator.initialize();
      await Future.delayed(const Duration(seconds: 1));
      await BackgroundLocator.registerLocationUpdate(
        locationCallback,
        initCallback: initCallback,
        disposeCallback: disposeCallback,
        androidSettings: const AndroidSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          interval: 1000,
          distanceFilter: 0,
          client: LocationClient.google,
          androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: 'Location tracking',
            notificationTitle: 'Background Location Running',
            notificationMsg: 'App uses your location in the background for tracking.',
            notificationTapCallback: notificationCallback,
          ),
        ),
        iosSettings: const IOSSettings(),
        autoStop: false,
      );
      _registerBgPort((_) {});
      print('AppDebug: BackgroundLocator initialized ✅');
    } catch (e) {
      print('AppDebug: BackgroundLocator failed: $e');
    }
  }

  Future<void> _checkForUpdateAndLogin() async {
    print('AppDebug: Checking for update');
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _showUpdateDialog();
      } else {
        _navigateAfterDelay();
      }
    } catch (_) {
      _navigateAfterDelay();
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(TTexts.updateAvailable),
        content: const Text(TTexts.updateAvailableContent),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateAfterDelay();
              },
              child: const Text(TTexts.skip)),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await InAppUpdate.performImmediateUpdate();
                } catch (_) {
                  _navigateAfterDelay();
                }
              },
              child: const Text(TTexts.updateNow)),
        ],
      ),
    );
  }

  Future<void> _navigateAfterDelay() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");

    await Future.delayed(const Duration(seconds: 2));

    if (userId != null && userId.isNotEmpty) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(TImages.lightAppLogo, height: 150),
      ),
    );
  }
}*/

// chat gpt 5 code

/*

import 'dart:developer' as dev;
import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';

import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';
import '../../../../utils/device/movementdetector.dart';
import '../../../dashboard/screen/dashboard.dart';
import '../../../../services/LocationController.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/text_strings.dart';

import 'package:background_locator_2/location_dto.dart';


// Globals
const _bgPortName = 'bg_location_port';
final ValueNotifier<LocationDto?> lastLocation = ValueNotifier<LocationDto?>(null);
Timer? _tick;
LocationDto? _lastFix;

@pragma('vm:entry-point')
void initCallback(dynamic _) {
  _tick?.cancel();
  late MovementDetector movementDetector;
  bool isMoving = false;

  _tick = Timer.periodic(const Duration(seconds: 1), (_) {
    final l = _lastFix;
    if (l != null) {
      print('AppDebug: BG Tick lat=${l.latitude}, lng=${l.longitude}, acc=${l.accuracy}');
      LocationController(l.latitude, l.longitude).sendLocationData();

      // Movement detection
      movementDetector = MovementDetector(
        onMovement: (moving) {
          print(moving ? "Phone moving" : "Phone still");
          print("sensor_of_phone: $isMoving");
        },
      );
      movementDetector.start();
    } else {
      print("AppDebug: No location fix received yet.");
    }
  });
}




*/
/*@pragma('vm:entry-point')
void locationCallback(LocationDto data) {
  _lastFix = data;

  // Ensure that port is registered before sending data to the port
  final port = IsolateNameServer.lookupPortByName(_bgPortName);
  if (port != null) {
    print("AppDebug: Sending location data to port.");
    port.send(data);
  } else {
    print("AppDebug: BG port not found.");
    // Register the port if it isn't found yet
    _registerBgPort((LocationDto locationData) {
      print('AppDebug: Location data received after port registered: lat=${locationData.latitude}, lng=${locationData.longitude}');
    });
  }
}*//*


@pragma('vm:entry-point')
void locationCallback(LocationDto data) {
  print('AppDebug: Received location data. Lat: ${data.latitude}, Lng: ${data.longitude}, Acc: ${data.accuracy}');
  _lastFix = data; // Update _lastFix with the new location data

  // Ensure that the port is registered before sending data to the port
  final port = IsolateNameServer.lookupPortByName(_bgPortName);
  if (port != null) {
    print("AppDebug: Sending location data to port. Lat: ${data.latitude}, Lng: ${data.longitude}");
    port.send(data); // Send location data to the registered port
  } else {
    print("AppDebug: BG port not found.");
    // Register the port if it isn't found yet
    _registerBgPort((LocationDto locationData) {
      print('AppDebug: Location data received after port registered: lat=${locationData.latitude}, lng=${locationData.longitude}');
    });
  }
}







*/
/*void _registerBgPort(void Function(LocationDto) onLocation) {
  print('AppDebug: BG port register event fired.');

  // Check if the port is already registered before proceeding
  if (IsolateNameServer.lookupPortByName(_bgPortName) != null) {
    print("AppDebug: Port already registered.");
    return; // Exit if already registered
  }

  // Create a ReceivePort to listen for messages
  final port = ReceivePort();

  // Remove any existing port name mappings to avoid conflicts
  IsolateNameServer.removePortNameMapping(_bgPortName);

  // Register the port with a unique name to be looked up later
  IsolateNameServer.registerPortWithName(port.sendPort, _bgPortName);

  // Start listening to the port for incoming location updates
  port.listen((msg) {
    if (msg is LocationDto) {
      lastLocation.value = msg;
      print('AppDebug: BG port received lat=${msg.latitude}, lng=${msg.longitude}');

      // Call the function provided to handle the location data
      onLocation(msg);
    } else {
      print('AppDebug: Unexpected message received: $msg');
    }
  });
}*//*


void _registerBgPort(void Function(LocationDto) onLocation) {
  print('AppDebug: BG port register event fired.');

  // Check if the port is already registered before proceeding
  final existingPort = IsolateNameServer.lookupPortByName(_bgPortName);
  if (existingPort != null) {
    print("AppDebug: Port already registered.");
    return; // Exit if already registered
  }

  // Create a ReceivePort to listen for messages
  final port = ReceivePort();

  // Remove any existing port name mappings to avoid conflicts
  IsolateNameServer.removePortNameMapping(_bgPortName);

  // Register the port with a unique name to be looked up later
  IsolateNameServer.registerPortWithName(port.sendPort, _bgPortName);

  // Start listening to the port for incoming location updates
  port.listen((msg) {
    print("AppDebug: Port listener triggered.");
    if (msg is LocationDto) {
      lastLocation.value = msg;
      print('AppDebug: BG port received lat=${msg.latitude}, lng=${msg.longitude}');
      onLocation(msg); // Call the function provided to handle the location data
    } else {
      print('AppDebug: Unexpected message received: $msg');
    }
  });

  print('AppDebug: Port registration completed.');
}




void onLocation(LocationDto locationData) {
  print('AppDebug: Location data received in onLocation: Lat=${locationData.latitude}, Lng=${locationData.longitude}');
  // You can add additional logic here to process the location data
}





@pragma('vm:entry-point')
void disposeCallback() {
  _tick?.cancel();
  print("AppDebug: Background location service stopped.");
}

@pragma('vm:entry-point')
void notificationCallback() {
  print('AppDebug: Notification tapped');
}




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _startFlow();
  }

  // Simulate location update for testing


  Future<void> _startFlow() async {
    print('AppDebug: Splash started');

    // Register the background port right after app starts
    _registerBgPort((locationData) {
      print("AppDebug: Received location data: $locationData");
    });

    //  Check if location permissions are already granted
    final fgStatus = await Permission.location.status;
    final bgStatus = await Permission.locationAlways.status;

    if (!fgStatus.isGranted || !bgStatus.isGranted) {
      // Show disclosure only if permissions are NOT granted
      print('AppDebug: Permissions not granted, showing disclosure');
      await _showDisclosureDialog();
    } else {
      print('AppDebug: Permissions already granted, skipping disclosure');
      await _initBackgroundLocator();
      _checkForUpdateAndLogin();
    }
  }


  Future<void> _showDisclosureDialog() async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Location Access Required"),
        content: const Text(
            "Gluckscare collects your location even when the app is closed or not in use. "
                "We use this data to track your sales visits and provide accurate reporting. "
                "Your location is never shared with third parties."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Continue")),
        ],
      ),
    ) ?? false;

    if (!accepted) exit(0);

    print('AppDebug: User accepted disclosure, requesting permissions');
    await _requestPermissionsAndStart();
    _checkForUpdateAndLogin();
  }

  // workig with andoird 13
  */
/*Future<void> _requestPermissionsAndStart() async {
    final fg = await Permission.location.request();
    if (!fg.isGranted) return _showDisclosureDialog();

    final bg = await Permission.locationAlways.request();
    if (!bg.isGranted) return _showDisclosureDialog();

    await _requestNotificationPermission();

    // Register the port as soon as permissions are granted
    _registerBgPort((locationData) {
      print("AppDebug: Received location data: $locationData");
    });

    await _initBackgroundLocator();
  }*//*





  Future<void> _requestPermissionsAndStart() async {

    await _requestNotificationPermission();


    // Step 1: Request foreground location permission (ACCESS_FINE_LOCATION)
    final fg = await Permission.location.request();
    if (!fg.isGranted) {
      print('AppDebug: Foreground permission denied.');
      return; // Exit if foreground location permission is not granted
    }

    // Step 2: Request background location permission (ACCESS_BACKGROUND_LOCATION)
    final bg = await Permission.locationAlways.request();
    if (!bg.isGranted) {
      print('AppDebug: Background permission denied.');
      return; // Exit if background location permission is not granted
    }

    print('AppDebug: Permissions granted for both foreground and background.');



    // Proceed with background location initialization
    await _initBackgroundLocator();
  }

  Future<void> _requestNotificationPermission() async {
    // Request permission to show notifications
    final status = await Permission.notification.request();

    if (status.isGranted) {
      print("Notification permission granted.");
    } else {
      print("Notification permission denied.");
    }
  }




  Future<void> _initBackgroundLocator() async {
    try {
      await BackgroundLocator.initialize();
      await Future.delayed(const Duration(seconds: 1));

      // Register the background location update with proper settings
      await BackgroundLocator.registerLocationUpdate(
        locationCallback,
        initCallback: initCallback,
        disposeCallback: disposeCallback,
        androidSettings: AndroidSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          interval: 1000, // Every second
          distanceFilter: 0, // Update location immediately
          client: LocationClient.google,
          androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: 'Location tracking',
            notificationTitle: 'Background Location Running',
            notificationMsg: 'App uses your location in the background for tracking.',
            notificationTapCallback: notificationCallback,
          ),
        ),
        iosSettings: IOSSettings(),
        autoStop: false, // Keep running in background
      );


      _registerBgPort((_) {});
      print('AppDebug: BackgroundLocator initialized ');
    } catch (e) {
      print('AppDebug: BackgroundLocator failed: $e');
    }
  }




  Future<void> _checkForUpdateAndLogin() async {
    print('AppDebug: Checking for update');
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _showUpdateDialog();
      } else {
        _navigateAfterDelay();
      }
    } catch (_) {
      _navigateAfterDelay();
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(TTexts.updateAvailable),
        content: const Text(TTexts.updateAvailableContent),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateAfterDelay();
              },
              child: const Text(TTexts.skip)),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await InAppUpdate.performImmediateUpdate();
                } catch (_) {
                  _navigateAfterDelay();
                }
              },
              child: const Text(TTexts.updateNow)),
        ],
      ),
    );
  }



  Future<void> _navigateAfterDelay() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");

    await Future.delayed(const Duration(seconds: 2));

    if (userId != null && userId.isNotEmpty) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(TImages.lightAppLogo, height: 150),
      ),
    );
  }
}
*/




/*

import 'dart:io';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:in_app_update/in_app_update.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';
import '../../../dashboard/screen/dashboard.dart';
import '../../../../utils/constants/image_strings.dart';

// Request permission in foreground before starting background service
Future<bool> requestLocationPermission() async {
  PermissionStatus permissionStatus = await Permission.locationWhenInUse.request();
  if (Platform.isAndroid) {
    PermissionStatus backgroundPermissionStatus = await Permission.locationAlways.request();
    if (!backgroundPermissionStatus.isGranted) {
      return false; // Background location permission is not granted
    }
  }

  return permissionStatus.isGranted;
}

// Top-level onStart method for the background service
@pragma('vm:entry-point')  // Add this annotation for background access
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

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

  // Update every second with new location and timestamp
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        String location = await getCurrentLocation(); // Static method call

        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'Location: $location',
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
          content: "Location: $location",
        );
      }
    }

    debugPrint("SplashScreen: FLUTTER BACKGROUND SERVICE: ${DateTime.now()}");

    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    // Fetch current location
    String location = await getCurrentLocation();

    // Debug print to check lat and long
    debugPrint("SplashScreen: Current Location - $location");

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
        "location": location, // Add location here
      },
    );
  });
}

// Static method for getting current location
@pragma('vm:entry-point')  // Add this annotation for background access
Future<String> getCurrentLocation() async {
  try {
// Request location permission if not granted
    geolocator.LocationPermission permission = await geolocator.Geolocator.requestPermission();
    if (permission == geolocator.LocationPermission.denied ||
        permission == geolocator.LocationPermission.deniedForever) {
      return 'Location permission denied';
    }

// Fetch the current position
    geolocator.Position position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high);
    return 'Lat: ${position.latitude}, Long: ${position.longitude}';
  } catch (e) {
    return 'Error fetching location: $e';
  }
}

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
    _startLocationFetching(); // Start location fetching in background
  }

// Initialize Background Location Fetching
  Future<void> _startLocationFetching() async {
    print("[SplashScreen] Starting background location service...");

// Check and request location permissions
    bool isLocationGranted = await requestLocationPermission();
    if (!isLocationGranted) {
      print("[SplashScreen] Location permission denied.");
      return;
    }

// Start background location fetching
    await initializeService();

    print("[SplashScreen] Location service initialized and running.");
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

// Create notification channel before starting the service
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Initialize flutter_local_notifications for Android and iOS
    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

// Create notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

// Configure the background service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,  // Use top-level function
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'AWESOME SERVICE',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart, // Use top-level function
        onBackground: onIosBackground,
      ),
    );
  }

// Callback for iOS background
  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final log = preferences.getStringList('log') ?? <String>[];
    log.add(DateTime.now().toIso8601String());
    await preferences.setStringList('log', log);

    debugPrint("SplashScreen: onIosBackground called");

    return true;
  }

// Check for app update
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

// Show Update Dialog
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

// Perform Immediate Update
  Future<void> _startImmediateUpdate() async {
    try {
      print("[UpdateStart] Starting immediate update...");
      AuthManager authManager = AuthManager();
      await authManager.logout();

      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      print("[UpdateStart] Immediate update failed: $e");
      _checkLoginStatus(); // Continue app flow even if update fails
    }
  }

// Check Login Session
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
        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
}*/

// working with andoird 15 tab
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';

import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';
import '../../../../utils/device/movementdetector.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../../../dashboard/screen/dashboard.dart';
import '../../../../services/LocationController.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/text_strings.dart';


// Globals
const _bgPortName = 'bg_location_port';
final ValueNotifier<LocationDto?> lastLocation = ValueNotifier<LocationDto?>(null);
Timer? _tick;
LocationDto? _lastFix;

@pragma('vm:entry-point')
void initCallback(dynamic _) {
  _tick?.cancel();
  late MovementDetector movementDetector;
  bool isMoving = false;

  _tick = Timer.periodic(const Duration(seconds: 60), (_) {
    final l = _lastFix;
    if (l != null) {
      print('AppDebug: BG Tick lat=${l.latitude}, lng=${l.longitude}, acc=${l.accuracy}');
      LocationController(l.latitude, l.longitude).sendLocationData();

      // Movement detection
      movementDetector = MovementDetector(
        onMovement: (moving) {
          print(moving ? "Phone moving" : "Phone still");
        },
      );
      movementDetector.start();
    } else {
      print("AppDebug: No location fix received yet.");
    }
  });
}

@pragma('vm:entry-point')
void locationCallback(LocationDto data) {
  print('AppDebug: Received location data. Lat: ${data.latitude}, Lng: ${data.longitude}, Acc: ${data.accuracy}');
  _lastFix = data; // Update _lastFix with the new location data

  // Ensure that the port is registered before sending data to the port
  final port = IsolateNameServer.lookupPortByName(_bgPortName);
  if (port != null) {
    print("AppDebug: Sending location data to port. Lat: ${data.latitude}, Lng: ${data.longitude}");
    port.send(data); // Send location data to the registered port
  } else {
    print("AppDebug: BG port not found.");
    // Register the port if it isn't found yet
    _registerBgPort((LocationDto locationData) {
      print('AppDebug: Location data received after port registered: lat=${locationData.latitude}, lng=${locationData.longitude}');
    });
  }
}

void _registerBgPort(void Function(LocationDto) onLocation) {
  print('AppDebug: BG port register event fired.');

  // Check if the port is already registered before proceeding
  final existingPort = IsolateNameServer.lookupPortByName(_bgPortName);
  if (existingPort != null) {
    print("AppDebug: Port already registered.");
    return; // Exit if already registered
  }

  // Create a ReceivePort to listen for messages
  final port = ReceivePort();

  // Remove any existing port name mappings to avoid conflicts
  IsolateNameServer.removePortNameMapping(_bgPortName);

  // Register the port with a unique name to be looked up later
  IsolateNameServer.registerPortWithName(port.sendPort, _bgPortName);

  // Start listening to the port for incoming location updates
  port.listen((msg) {
    print("AppDebug: Port listener triggered.");
    if (msg is LocationDto) {
      lastLocation.value = msg;
      print('AppDebug: BG port received lat=${msg.latitude}, lng=${msg.longitude}');
      onLocation(msg); // Call the function provided to handle the location data
    } else {
      print('AppDebug: Unexpected message received: $msg');
    }
  });

  print('AppDebug: Port registration completed.');
}

void onLocation(LocationDto locationData) {
  print('AppDebug: Location data received in onLocation: Lat=${locationData.latitude}, Lng=${locationData.longitude}');
  // You can add additional logic here to process the location data
}

@pragma('vm:entry-point')
void disposeCallback() {
  _tick?.cancel();
  print("AppDebug: Background location service stopped.");
}

@pragma('vm:entry-point')
void notificationCallback() {
  print('AppDebug: Notification tapped');
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startFlow();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null) {
        print('FCM Foreground: ${notification.title}');

        showPushNotification(
          title: notification.title ?? 'New Message',
          body: notification.body ?? '',
        );
      }
    });

  }

  Future<void> _startFlow() async {
    print('AppDebug: Splash started');

    // Register the background port right after app starts
    _registerBgPort((locationData) {
      print("AppDebug: Received location data: $locationData");
    });

    // Check if location permissions are already granted
    final fgStatus = await Permission.location.status;
    final bgStatus = await Permission.locationAlways.status;

    if (!fgStatus.isGranted || !bgStatus.isGranted) {
      // Show disclosure only if permissions are NOT granted
      print('AppDebug: Permissions not granted, showing disclosure');
      await _showDisclosureDialog();
    } else {
      print('AppDebug: Permissions already granted, skipping disclosure');
      await _initBackgroundLocator();
      _checkForUpdateAndLogin();
    }
  }

  Future<void> _showDisclosureDialog() async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Location Access Required"),
        content: const Text(
            "Gluckscare collects your location even when the app is closed or not in use. "
                "We use this data to track your sales visits and provide accurate reporting. "
                "Your location is never shared with third parties."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Continue")),
        ],
      ),
    ) ?? false;

    if (!accepted) exit(0);

    print('AppDebug: User accepted disclosure, requesting permissions');
    await _requestPermissionsAndStart();
    _checkForUpdateAndLogin();
  }

  void showPushNotification({
    required String title,
    required String body,
  }) {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'push_channel', //  NEW channel (separate from location)
      'Push Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails =
    NotificationDetails(android: androidDetails);

    flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      notificationDetails,
    );
  }


  Future<void> _requestPermissionsAndStart() async {
    await _requestNotificationPermission();

    // Step 1: Request foreground location permission (ACCESS_FINE_LOCATION)
    final fg = await Permission.location.request();
    if (!fg.isGranted) {
      print('AppDebug: Foreground permission denied.');
      return; // Exit if foreground location permission is not granted
    }

    // Step 2: Request background location permission (ACCESS_BACKGROUND_LOCATION)
    final bg = await Permission.locationAlways.request();
    if (!bg.isGranted) {
      print('AppDebug: Background permission denied.');
      return; // Exit if background location permission is not granted
    }

    print('AppDebug: Permissions granted for both foreground and background.');

    // Proceed with background location initialization
    await _initBackgroundLocator();
  }

  Future<void> _requestNotificationPermission() async {
    // Request permission to show notifications
    final status = await Permission.notification.request();

    if (status.isGranted) {
      print("Notification permission granted.");
    } else {
      print("Notification permission denied.");
    }
  }


  Future<void> _initBackgroundLocator() async {
    try {
      await BackgroundLocator.initialize();
      await Future.delayed(const Duration(seconds: 1));

      // Register the background location update with proper settings
      await BackgroundLocator.registerLocationUpdate(
        locationCallback,
        initCallback: initCallback,
        disposeCallback: disposeCallback,
        androidSettings: AndroidSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          interval: 1000, // Every second
          distanceFilter: 0, // Update location immediately
          client: LocationClient.google,
          androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: 'Location tracking',
            notificationTitle: 'Background Location Running',
            notificationMsg: 'App uses your location in the background for tracking.',
            notificationTapCallback: notificationCallback,
          ),
        ),
        iosSettings: IOSSettings(),
        autoStop: false, // Keep running in background
      );

      _registerBgPort((_) {});
      print('AppDebug: BackgroundLocator initialized ');
    } catch (e) {
      print('AppDebug: BackgroundLocator failed: $e');
    }
  }

  Future<void> _checkForUpdateAndLogin() async {
    print('AppDebug: Checking for update');
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _showUpdateDialog();
      } else {
        _navigateAfterDelay();
      }
    } catch (_) {
      _navigateAfterDelay();
    }
  }

  /*void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(TTexts.updateAvailable),
        content: const Text(TTexts.updateAvailableContent),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateAfterDelay();
              },
              child: const Text(TTexts.skip)),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await InAppUpdate.performImmediateUpdate();
                } catch (_) {
                  _navigateAfterDelay();
                }
              },
              child: const Text(TTexts.updateNow)),
        ],
      ),
    );
  }*/

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(TTexts.updateAvailable),
        content: const Text(TTexts.updateAvailableContent),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateAfterDelay(); // Continue normal flow if skipped
            },
            child: const Text(TTexts.skip),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                print("AppDebug: User opted to update now.");
                await InAppUpdate.performImmediateUpdate();

                //  After successful update, navigate directly to LoginScreen
                print("AppDebug: Update completed successfully. Navigating to LoginScreen.");
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false, // Clear all previous routes
                  );
                }
              } catch (e) {
                print("AppDebug: Immediate update failed: $e");
                _navigateAfterDelay(); // Continue normal flow if update fails
              }
            },
            child: const Text(TTexts.updateNow),
          ),
        ],
      ),
    );
  }


  Future<void> _navigateAfterDelay() async {
    final AuthManager authManager = AuthManager();

    final String? userId = await authManager.getUserId();
    final String? token  = await authManager.getAuthToken();

    await Future.delayed(const Duration(seconds: 2));

    // BOTH must exist
    if (userId != null &&
        userId.isNotEmpty &&
        token != null &&
        token.isNotEmpty) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );

    } else {
      // clean broken session (optional but recommended)
      await authManager.logout();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(TImages.lightAppLogo, height: 150),
      ),
    );
  }
}

