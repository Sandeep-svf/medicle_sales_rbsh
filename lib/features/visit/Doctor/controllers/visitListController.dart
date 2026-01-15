import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl for date formatting

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../models/visitSalesData.dart';

enum VisitDateFilter { today, last7Days, last15Days, custom }

class VisitListController with ChangeNotifier {
  AuthManager authManager = AuthManager();

  List<VisitSalesLogModel> _visitList = [];
  String? userId;
  bool _isLoading = false;

  List<VisitSalesLogModel> get salesList => _visitList;
  bool get isLoading => _isLoading;

  final String fetchApiUrl = THttpHelper.baseUrl;

  // Fetch sales list with dynamic filters
  Future<void> fetchSalesList({
    VisitDateFilter filter = VisitDateFilter.today,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    notifyListeners(); // Notify UI to show loading

    try {
      userId = await authManager.getUserId();

      if (kDebugMode) {
        debugPrint("Visit Sales Controller: Fetching sales data for user id: $userId");
      }

      if (userId == null) {
        debugPrint("Visit Sales Controller: User ID is null. Cannot fetch sales data.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      String apiUrl = "$fetchApiUrl/doctor-visits/user/$userId";
      String queryParams = "";

      // Determine Query Parameters based on filter
      switch (filter) {
        case VisitDateFilter.today:
          queryParams = "?range=today";
          break;
        case VisitDateFilter.last7Days:
          queryParams = "?range=last7days";
          break;
        case VisitDateFilter.last15Days:
          queryParams = "?range=last15days";
          break;
        case VisitDateFilter.custom:
          if (startDate != null && endDate != null) {
            final DateFormat formatter = DateFormat('yyyy-MM-dd');
            String start = formatter.format(startDate);
            String end = formatter.format(endDate);
            queryParams = "?startDate=$start&endDate=$end";
          } else {
            // Fallback to today if dates are missing
            queryParams = "?range=today";
          }
          break;
      }

      final String fullUrl = "$apiUrl$queryParams";

      if (kDebugMode) {
        debugPrint("Visit Sales Controller: Fetching data from API: $fullUrl");
      }

      // Send the HTTP request
      final response = await http.get(Uri.parse(fullUrl));

      if (kDebugMode) {
        debugPrint("Visit Sales Controller: Response Status Code: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _visitList = data.map((item) => VisitSalesLogModel.fromJson(item)).toList();

        if (kDebugMode) {
          debugPrint("Visit Sales Controller: Mapped sales logs count: ${_visitList.length}");
        }
      } else {
        throw Exception("Failed to fetch sales logs. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Visit Sales Controller: Error fetching sales data: $e");
      }
      _visitList = []; // Clear list on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}