import 'package:uuid/uuid.dart';

import '../core/model/location_point.dart';
import '../core/model/stop_point.dart';
import '../core/model/trip.dart';
import '../utils/geo_utils.dart';

class TripDetector {
  final _uuid = const Uuid();

  Trip? _activeTrip;
  LocationPoint? _lastPoint;
  DateTime? _currentLocalDate;

  ///  READ-ONLY getter (fixes your error)
  Trip? get activeTrip => _activeTrip;

  /// Returns:
  /// - completed Trip (when closed)
  /// - active Trip (when ongoing)
  /// - null (when nothing happened)
  Trip? processLocation(
      LocationPoint point,
      DateTime localNow, {
        StopPoint? activeStop,
        StopPoint? newlyOpenedStop,
      }) {
    _handleDailyReset(localNow);

    //  If a stop just opened → close active trip
    if (newlyOpenedStop != null && _activeTrip != null) {
      final completedTrip = _activeTrip!;
      _closeTrip(
        newlyOpenedStop.startTimeUtc,
        toStopId: newlyOpenedStop.stopId,
      );
      return completedTrip; //  RETURN CLOSED TRIP
    }

    //  If user is currently in a stop → no trip activity
    if (activeStop != null) {
      _lastPoint = null; //  important: stop distance accumulation
      return null;
    }

    // 🚶 User is moving
    return _handleMovement(point);
  }

  // ---------------- PRIVATE ----------------

  void _handleDailyReset(DateTime localNow) {
    final today = DateTime(localNow.year, localNow.month, localNow.day);

    if (_currentLocalDate == null || _currentLocalDate != today) {
      _currentLocalDate = today;

      if (_activeTrip != null) {
        final completedTrip = _activeTrip!;
        _closeTrip(localNow.toUtc());
        // NOTE: engine can persist this if needed
      }
    }
  }

  Trip _handleMovement(LocationPoint point) {
    if (_activeTrip == null) {
      _startTrip(point);
      _lastPoint = point;
      return _activeTrip!;
    }

    if (_lastPoint != null) {
      final delta = GeoUtils.distanceMeters(
        _lastPoint!.latitude,
        _lastPoint!.longitude,
        point.latitude,
        point.longitude,
      );

      //  Guard against GPS spikes
      if (delta < 1000) {
        _activeTrip!.totalDistanceMeters += delta;
      }
    }

    _lastPoint = point;
    return _activeTrip!;
  }

  void _startTrip(LocationPoint point) {
    _activeTrip = Trip(
      tripId: _uuid.v4(),
      localDate: _currentLocalDate!,
      startTimeUtc: point.timestampUtc,
      totalDistanceMeters: 0,
      status: TripStatus.active,
    );
  }

  void _closeTrip(DateTime endTimeUtc, {String? toStopId}) {
    _activeTrip!
      ..endTimeUtc = endTimeUtc
      ..toStopId = toStopId
      ..status = TripStatus.completed;

    _activeTrip = null;
    _lastPoint = null;
  }
}
