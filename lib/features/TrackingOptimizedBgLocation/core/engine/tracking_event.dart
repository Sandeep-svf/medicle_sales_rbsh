
import '../location/location_decision.dart';
import '../model/location_point.dart';
import '../model/stop_point.dart';
import '../model/trip.dart';

class TrackingEvent {
  final LocationPoint point;
  final LocationDecision decision;

  final StopPoint? activeStop;
  final StopPoint? newlyOpenedStop;
  final Trip? activeTrip;
  final Trip? completedTrip;

  TrackingEvent({
    required this.point,
    required this.decision,
    this.activeStop,
    this.newlyOpenedStop,
    this.activeTrip,
    this.completedTrip,
  });
}
