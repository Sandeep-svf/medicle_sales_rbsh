import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../models/visitSalesData.dart';

class VisitListController with ChangeNotifier {
  AuthManager authManager = AuthManager();

  List<VisitSalesLogModel> _visitList = [];
  String? userId;

  List<VisitSalesLogModel> get salesList => _visitList;

  final String fetchApiUrl = THttpHelper.baseUrl;

  // Fetch sales list from the server
  Future<void> fetchSalesList() async {
    try {
      // Fetch userId from SharedPreferences
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

      final String apiUrl = "$fetchApiUrl/doctors/by-head-office/$userId";
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
        List<dynamic> data = jsonDecode(response.body);

        // Map the data to VisitSalesLogModel and update the visit list
        _visitList = data.map((item) => VisitSalesLogModel.fromJson(item)).toList();

        // Debugging: Log the fetched and mapped list
        if (kDebugMode) {
          debugPrint("Visit Sales Controller: Mapped sales logs: $_visitList");
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
