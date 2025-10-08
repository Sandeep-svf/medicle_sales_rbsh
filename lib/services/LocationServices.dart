/*

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'LocationSample.dart';


class LocationService {
  LocationService(this._repo);

  final LocationRepository _repo;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Listen to events
    bg.BackgroundGeolocation.onLocation((bg.Location loc) {
      final c = loc.coords;
      _repo.add(LocationSample(
        latitude: c.latitude,
        longitude: c.longitude,
        timestamp: DateTime.now(),
        isMoving: loc.isMoving ?? false,
      ));
      // You can also ship to server here.
    });

    bg.BackgroundGeolocation.onMotionChange((bg.Location loc) {
      final c = loc.coords;
      _repo.add(LocationSample(
        latitude: c.latitude,
        longitude: c.longitude,
        timestamp: DateTime.now(),
        isMoving: loc.isMoving ?? false,
      ));
    });

    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent e) {
      // Log or react to provider changes (gps disabled, etc).
      // print('[providerchange] $e');
    });

    // Configure
    final state = await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 20.0,
      stopOnTerminate: false,     // keep running after swipe‑away
      startOnBoot: true,          // resume on device reboot
      foregroundService: true,    // ensure FGS
      debug: true,                // dev only
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      // Optional HTTP config if you push to a server:
      // url: 'https://your.api/locations',
      // batchSync: true,
      // autoSync: true,
    ));

    if (!state.enabled) {
      await bg.BackgroundGeolocation.start();
    }

    _initialized = true;
  }

  Future<void> start() => bg.BackgroundGeolocation.start();
  Future<void> stop() => bg.BackgroundGeolocation.stop();

  Future<void> getOneShot() async {
    await bg.BackgroundGeolocation.getCurrentPosition(samples: 1, persist: true);
  }
}
*/
