import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

typedef MovementCallback = void Function(bool isMoving);

class MovementDetector {
  final double threshold; // sensitivity
  final Duration stillTimeout;
  final MovementCallback onMovement;

  bool _isMoving = false;
  DateTime? _lastMovementTime;
  late final Stream<AccelerometerEvent> _stream;
  late final StreamSubscription _subscription;

  MovementDetector({
    required this.onMovement,
    this.threshold = 1.0, // smaller = more sensitive
    this.stillTimeout = const Duration(seconds: 1),
  }) {
    _stream = accelerometerEvents;
  }

  void start() {
    _subscription = _stream.listen((AccelerometerEvent event) {
      double acceleration =
      sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      double delta = (acceleration - 9.8).abs();

      if (delta > threshold) {
        if (!_isMoving) {
          _isMoving = true;
          onMovement(true);
        }
        _lastMovementTime = DateTime.now();
      } else {
        if (_isMoving &&
            _lastMovementTime != null &&
            DateTime.now().difference(_lastMovementTime!) > stillTimeout) {
          _isMoving = false;
          onMovement(false);
        }
      }
    });
  }

  void stop() {
    _subscription.cancel();
  }
}
