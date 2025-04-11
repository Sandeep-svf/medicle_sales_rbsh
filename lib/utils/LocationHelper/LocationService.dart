/*
// location_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Timer? _timer;

  static Future<void> start(ServiceInstance service) async {
    // Ensure location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // Ensure service is running in foreground
    if (service is AndroidServiceInstance && !await service.isForegroundService()) {
      service.setAsForegroundService();
    }

    // Start periodic location updates
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final lat = position.latitude;
        final lon = position.longitude;

        if (kDebugMode) {
          print('[LocationService] Latitude: $lat, Longitude: $lon');
        }

        service.invoke('locationUpdate', {
          'latitude': lat,
          'longitude': lon,
        });
      } catch (e) {
        if (kDebugMode) {
          print('[LocationService] Error: $e');
        }
      }
    });
  }

  static void stop() {
    _timer?.cancel();
  }
}
*/
