import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';

import '../core/engine/tracking_engine_persisted.dart';
import '../core/model/location_point.dart';
import '../debug/tracking_console_logger.dart';
import '../service/tracking_health_monitor.dart';
import '../storage/app_state_dao.dart';
import '../storage/upload_queue_dao.dart';
import '../storage/upload_queue_drainer.dart';

@pragma('vm:entry-point')
void locationServiceEntry(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  GeolocatorAndroid.registerWith();
  trackingConsoleLog('LocationService', 'Entrypoint started.');

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: 'Tracking active',
      content: 'Sales tracking is running',
    );
    trackingConsoleLog(
      'LocationService',
      'Android foreground service notification configured.',
    );
  }

  final appStateDao = AppStateDao();
  final healthMonitor = TrackingHealthMonitor(appStateDao: appStateDao);
  final trackingSessionId = await _initializeTrackingState(
    appStateDao,
    healthMonitor,
  );
  final engine = TrackingEnginePersisted();
  final queueDrainer = UploadQueueDrainer(UploadQueueDao());
  trackingConsoleLog(
    'LocationService',
    'Tracking storage initialized. GPS interval=10s, upload interval=30s.',
  );

  unawaited(_drainQueue(queueDrainer, 'service-start'));
  Timer.periodic(const Duration(seconds: 30), (_) {
    unawaited(_drainQueue(queueDrainer, '30-second timer'));
  });

  var heartbeatRunning = false;
  Timer.periodic(const Duration(minutes: 1), (_) async {
    if (heartbeatRunning) {
      return;
    }

    heartbeatRunning = true;
    try {
      await healthMonitor.recordHeartbeat();
      trackingConsoleLog('LocationService', 'Heartbeat saved.');
    } catch (error, stackTrace) {
      trackingConsoleError(
        'LocationService',
        'Could not persist tracking heartbeat.',
        error,
        stackTrace,
      );
    } finally {
      heartbeatRunning = false;
    }
  });

  service.on('request_last_location').listen((_) async {
    try {
      final last = await engine.loadLastPoint();
      if (last == null) {
        trackingConsoleLog(
          'LocationService',
          'Last-location request: no saved location found.',
        );
        return;
      }

      trackingConsoleLog(
        'LocationService',
        'Last location loaded: lat=${last.latitude}, lng=${last.longitude}, '
            'accuracy=${last.accuracy}, speed=${last.speed}, '
            'time=${last.timestampUtc.toIso8601String()}.',
      );

      service.invoke('gps_update', {
        'lat': last.latitude,
        'lng': last.longitude,
        'speed': last.speed,
        'accuracy': last.accuracy,
        'time': last.timestampUtc.toIso8601String(),
      });
    } catch (error, stackTrace) {
      trackingConsoleError(
        'LocationService',
        'Could not restore last location.',
        error,
        stackTrace,
      );
    }
  });

  var gpsPollRunning = false;
  Timer.periodic(const Duration(seconds: 10), (_) async {
    if (gpsPollRunning) {
      trackingConsoleLog(
        'LocationService',
        'GPS poll skipped because the previous poll is still running.',
      );
      return;
    }

    gpsPollRunning = true;
    try {
      trackingConsoleLog('LocationService', 'Requesting current GPS point...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      final point = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        timestampUtc: position.timestamp.toUtc(),
      );

      trackingConsoleLog(
        'LocationService',
        'GPS received: lat=${point.latitude}, lng=${point.longitude}, '
            'accuracy=${point.accuracy}, speed=${point.speed}, '
            'time=${point.timestampUtc.toIso8601String()}.',
      );

      await engine.process(point, trackingSessionId);
      trackingConsoleLog('LocationService', 'GPS point processing completed.');
      service.invoke('gps_update', {
        'lat': point.latitude,
        'lng': point.longitude,
        'speed': point.speed,
        'accuracy': point.accuracy,
        'time': point.timestampUtc.toIso8601String(),
      });
    } catch (error, stackTrace) {
      trackingConsoleError(
        'LocationService',
        'GPS poll failed.',
        error,
        stackTrace,
      );
    } finally {
      gpsPollRunning = false;
    }
  });
}

Future<String> _initializeTrackingState(
  AppStateDao appStateDao,
  TrackingHealthMonitor healthMonitor,
) async {
  while (true) {
    try {
      trackingConsoleLog(
        'LocationService',
        'Initializing tracking database and session...',
      );
      final trackingSessionId =
          await appStateDao.getOrCreateTrackingSessionId();
      await appStateDao.set(
        'last_background_start',
        DateTime.now().toUtc().toIso8601String(),
      );
      await healthMonitor.recordServiceStarted();
      trackingConsoleLog(
        'LocationService',
        'Tracking session and initial heartbeat saved.',
      );
      return trackingSessionId;
    } catch (error, stackTrace) {
      trackingConsoleError(
        'LocationService',
        'Tracking storage initialization failed; retrying.',
        error,
        stackTrace,
      );
      await Future<void>.delayed(const Duration(seconds: 10));
    }
  }
}

Future<void> _drainQueue(
  UploadQueueDrainer queueDrainer,
  String trigger,
) async {
  trackingConsoleLog('LocationService', 'Queue drain triggered by $trigger.');
  final result = await queueDrainer.drainAvailable();
  trackingConsoleLog(
    'LocationService',
    'Queue drain finished: hadWork=${result.hadWork}, '
        'processed=${result.processedCount}, retry=${result.shouldRetry}, '
        'busy=${result.busy}.',
  );
}
