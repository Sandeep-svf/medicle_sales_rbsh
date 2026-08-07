import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../model/performance_dashboard_model.dart';

class PerformanceService {
  PerformanceService._();

  static final PerformanceService instance = PerformanceService._();

  Future<PerformanceDashboardModel> getDashboard({
    required String filter,
    DateTime? startDate,
    DateTime? endDate,
    String visitType = "all",
  }) async {
    final token = await AuthManager().getAuthToken();

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found.");
    }

    final uri = _buildUri(
      filter: filter,
      startDate: startDate,
      endDate: endDate,
      visitType: visitType,
    );

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return PerformanceDashboardModel.fromJson(json);
    }

    throw Exception(
      json["message"] ?? "Unable to load dashboard.",
    );
  }

  Uri _buildUri({
    required String filter,
    DateTime? startDate,
    DateTime? endDate,
    String visitType = "all",
  }) {
    final query = <String, String>{
      "filter": filter,
    };

    if (filter == "custom") {
      query["startDate"] = _formatDate(startDate!);
      query["endDate"] = _formatDate(endDate!);
      query["visit_type"] = visitType;
    }

    return Uri.parse(
      "${THttpHelper.baseUrl}/dcr/dcr-statehead-mobile",
    ).replace(
      queryParameters: query,
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }
}