import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicle_sales_rbsh/features/TrackingOptimizedBgLocation/core/model/location_point.dart';
import 'package:permission_handler/permission_handler.dart';

import '../background/location_service.dart';
import '../storage/upload_queue_dao.dart';
import '../storage/upload_queue_drainer.dart';
import '../utils/oem_settings_helper.dart';
import 'tracking_debug_state.dart';
import '../core/model/stop_point.dart';
import 'debug_repository.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final List<String> _gpsPoints = [];
  List<LocationPoint> _dbLocations = [];
  List<StopPoint> _dbStops = [];
  static const _log = '[DEBUG_SCREEN]';

  late final UploadQueueDao _uploadQueueDao;
  late final UploadQueueDrainer _drainer;


  final repo = DebugRepository();
  final service = FlutterBackgroundService();
  int _gpsCount = 0;
  String _lastLatLng = '--';
  double _lastSpeed = 0.0;

  int stops = 0;
  int stopSeconds = 0;
  double distance = 0;

  bool serviceRunning = false;
  Timer? _refreshTimer;

  String get lastLatLng {
    final p = TrackingDebugState.lastPoint;
    if (p == null) return '--';
    return '${p.latitude.toStringAsFixed(6)}, '
        '${p.longitude.toStringAsFixed(6)}';
  }

  List<String> get debugPoints {
    return TrackingDebugState.points
        .takeLast(5) // show last 5 points only
        .map((p) =>
    '${p.latitude.toStringAsFixed(6)}, '
        '${p.longitude.toStringAsFixed(6)}')
        .toList();
  }

  @override
  void initState() {
    super.initState();

    _uploadQueueDao = UploadQueueDao();
    _drainer = UploadQueueDrainer(_uploadQueueDao);

    _init();
  }
  Future<void> createTrackingChannel() async {
    final plugin = FlutterLocalNotificationsPlugin();

    const channel = AndroidNotificationChannel(
      'tracking_channel',
      'Tracking Service',
      description: 'Foreground service for location tracking',
      importance: Importance.low, //  MUST be low
    );

    await plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }



  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ---------------- INIT ----------------

  Future<void> _init() async {
    final ok = await _requestPermissions();
    if (!ok) return;
    await createTrackingChannel();
    await _startService();
    await _load();

    // Drain every 10 seconds
    Timer.periodic(
      const Duration(seconds: 10),
          (_) => _drainer.drainOnce(),
    );

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        if (mounted) _load();
      },
    );

  }

  // ---------------- PERMISSIONS ----------------

  bool _permissionInProgress = false;

  Future<bool> _requestPermissions() async {
    if (_permissionInProgress) return false;
    _permissionInProgress = true;

    try {
      // 1️⃣ Foreground location
      final fg = await Permission.location.request();
      if (!fg.isGranted) return false;

      // 2️⃣ Background location
      final bg = await Permission.locationAlways.request();
      if (!bg.isGranted) {
        await openAppSettings();
        return false;
      }

      // 3️⃣ Notifications
      await Permission.notification.request();

      // 4️⃣ Battery optimization
      final battery = await Permission.ignoreBatteryOptimizations.request();
      if (!battery.isGranted) {
        debugPrint('Battery optimization not ignored');
      }

      return true;
    } finally {
      _permissionInProgress = false;
    }
  }


  Future<void> requestBatteryWhitelist() async {
    final status = await Permission.ignoreBatteryOptimizations.status;

    if (!status.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  // ---------------- SERVICE ----------------

  Future<void> _startService() async {
    final running = await service.isRunning();
    if (!running) {
      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: locationServiceEntry,
          isForegroundMode: true,
          notificationChannelId: 'tracking_channel',
          initialNotificationTitle: 'Tracking active',
          initialNotificationContent: 'Sales tracking is running',
          foregroundServiceNotificationId: 1001,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
        ),
      );


      //  LISTEN FOR DEBUG STATE (THIS WAS MISSING)
      service.on('debug_state').listen((event) {
        if (event == null) return;

        debugPrint('$_log debug_state → $event');

        setState(() {
          TrackingDebugState.acceptedGps =
              event['acceptedGps'] ?? TrackingDebugState.acceptedGps;

          TrackingDebugState.rejectedGps =
              event['rejectedGps'] ?? TrackingDebugState.rejectedGps;

          TrackingDebugState.lastSpeed =
              (event['lastSpeed'] ?? 0.0).toDouble();

          final stopMinutes = event['activeStopMinutes'];
          if (stopMinutes != null) {
            TrackingDebugState.activeStop =
                TrackingDebugState.activeStop; // already set by engine
          }
        });
      });


      await service.startService();
    }

    //  LISTEN FOR GPS UPDATES
    service.on('gps_update').listen((event) {
      if (!mounted || event == null) return;

      final lat = event['lat'] as double?;
      final lng = event['lng'] as double?;
      final speed = (event['speed'] as num?)?.toDouble() ?? 0.0;


      debugPrint('$_log GPS event received → $event');

      if (lat == null || lng == null) {
        debugPrint('$_log GPS event missing lat/lng');
        return;
      }

      setState(() {
        _gpsCount++;
        _lastLatLng = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

        _lastSpeed = speed * 3.6; //  m/s → km/h

        _gpsPoints.add(_lastLatLng);
        if (_gpsPoints.length > 5) {
          _gpsPoints.removeAt(0);
        }
      });

      debugPrint('$_log UI updated → lastLatLng=$_lastLatLng, gpsCount=$_gpsCount');
    });


    // THIS IS THE MISSING LINE
    service.invoke('request_last_location');

    serviceRunning = true;
    if (mounted) setState(() {});
  }



  // ---------------- DATA ----------------

  Future<void> _load() async {
    if (!mounted) return;

    final today =
    DateTime.now().toIso8601String().substring(0, 10);

    debugPrint('$_log Loading summary stats for $today');

    stops = await repo.stopsToday(today);
    stopSeconds = await repo.totalStopDurationToday(today);
    distance = await repo.totalDistanceToday(today);

    debugPrint('$_log Stats → stops=$stops, stopSeconds=$stopSeconds, distance=$distance');

    //  LOAD DB DATA (THIS WAS MISSING)
    _dbLocations = await repo.recentLocations();
    _dbStops = await repo.recentStops();

    debugPrint('$_log DB locations count = ${_dbLocations.length}');
    debugPrint('$_log DB stops count = ${_dbStops.length}');

    if (_dbLocations.isNotEmpty) {
      final p = _dbLocations.first;
      debugPrint('$_log Latest DB location → ${p.latitude}, ${p.longitude}');
    }

    if (_dbStops.isNotEmpty) {
      final s = _dbStops.first;
      debugPrint(
        '$_log Latest stop → duration=${s.duration.inMinutes} min '
            'lat=${s.latitude}, lng=${s.longitude}',
      );
    }

    if (mounted) setState(() {});
  }



  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking Debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Divider(),
          const Text(
            'Debug screen – not for MR users',
            style: TextStyle(color: Colors.red),
          ),

          const Divider(),

          _statusTile(),
          const Divider(),

          _debugBadge(),


          _tile('Last GPS', _lastLatLng),
          _tile('GPS Points Count', _gpsCount.toString()),


          ..._gpsPoints.map(
                (p) => _tile('GPS', p),
          ),


          ElevatedButton(
            onPressed: () => OemSettingsHelper.open(),
            child: const Text('Disable Battery Optimization (OEM)'),
          ),


          _tile('Stops Today', stops.toString()),
          _tile(
            'Total Stop Time',
            '${(stopSeconds / 60).toStringAsFixed(1)} min',
          ),
          _tile(
            'Distance Today',
            '${(distance / 1000).toStringAsFixed(2)} km',
          ),

          const Text('DB: Location Points', style: TextStyle(fontWeight: FontWeight.bold)),

          ..._dbLocations.map((p) => _tile(
            'LOC',
            '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}',
          )),

          const Divider(),
          const Text('DB: Stops', style: TextStyle(fontWeight: FontWeight.bold)),

          ..._dbStops.map((s) => _tile(
            'STOP',
            '${s.duration.inMinutes} min @ '
                '${s.latitude.toStringAsFixed(5)}, '
                '${s.longitude.toStringAsFixed(5)}',
          )),


        ],
      ),
    );
  }

  Widget _statusTile() {
    return ListTile(
      title: const Text('Tracking Service'),
      trailing: Text(
        serviceRunning ? 'RUNNING' : 'STOPPED',
        style: TextStyle(
          color: serviceRunning ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _tile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}


Widget _debugBadge() {
  final stop = TrackingDebugState.activeStop;

  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badgeRow('Accepted GPS', TrackingDebugState.acceptedGps.toString()),
        _badgeRow('Rejected GPS', TrackingDebugState.rejectedGps.toString()),
        _badgeRow(
          'Speed',
          '${TrackingDebugState.lastSpeed.toStringAsFixed(2)} m/s',
        ),
        _badgeRow(
          'Active Stop',
          stop == null
              ? 'NO'
              : 'YES (${stop.duration.inMinutes} min)',
        ),
      ],
    ),
  );
}

Widget _badgeRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}


extension TakeLast<E> on List<E> {
  List<E> takeLast(int n) {
    if (length <= n) return this;
    return sublist(length - n);
  }
}

