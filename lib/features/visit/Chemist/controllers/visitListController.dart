import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../models/ChemisVisitModel.dart';

// Enum needs to be accessible, or imported from Doctor screen file if shared.
// Ideally define in a shared file, but defining here for completeness if separate.
enum VisitDateFilter { today, last7Days, last15Days, custom }

class VisitListController with ChangeNotifier {
  AuthManager authManager = AuthManager();

  List<ChemistVisitModel> _visitList = [];
  String? userId;
  bool _isLoading = false;

  List<ChemistVisitModel> get salesList => _visitList;
  bool get isLoading => _isLoading;

  final String fetchApiUrl = THttpHelper.baseUrl;

  // Updated fetch to handle filters
  Future<void> fetchVisitList({
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

      String apiUrl = "$fetchApiUrl/chemist-visits/user/$userId";
      String queryParams = "";

      // Determine Query Parameters
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
        debugPrint("Chemist Visit Controller: Fetching data from: $fullUrl");
      }

      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        final List<dynamic> listJson = json.decode(response.body) as List<dynamic>;
        _visitList = listJson
            .whereType<Map<String, dynamic>>()
            .map((m) => ChemistVisitModel.fromJson(m))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Chemist Visit Controller: Error: $e");
      }
      _visitList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}