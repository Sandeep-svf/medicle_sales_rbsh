import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'LocationServices.dart';


class BackgroundService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  static Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        isForegroundMode: true, // Keeps service running in foreground
        notificationChannelId: "background_location",
        initialNotificationTitle: "Location Service Running",
        initialNotificationContent: "Fetching user location...",
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        onBackground: _onStart,
        onForeground: _onStart,
      ),
    );
  }

  static Future<void> startService() async {
    await _service.startService();
  }
}

/// Background task: Fetches location every 10 seconds
@pragma('vm:entry-point')
Future<bool> _onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService(); // Keeps running even if app is closed
  }

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    Position? position = await LocationService.fetchLocation();

    if (position != null) {
      String message = "✅ Location: ${position.latitude}, ${position.longitude}";
      print(message);
      showSnackbar(message);
    } else {
      String errorMessage = "❌ Error: Unable to fetch location.";
      print(errorMessage);
      showSnackbar(errorMessage);
    }
  });

  return true; // ✅ Fix: Return Future<bool>
}

/// Show a Snackbar when location updates
void showSnackbar(String message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  });
}

/// Create a global navigator key to access context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
