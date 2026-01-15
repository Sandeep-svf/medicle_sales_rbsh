import 'package:uuid/uuid.dart';

import '../config/tracking_config.dart';
import '../core/model/location_point.dart';
import '../core/model/stop_point.dart';
import '../utils/geo_utils.dart';

class StopDetector {
  final double stopRadiusMeters = TrackingConfig.stopRadiusMeters;
  final Duration stopTimeThreshold = TrackingConfig.stopTimeThreshold;

  final _uuid = const Uuid();

  StopPoint? _activeStop;

  LocationPoint? _candidatePoint;
  DateTime? _candidateStartTime;

  DateTime? _currentLocalDate;
  int _dailyStopIndex = 0;

  ///  PUBLIC READ-ONLY GETTER (fixes your error)
  StopPoint? get activeStop => _activeStop;

  /// Returns:
  /// - newly opened StopPoint
  /// - null if no new stop
  StopPoint? processLocation(
      LocationPoint point,
      DateTime localNow,
      ) {
    _handleDailyReset(localNow);

    // If stop already active → update or close
    if (_activeStop != null) {
      return _updateActiveStop(point);
    }

    // Otherwise evaluate stop candidate
    return _evaluateCandidate(point);
  }

  // ---------------- PRIVATE ----------------

  void _handleDailyReset(DateTime localNow) {
    final today = DateTime(localNow.year, localNow.month, localNow.day);

    if (_currentLocalDate == null || _currentLocalDate != today) {
      _currentLocalDate = today;
      _dailyStopIndex = 0;

      // Close active stop at day boundary
      if (_activeStop != null) {
        _closeStop(localNow.toUtc());
      }
    }
  }

  StopPoint? _evaluateCandidate(LocationPoint point) {
    if (_candidatePoint == null) {
      _candidatePoint = point;
      _candidateStartTime = point.timestampUtc;
      return null;
    }

    final distance = GeoUtils.distanceMeters(
      _candidatePoint!.latitude,
      _candidatePoint!.longitude,
      point.latitude,
      point.longitude,
    );

    // User moved away → reset candidate
    if (distance > stopRadiusMeters) {
      _candidatePoint = point;
      _candidateStartTime = point.timestampUtc;
      return null;
    }

    final duration =
    point.timestampUtc.difference(_candidateStartTime!);

    if (duration >= stopTimeThreshold) {
      return _openStop(point);
    }

    return null;
  }

  StopPoint _openStop(LocationPoint point) {
    _dailyStopIndex++;

    final stop = StopPoint(
      stopId: _uuid.v4(),
      localDate: _currentLocalDate!,
      stopIndex: _dailyStopIndex,
      latitude: point.latitude,
      longitude: point.longitude,
      radiusMeters: stopRadiusMeters,
      startTimeUtc: _candidateStartTime!,
      duration: Duration.zero,
      status: StopStatus.open,
    );

    _activeStop = stop;
    _candidatePoint = null;
    _candidateStartTime = null;

    return stop;
  }

  StopPoint? _updateActiveStop(LocationPoint point) {
    final distance = GeoUtils.distanceMeters(
      _activeStop!.latitude,
      _activeStop!.longitude,
      point.latitude,
      point.longitude,
    );

    if (distance <= stopRadiusMeters) {
      // Still inside stop → update duration
      _activeStop!.duration =
          point.timestampUtc.difference(_activeStop!.startTimeUtc);
      return null;
    }

    // User moved away → close stop
    _closeStop(point.timestampUtc);
    return null;
  }

  void _closeStop(DateTime endTimeUtc) {
    _activeStop!
      ..endTimeUtc = endTimeUtc
      ..status = StopStatus.closed;

    _activeStop = null;
  }
}
