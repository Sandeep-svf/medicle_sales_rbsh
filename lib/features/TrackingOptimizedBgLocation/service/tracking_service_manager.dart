import 'dart:io';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../background/location_service.dart';

class TrackingServiceManager {
  TrackingServiceManager._();

  static final TrackingServiceManager instance =
  TrackingServiceManager._();

  static const String notificationChannelId = 'tracking_channel';
  static const int notificationId = 1001;

  final FlutterBackgroundService _service =
  FlutterBackgroundService();

  bool _configured = false;

  // =========================================================
  // CONFIGURE SERVICE
  //
  // Call once from main.dart.
  // This does NOT immediately start location tracking.
  // =========================================================
  Future<bool> configure() async {
    if (_configured) {
      return true;
    }

    try {
      if (Platform.isAndroid) {
        await _createAndroidNotificationChannel();
      }

      final configured = await _service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: locationServiceEntry,

          // IMPORTANT:
          // Splash starts service after permissions.
          autoStart: false,

          // Restart service after phone reboot.
          autoStartOnBoot: true,

          isForegroundMode: true,

          notificationChannelId: notificationChannelId,
          initialNotificationTitle: 'Tracking active',
          initialNotificationContent:
          'Sales location tracking is running',

          foregroundServiceNotificationId: notificationId,

          foregroundServiceTypes: [
            AndroidForegroundType.location,
          ],
        ),

        iosConfiguration: IosConfiguration(
          autoStart: false,
        ),
      );

      _configured = configured;

      print(
        '[TrackingServiceManager] configured = $configured',
      );

      return configured;
    } catch (e, s) {
      print(
        '[TrackingServiceManager] configure error: $e',
      );
      print(s);

      return false;
    }
  }

  // =========================================================
  // ENSURE SERVICE RUNNING
  //
  // Safe to call multiple times.
  // =========================================================
  Future<bool> ensureRunning() async {
    try {
      // Safety in case configure wasn't called for some reason.
      if (!_configured) {
        final configured = await configure();

        if (!configured) {
          return false;
        }
      }

      final running = await _service.isRunning();

      if (running) {
        print(
          '[TrackingServiceManager] service already running',
        );

        return true;
      }

      print(
        '[TrackingServiceManager] starting tracking service...',
      );

      final started = await _service.startService();

      print(
        '[TrackingServiceManager] start result = $started',
      );

      return started;
    } catch (e, s) {
      print(
        '[TrackingServiceManager] start error: $e',
      );
      print(s);

      return false;
    }
  }

  Future<bool> isRunning() async {
    try {
      return await _service.isRunning();
    } catch (_) {
      return false;
    }
  }

  // =========================================================
  // ANDROID NOTIFICATION CHANNEL
  // =========================================================
  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      notificationChannelId,
      'Location Tracking',
      description:
      'Shows when background sales location tracking is active.',
      importance: Importance.low,
    );

    final notifications =
    FlutterLocalNotificationsPlugin();

    await notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}