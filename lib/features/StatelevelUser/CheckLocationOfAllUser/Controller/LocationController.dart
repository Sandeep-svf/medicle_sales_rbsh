import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../Model/UserLocationListModel.dart';

class LocationControllerList {
  final String baseUrl;

  LocationControllerList({required this.baseUrl});

  // API URL: {{base_url}}locations/state-head/user-24h-data/68aa1486771e77bad145c17a?date=08/25/2025
  Future<List<UserLocationListModel>> fetchUserLocationData(String userId, String date) async {
    // Constructing the API URL
    final String apiUrl = '$baseUrl/locations/state-head/user-24h-data/$userId?date=$date';
    AuthManager authManager = AuthManager();
    final token = authManager.getAuthToken();
    try {
      // Making the GET request to the API
      final response = await http.get(Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },);

      if (response.statusCode == 200) {
        // Parsing the JSON response
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extracting location data from the response
        List<UserLocationListModel> locations = List<UserLocationListModel>.from(
            responseData['location'].map((x) => UserLocationListModel.fromJson(x))
        );

        // Filtering the list based on latitude and longitude
        List<UserLocationListModel> filteredLocations = _filterLocationsByLatLong(locations);

        return filteredLocations;
      } else {
        throw Exception('Failed to load location data');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  // Filtering the locations to create a new list of latitudes and longitudes
  List<UserLocationListModel> _filterLocationsByLatLong(List<UserLocationListModel> locations) {
    List<UserLocationListModel> filteredLocations = [];

    for (var location in locations) {
      // Add logic for filtering if needed (e.g., only add locations within a specific range of lat/long)
      if (location.latitude != null && location.longitude != null) {
        filteredLocations.add(location);
      }
    }

    return filteredLocations;
  }
}


