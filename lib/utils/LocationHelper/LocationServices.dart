import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Fetch the current location
  static Future<Position?> fetchLocation() async {
    bool isPermissionGranted = await _checkPermission();
    if (!isPermissionGranted) {
      print("❌ Location permission denied");
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print("❌ Error fetching location: $e");
      return null;
    }
  }

  /// Check and request location permission
  static Future<bool> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // User denied permanently, can't ask again
    }

    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }
}
