import '../model/location_point.dart';
import 'location_decision.dart';
import 'dart:math';

class LocationAcceptor {
  LocationPoint? _lastAccepted;

  LocationDecision evaluate(LocationPoint point) {
    if (_lastAccepted == null) {
      _lastAccepted = point;
      return LocationDecision.accepted;
    }

    final speed = point.speed; // m/s
    final distance = _distanceMeters(_lastAccepted!, point);
    final seconds =
        point.timestampUtc.difference(_lastAccepted!.timestampUtc).inSeconds;

    // ---------------- STATIONARY ----------------
    if (speed < 0.5) {
      // User not moving → accept only if first point
      return LocationDecision.rejectedStationary;
    }

    // ---------------- WALKING ----------------
    if (speed < 2.5) {
      // Accept every ~10 sec or >20m
      if (seconds < 10 && distance < 20) {
        return LocationDecision.rejectedNoise;
      }
    }

    // ---------------- VEHICLE ----------------
    else {
      // Accept every ~1–2 sec or >10m
      if (seconds < 2 && distance < 10) {
        return LocationDecision.rejectedNoise;
      }
    }

    _lastAccepted = point;
    return LocationDecision.accepted;
  }

  // ---------------- UTILS ----------------

  double _distanceMeters(LocationPoint a, LocationPoint b) {
    const r = 6371000;
    final dLat = _deg(b.latitude - a.latitude);
    final dLng = _deg(b.longitude - a.longitude);

    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg(a.latitude)) *
            cos(_deg(b.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    return 2 * r * atan2(sqrt(h), sqrt(1 - h));
  }

  double _deg(double d) => d * pi / 180;
}
