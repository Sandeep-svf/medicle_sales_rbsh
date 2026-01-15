class TrackingState {
  final double lastLat;
  final double lastLng;
  final DateTime lastTimestampUtc;
  final String? activeStopId;
  final String? activeTripId;

  TrackingState({
    required this.lastLat,
    required this.lastLng,
    required this.lastTimestampUtc,
    this.activeStopId,
    this.activeTripId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'last_lat': lastLat,
      'last_lng': lastLng,
      'last_timestamp_utc': lastTimestampUtc.toIso8601String(),
      'active_stop_id': activeStopId,
      'active_trip_id': activeTripId,
    };
  }

  factory TrackingState.fromMap(Map<String, dynamic> map) {
    return TrackingState(
      lastLat: map['last_lat'],
      lastLng: map['last_lng'],
      lastTimestampUtc:
      DateTime.parse(map['last_timestamp_utc']),
      activeStopId: map['active_stop_id'],
      activeTripId: map['active_trip_id'],
    );
  }
}
