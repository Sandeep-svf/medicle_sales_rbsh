import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import '../storage/app_state_dao.dart';
import '../storage/upload_queue_dao.dart';
import '../storage/upload_queue_drainer.dart';

import '../core/engine/tracking_engine_persisted.dart';
import '../core/model/location_point.dart';

@pragma('vm:entry-point')
@pragma('vm:entry-point')
void locationServiceEntry(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // ===============================
  // PHASE-2: BACKGROUND RESTART MARK
  // ===============================
  final appStateDao = AppStateDao();
  await appStateDao.set(
    'last_background_start',
    DateTime.now().toUtc().toIso8601String(),
  );


  final engine = TrackingEnginePersisted();


  // ===============================
  // PHASE-2: BACKGROUND QUEUE DRAIN
  // ===============================
  final uploadQueueDao = UploadQueueDao();
  final queueDrainer = UploadQueueDrainer(uploadQueueDao);

  // Drain every 30s even if UI never opens
  Timer.periodic(
    const Duration(seconds: 30),
        (_) async {
      await queueDrainer.drainOnce();
    },
  );

  Timer.periodic(const Duration(minutes: 1), (_) {
    print('[HEARTBEAT] location service alive ${DateTime.now()}');
  });



  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: 'Tracking active',
      content: 'Sales tracking is running',
    );
  }

  //  UI RECONNECT HANDLER (APP REOPEN / AFTER KILL)
  service.on('request_last_location').listen((_) async {
    final last = await engine.loadLastPoint();
    if (last == null) return;

    service.invoke('gps_update', {
      'lat': last.latitude,
      'lng': last.longitude,
      'speed': last.speed,
      'accuracy': last.accuracy,
      'time': last.timestampUtc.toIso8601String(),
    });
  });

  //  GPS LOOP
  Timer.periodic(const Duration(seconds: 10), (_) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final point = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        timestampUtc: DateTime.now().toUtc(),
      );

      //  SINGLE SOURCE OF TRUTH
      await engine.process(point);

      //  LIVE UPDATE (FOR UI IF OPEN)
      service.invoke('gps_update', {
        'lat': point.latitude,
        'lng': point.longitude,
        'speed': point.speed,
        'accuracy': point.accuracy,
        'time': point.timestampUtc.toIso8601String(),
      });

      print('DEBUG LAT: ${point.latitude}');
      print('DEBUG LNG: ${point.longitude}');
      print('DEBUG speed: ${point.speed}');
      print('DEBUG accuracy: ${point.accuracy}');
      print('DEBUG time: ${point.timestampUtc.toIso8601String()}');
    } catch (e) {
      print('GPS ERROR: $e');
    }
  });
}

