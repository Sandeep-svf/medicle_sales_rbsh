import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../models/visitSalesData.dart'; // Ensure this has StockistVisit model

// Ideally defined globally, but redefining here for context
enum VisitDateFilter { today, last7Days, last15Days, custom }

class VisitListController with ChangeNotifier {
  AuthManager authManager = AuthManager();

  List<StockistVisit> _visitList = [];
  String? userId;
  bool _isLoading = false;

  List<StockistVisit> get salesList => _visitList;
  bool get isLoading => _isLoading;

  final String fetchApiUrl = THttpHelper.baseUrl;

  Future<void> fetchSalesList({
    VisitDateFilter filter = VisitDateFilter.today,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      userId = await authManager.getUserId();

      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      String apiUrl = "$fetchApiUrl/stockist-visits/user/$userId";
      String queryParams = "";

      // Filter Logic
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
            queryParams = "?range=today";
          }
          break;
      }

      final String fullUrl = "$apiUrl$queryParams";

      if (kDebugMode) {
        debugPrint("Stockist Visit Controller: Fetching: $fullUrl");
      }

      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _visitList = data.map((item) => StockistVisit.fromJson(item)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Stockist Visit Controller: Error: $e");
      }
      _visitList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}