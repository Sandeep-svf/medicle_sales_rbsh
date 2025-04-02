import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/features/visitDoctor/models/visitSalesData.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';

class VisitListController with ChangeNotifier {
  AuthManager authManager = AuthManager();

  List<VisitSalesLogModel> _visitList = [];
  bool _isLoading = false;
  String? userId;

  List<VisitSalesLogModel> get salesList => _visitList;

  bool get isLoading => _isLoading;

  final String fetchApiUrl = THttpHelper.baseUrl;
  final String addApiUrl = THttpHelper.baseUrl;

  /// Fetch sales list from the server
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

      _isLoading = true;
      notifyListeners();

      // Construct the API URL
      final String apiUrl = "$fetchApiUrl/doctor-visits/user/$userId";
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
        // Decode the response body
        List<dynamic> data = jsonDecode(response.body);
        if (kDebugMode) {
          debugPrint("Visit Sales Controller: Fetched ${data.length} sales logs");
        }

        // Map the data to VisitSalesLogModel and update the visit list
        _visitList = data.map((item) => VisitSalesLogModel.fromJson(item)).toList();
      } else {
        // Log error if response status code is not 200
        throw Exception("Failed to fetch sales logs. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      // Log any errors that occur during the fetch process
      if (kDebugMode) {
        debugPrint("Visit Sales Controller: Error fetching sales data: $e");
      }
    } finally {
      // Ensure loading state is turned off even if there is an error
      _isLoading = false;
      notifyListeners();
    }
  }

/// Add new sales data via API
// Placeholder for future implementation of adding new sales data
}
