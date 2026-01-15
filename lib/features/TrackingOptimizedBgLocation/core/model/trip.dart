enum TripStatus { active, completed }

class Trip {
  final String tripId;
  final DateTime localDate;

  final DateTime startTimeUtc;
  DateTime? endTimeUtc;

  final String? fromStopId;
  String? toStopId;

  double totalDistanceMeters;
  TripStatus status;

  Trip({
    required this.tripId,
    required this.localDate,
    required this.startTimeUtc,
    this.endTimeUtc,
    this.fromStopId,
    this.toStopId,
    required this.totalDistanceMeters,
    required this.status,
  });
}
