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
import 'features/authentication/screens/onboarding/splash.dart';
import 'features/salesActivity/controllers/SalesController.dart';
import 'app.dart';
import 'dart:async';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(DashboardController());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SalesController()),
      ],
      child: const App(),  // just your App widget
    ),
  );
}
