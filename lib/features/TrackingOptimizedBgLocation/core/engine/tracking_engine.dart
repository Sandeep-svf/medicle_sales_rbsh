import '../../stop/stop_detector.dart';
import '../../trip/trip_detector.dart';
import '../location/location_acceptor.dart';
import '../location/location_decision.dart';
import '../model/location_point.dart';
import '../model/trip.dart';
import 'tracking_event.dart';

class TrackingEngine {
  final LocationAcceptor _acceptor;
  final StopDetector _stopDetector;
  final TripDetector _tripDetector;

  TrackingEngine({
    LocationAcceptor? acceptor,
    StopDetector? stopDetector,
    TripDetector? tripDetector,
  })  : _acceptor = acceptor ?? LocationAcceptor(),
        _stopDetector = stopDetector ?? StopDetector(),
        _tripDetector = tripDetector ?? TripDetector();

  TrackingEvent processRawPoint(
      LocationPoint point,
      DateTime localNow,
      ) {
    //  ACCEPTANCE RULES
    final decision = _acceptor.evaluate(point);

    if (decision != LocationDecision.accepted) {
      return TrackingEvent(
        point: point,
        decision: decision,
      );
    }

    //  STOP DETECTION
    final newlyOpenedStop =
    _stopDetector.processLocation(point, localNow);

    final activeStop = _stopDetector.activeStop; //  FIXED

    //  TRIP DETECTION
    final tripResult = _tripDetector.processLocation(
      point,
      localNow,
      activeStop: activeStop,
      newlyOpenedStop: newlyOpenedStop,
    );

    return TrackingEvent(
      point: point,
      decision: decision,
      activeStop: activeStop,
      newlyOpenedStop: newlyOpenedStop,
      activeTrip: _tripDetector.activeTrip, //  FIXED
      completedTrip:
      tripResult?.status == TripStatus.completed ? tripResult : null,
    );
  }
}
