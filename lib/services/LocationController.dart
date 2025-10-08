import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../utils/device/DeviceInfoHelper.dart';
import '../utils/http/http_client.dart';

class LocationController {
  static const String baseUrlData = THttpHelper.baseUrl;
  static const String apiUrl = '$baseUrlData/location-events';

  final double latitude;
  final double longitude;

  AuthManager authManager = AuthManager();

  // Constructor to initialize latitude and longitude
  LocationController(this.latitude, this.longitude);

  Future<void> sendLocationData() async {
    print("LocationController calling this function...");
    String? deviceId;
    String? userId;

    // Get userId from AuthManager, handle null by assigning an empty string
    userId = await authManager.getUserId();
    if (userId == null) {
      print("Error: userId is null, assigning empty string");
      userId = null; // Assign empty string if null
    }

    // Get deviceId from DeviceInfoHelper, handle null by assigning a default string
    final deviceInfoHelper = DeviceInfoHelper();
    deviceId = await deviceInfoHelper.getDeviceId();
    if (deviceId == null) {
      print("Error: deviceId is null, assigning default value");
      deviceId = "No Device Id found"; // Assign default value if null
    }

    print("LocationController Device ID: $deviceId");
    print("LocationController userId ID: $userId");
    print("LocationController latitude: $latitude");
    print("LocationController longitude : $longitude");



    final Map<String,dynamic> requestData = {

        "user_id": userId,
        "device_id": deviceId,
        "event_type": "location_update",
        "latitude": latitude,
        "longitude": longitude,
        "timestamp": "2025-10-04T10:30:00Z",
        "metadata": {
          "battery_level": 85,
          "network_type": "4g tab test 8 Oct",
          "accuracy": 15.5,
          "speed": 0  //optional
        }



    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      print('LocationController response.body: ${response.body}');
      print('LocationController response.statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('LocationController Location tracing started');
      } else {
        print('LocationController Failed to start location tracing: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while sending location data: $e');
    }
  }
}
