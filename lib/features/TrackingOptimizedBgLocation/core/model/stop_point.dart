enum StopStatus { open, closed }

class StopPoint {
  final String stopId;
  final DateTime localDate;
  final int stopIndex;

  final double latitude;
  final double longitude;
  final double radiusMeters;

  final DateTime startTimeUtc;
  DateTime? endTimeUtc;

  Duration duration; //  THIS IS THE SOURCE OF TRUTH
  StopStatus status;

  StopPoint({
    required this.stopId,
    required this.localDate,
    required this.stopIndex,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.startTimeUtc,
    this.endTimeUtc,
    required this.duration,
    required this.status,
  });

  //  FROM DB → OBJECT
  factory StopPoint.fromMap(Map<String, dynamic> map) {
    return StopPoint(
      stopId: map['stop_id'] as String,
      localDate: DateTime.parse(map['local_date'] as String),
      stopIndex: map['stop_index'] as int,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      radiusMeters: (map['radius_meters'] as num).toDouble(),
      startTimeUtc: DateTime.parse(map['start_time_utc'] as String),
      endTimeUtc: map['end_time_utc'] != null
          ? DateTime.parse(map['end_time_utc'] as String)
          : null,

      //  FIX: convert seconds → Duration
      duration: Duration(
        seconds: map['duration_seconds'] as int,
      ),

      status: StopStatus.values.firstWhere(
            (e) => e.name == map['status'],
      ),
    );
  }

  //  OBJECT → DB
  Map<String, dynamic> toMap() {
    return {
      'stop_id': stopId,
      'local_date': localDate.toIso8601String(),
      'stop_index': stopIndex,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'start_time_utc': startTimeUtc.toIso8601String(),
      'end_time_utc': endTimeUtc?.toIso8601String(),

      //  FIX: Duration → seconds
      'duration_seconds': duration.inSeconds,

      'status': status.name,
    };
  }
}
