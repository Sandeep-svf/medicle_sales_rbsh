/*


import 'dart:developer' as dev;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:medicle_sales_rbsh/services/LocationController.dart';
import 'package:provider/provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';

import 'features/SalesChartAnalysis/controller/DashboardController.dart';
import 'features/salesActivity/controllers/SalesController.dart';
import 'app.dart';
import 'dart:async';
// ========= Globals =========
const _bgPortName = 'bg_location_port';
final ValueNotifier<LocationDto?> lastLocation = ValueNotifier<LocationDto?>(null);

Timer? _tick;
LocationDto? _lastFix;


@pragma('vm:entry-point')
void initCallback(dynamic _) {
  dev.log('init started', name: 'BG loc');
  _tick?.cancel();
  _tick = Timer.periodic(const Duration(seconds: 1), (_) {
    final l = _lastFix;
    if (l != null) {
      print('BG loc: ${l.latitude}, ${l.longitude}, acc=${l.accuracy}');

      // in initCallback ticker:
      dev.log('BG loc: ${l.latitude}, ${l.longitude}, acc=${l.accuracy}', name: 'BG loc');

      final locationController = LocationController(l.latitude,l.longitude);
      locationController.sendLocationData();


    } else {
      print('BG loc: waiting for first fix...');
    }
  });
}

@pragma('vm:entry-point')
void locationCallback(LocationDto data) {
  _lastFix = data; // store latest; heartbeat prints every second
  // forward to UI if alive (no prints here)
  // in locationCallback:
  dev.log('got fix lat=${data.latitude}, lng=${data.longitude}', name: 'BG loc');
  IsolateNameServer.lookupPortByName(_bgPortName)?.send(data);
}

@pragma('vm:entry-point')
void disposeCallback() {
  _tick?.cancel();
}




@pragma('vm:entry-point')
void notificationCallback() {}

void _registerBgPort(void Function(LocationDto) onLocation) {
  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping(_bgPortName);
  IsolateNameServer.registerPortWithName(port.sendPort, _bgPortName);

  port.listen((msg) {
    if (msg is LocationDto) {
      lastLocation.value = msg; // <-- read lat/lng from here anywhere in UI
      debugPrint('BG loc: ${msg.latitude}, ${msg.longitude}, acc=${msg.accuracy}');
      debugPrint('BG loc: running..');
      onLocation(msg);
    }
  });
}

// ========= Bootstrap widget (starts perms + tracking AFTER first frame) =========
class _Bootstrap extends StatefulWidget {
  final Widget child;
  const _Bootstrap({required this.child});

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!Platform.isAndroid) return;

    // 1) Ask permissions
    final fg = await Permission.location.request();
    final bg = await Permission.locationAlways.request();
    final nt = await Permission.notification.request();
    debugPrint(
        'Perms -> fg:${fg.isGranted} bg:${bg.isGranted} notif:${nt.isGranted}');



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
          // <-- switch to Fused
          androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: 'Location tracking',
            notificationTitle: 'Background Location running',
            notificationMsg: 'App uses your location in the background to support essential features.',
            notificationTapCallback: notificationCallback,
          ),
        ),
        iosSettings: const IOSSettings(),
        autoStop: false,
      );
      debugPrint('BG started: registration OK');
    } catch (e) {
      debugPrint('BG start FAILED: $e');
    }
    final running = await BackgroundLocator.isServiceRunning();
    debugPrint('BG running: $running');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the port BEFORE starting service (don’t await anything here)
  _registerBgPort((_) { */
/* optional: forward to a controller / API *//*
 });
  Get.put(DashboardController());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SalesController()),
      ],
      child: _Bootstrap(child: const App()),
    ),
  );
}




*/

import 'dart:developer' as dev;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:medicle_sales_rbsh/services/LocationController.dart';
import 'package:medicle_sales_rbsh/utils/offline_model/BaseOfflineModel.dart';
import 'package:provider/provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';

import 'features/SalesChartAnalysis/controller/DashboardController.dart';
import 'features/addDoctor/models/DoctorOfflineModel.dart';
import 'features/addDoctor/services/SyncService.dart';
import 'features/authentication/screens/onboarding/splash.dart';
import 'features/salesActivity/controllers/SalesController.dart';
import 'app.dart';
import 'dart:async';

import 'features/ticket/controller/TicketController.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(DashboardController()); // Register DashboardController
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SalesController()),
      ],
      child: const App(),  // just your App widget
    ),
  );
}
/*
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request location permission
  bool isLocationGranted = await requestLocationPermission();

  if (isLocationGranted) {
    await initializeService();
    runApp(const MyApp());
  } else {
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text("Permission Denied")),
          body: const Center(child: Text("Location permission is required to use this app")),
        ),
      ),
    );
  }
}

Future<bool> requestLocationPermission() async {
  // Request permission to access location
  PermissionStatus status = await Permission.locationWhenInUse.request();
  if (status.isGranted) {
    return true;
  } else {
    return false;
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Create notification channel before starting the service
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description: 'This channel is used for important notifications.', // description
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
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Configure the background service
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // This will be executed when app is in the foreground or background in a separate isolate
      onStart: onStart,

      // Auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      // Auto start service
      autoStart: true,

      // This will be executed when app is in the foreground in a separated isolate
      onForeground: onStart,

      // You have to enable background fetch capability in the Xcode project
      onBackground: onIosBackground,
    ),
  );
}

// Ensure this is executed
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for Flutter 3.0.0 and later
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

  // Update every second with new location and timestamp
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
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "Stop Service";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;
                String? device = data["device"];
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Column(
                  children: [
                    Text(device ?? 'Unknown'),
                    Text(date.toString()),
                  ],
                );
              },
            ),
            ElevatedButton(
              child: const Text("Foreground Mode"),
              onPressed: () =>
                  FlutterBackgroundService().invoke("setAsForeground"),
            ),
            ElevatedButton(
              child: const Text("Background Mode"),
              onPressed: () =>
                  FlutterBackgroundService().invoke("setAsBackground"),
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                final service = FlutterBackgroundService();
                var isRunning = await service.isRunning();
                isRunning
                    ? service.invoke("stopService")
                    : service.startService();

                setState(() {
                  text = isRunning ? 'Start Service' : 'Stop Service';
                });
              },
            ),
            const Expanded(
              child: LogView(),
            ),
          ],
        ),
      ),
    );
  }
}

class LogView extends StatefulWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final Timer timer;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.reload();
      logs = sp.getStringList('log') ?? [];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs.elementAt(index);
        return Text(log);
      },
    );
  }
}
*/

// code with debug print

/*

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request location permission
  bool isLocationGranted = await requestLocationPermission();

  if (isLocationGranted) {
    await initializeService();
    runApp(const MyApp());
  } else {
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text("Permission Denied")),
          body: const Center(child: Text("Location permission is required to use this app")),
        ),
      ),
    );
  }
}

Future<bool> requestLocationPermission() async {
  // Request permission to access location (both foreground and background)
  PermissionStatus permissionStatus = await Permission.locationWhenInUse.request();

  // Check for background location permission (Android specific)
  if (Platform.isAndroid) {
    PermissionStatus backgroundPermissionStatus = await Permission.locationAlways.request();
    if (!backgroundPermissionStatus.isGranted) {
      return false; // Background location permission is not granted
    }
  }

  if (permissionStatus.isGranted) {
    return true;
  } else {
    return false; // Location permission is denied
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Create notification channel before starting the service
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description: 'This channel is used for important notifications.', // description
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
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Configure the background service
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
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
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

// Ensure this is executed
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  debugPrint("LocationFetching: onIosBackground called");

  return true;
}

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

  // Update every second with new location and timestamp
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'Location: ${await getCurrentLocation()}',
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
          content: "Location: ${await getCurrentLocation()}",
        );
      }
    }

    debugPrint("LocationFetching: FLUTTER BACKGROUND SERVICE: ${DateTime.now()}");

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
    debugPrint("LocationFetching: Current Location - $location");

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

// Fetch the current location
Future<String> getCurrentLocation() async {
  try {
    // Request location permission if not granted
    LocationPermission permission = await geolocator.Geolocator.requestPermission();
    if (permission == geolocator.LocationPermission.denied || permission == geolocator.LocationPermission.deniedForever) {
      return 'Location permission denied';
    }

    // Fetch the current position
    geolocator.Position position = await geolocator.Geolocator.getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.high);
    return 'Lat: ${position.latitude}, Long: ${position.longitude}';
  } catch (e) {
    return 'Error fetching location: $e';
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "Stop Service";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;
                String? device = data["device"];
                String? location = data["location"];
                return Column(
                  children: [
                    Text(device ?? 'Unknown'),
                    Text(location ?? 'Unknown location'),
                  ],
                );
              },
            ),
            ElevatedButton(
              child: const Text("Foreground Mode"),
              onPressed: () =>
                  FlutterBackgroundService().invoke("setAsForeground"),
            ),
            ElevatedButton(
              child: const Text("Background Mode"),
              onPressed: () =>
                  FlutterBackgroundService().invoke("setAsBackground"),
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                final service = FlutterBackgroundService();
                var isRunning = await service.isRunning();
                isRunning
                    ? service.invoke("stopService")
                    : service.startService();

                setState(() {
                  text = isRunning ? 'Start Service' : 'Stop Service';
                });
              },
            ),
            const Expanded(
              child: LogView(),
            ),
          ],
        ),
      ),
    );
  }
}

class LogView extends StatefulWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final Timer timer;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.reload();
      logs = sp.getStringList('log') ?? [];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs.elementAt(index);
        return Text(log);
      },
    );
  }
}
*/

