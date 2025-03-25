import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// ✅ Initialize the background service for location tracking
  Future<void> initializeService() async {
    debugPrint('LocationTag: inside initializeService.');

    // ✅ Ask for permissions before starting the service
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      debugPrint("LocationTag: Permission denied. Service not started.");
      return;
    }

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: false,  // ✅ Runs in background without notification
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    // ✅ Start service & wait for it to actually start
    bool started = await service.startService();
    if (started) {
      debugPrint("LocationTag: Background Service Started Successfully");
    } else {
      debugPrint("LocationTag: Background Service Failed to Start");
    }
  }

  /// ✅ iOS Background Execution Handler
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    debugPrint("LocationTag: Running in iOS background");
    return true;
  }

  /// ✅ Background Execution for Android & iOS
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    debugPrint('LocationTag: inside onStart.');

    DartPluginRegistrant.ensureInitialized();

    // ✅ Ensure location permissions are granted before proceeding
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      debugPrint("LocationTag: Stopping service due to permission denial.");
      service.stopSelf();
      return;
    }

    debugPrint("LocationTag: Service is now running!");

    // ✅ Periodically Fetch Location
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        debugPrint(
            'LocationTag: Lat: ${position.latitude}, Long: ${position.longitude}');
      } catch (e) {
        debugPrint('LocationTag: Error getting location: $e');
      }
    });
  }

  /// ✅ Request Location Permissions
  static Future<bool> _requestPermission() async {
    debugPrint("LocationTag: Requesting location permissions...");

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('LocationTag: Location services are disabled.');
      return false;
    }

    var permission = await Permission.location.request();
    var backgroundPermission = await Permission.locationAlways.request();

    if (permission.isGranted && backgroundPermission.isGranted) {
      debugPrint("LocationTag: Location permission granted!");
      return true;
    }

    debugPrint("LocationTag: Location permission denied.");
    return false;
  }
}
