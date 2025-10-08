import 'dart:async';

class LocationSample {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final bool isMoving;

  const LocationSample({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.isMoving,
  });
}

class LocationRepository {
  final _controller = StreamController<LocationSample>.broadcast();

  Stream<LocationSample> get stream => _controller.stream;

  void add(LocationSample s) => _controller.add(s);

  Future<void> dispose() async => _controller.close();
}
