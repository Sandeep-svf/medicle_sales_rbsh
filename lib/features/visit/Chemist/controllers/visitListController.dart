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

      final String apiUrl = "$fetchApiUrl/chemist-visits/user/$userId";
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
        final List<dynamic> listJson = json.decode(response.body) as List<dynamic>;
        _visitList = listJson
            .whereType<Map<String, dynamic>>()
            .map((m) => ChemistVisitModel.fromJson(m))
            .toList();
        notifyListeners();
      }

    } catch (e) {
      // Log any errors that occur during the fetch process
      if (kDebugMode) {
        debugPrint("Visit Sales Controller: Error fetching sales data: $e");
      }
    }
  }
}
