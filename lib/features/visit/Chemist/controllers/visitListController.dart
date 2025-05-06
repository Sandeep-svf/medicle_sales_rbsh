import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../models/ChemisVisitModel.dart';

class VisitListController with ChangeNotifier {
  AuthManager authManager = AuthManager();

  List<ChemistVisitModel> _visitList = [];
  String? userId;

  List<ChemistVisitModel> get salesList => _visitList;

  final String fetchApiUrl = THttpHelper.baseUrl;

  // Fetch visits list from the server
  Future<void> fetchVisitList() async {
    try {
      userId = await authManager.getUserId();

      // Debugging: Log the userId
      if (kDebugMode) {
        debugPrint("Visit Sales Controller: Fetching sales data for user id: $userId");
      }

      if (userId == null) {
        // Log error if userId is null
        debugPrint("Visit Sales Controller: User ID is null. Cannot fetch sales data.");
        return;
      }

      final String apiUrl = "$fetchApiUrl/chemists/visits/user/$userId";
      if (kDebugMode) {
        debugPrint("Visit Sales Controller: Fetching data from API: $apiUrl");
      }

      // Send the HTTP request
      final response = await http.get(Uri.parse(apiUrl));

      // Log the response status code
      if (kDebugMode) {
        debugPrint("Visit Sales Controller: Response Status Code: ${response.statusCode}");
      }

      // Handle successful response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if the response body contains a "Data" key
        if (responseData['success'] == "true" && responseData.containsKey('Data')) {
          // Extract the list of visits from the response map
          List<dynamic> data = responseData['Data'];

          // Map the data to ChemistVisitModel and update the visit list
          _visitList = data.map((item) => ChemistVisitModel.fromJson(item)).toList();

          // Debugging: Log the fetched and mapped list
          if (kDebugMode) {
            debugPrint("Visit Sales Controller: Mapped sales logs: $_visitList");
          }

          // Notify listeners to refresh the UI
          notifyListeners();
        } else {
          debugPrint("Visit Sales Controller: 'Data' key not found in the response or success flag is false.");
        }
      } else {
        throw Exception("Failed to fetch sales logs. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      // Log any errors that occur during the fetch process
      if (kDebugMode) {
        debugPrint("Visit Sales Controller: Error fetching sales data: $e");
      }
    }
  }
}
