class LocationPoint {
  final double latitude;
  final double longitude;
  final double accuracy; // meters
  final double speed; // m/s
  final DateTime timestampUtc;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.timestampUtc,
  });

  ///  ADD THIS
  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
      speed: (map['speed'] as num).toDouble(),
      timestampUtc: DateTime.parse(map['timestamp_utc'] as String),
    );
  }

  /// (optional but useful)
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'timestamp_utc': timestampUtc.toIso8601String(),
    };
  }
}
