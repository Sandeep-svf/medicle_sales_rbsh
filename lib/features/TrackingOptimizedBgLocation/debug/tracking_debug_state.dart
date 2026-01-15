import '../core/model/location_point.dart';
import '../core/model/stop_point.dart';
import '../core/model/trip.dart';
import '../core/location/location_decision.dart';

class TrackingDebugState {
  static LocationPoint? lastPoint;

  //  NEW: store all points (debug only)
  static final List<LocationPoint> points = [];

  static StopPoint? activeStop;
  static Trip? activeTrip;
  static LocationDecision? lastDecision;

  static int acceptedGps = 0;
  static int rejectedGps = 0;

  static double lastSpeed = 0;


  static int? activeStopMinutes;



}
