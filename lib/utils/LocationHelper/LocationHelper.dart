import 'package:geolocator/geolocator.dart';

class LocationHelper {
  // Method to check if location permission is granted
  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission if denied
      permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
    }

    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  // Method to fetch the current location (latitude, longitude)
  Future<String?> getCurrentLocation() async {
    // Check for location permission first
    bool hasPermission = await _checkLocationPermission();

    if (!hasPermission) {
      return Future.error('Location permission denied');
    }

    try {
      // Get the current position of the user
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Return the location as a string: "latitude,longitude"
      return '${position.latitude},${position.longitude}';
    } catch (e) {
      return Future.error('Failed to get location: $e');
    }
  }
}
