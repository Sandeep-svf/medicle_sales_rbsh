import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/http/api_http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../../SalesChartAnalysis/model/SalesChartDashboardModel.dart';

class AllowanceVisitException implements Exception {
  const AllowanceVisitException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AllowanceVisitService {
  /// Reuses the dashboard Visits model for the selected day's total, pending
  /// scheduled and confirmed records. Monthly totals cannot establish a day.
  Future<Visits> fetchForDay(String userId, DateTime date) async {
    final token = await AuthManager().getAuthToken();
    if (token == null || token.isEmpty) {
      throw const AllowanceVisitException(
          'Please sign in again to load visits.');
    }
    final day = DateFormat('yyyy-MM-dd').format(date);
    final results = await Future.wait([
      _details('doctor', userId, day, token),
      _details('chemist', userId, day, token),
    ]);
    return Visits(
      doctor: results[0],
      chemist: results[1],
      total: results[0].total + results[1].total,
      scheduled: results[0].scheduled + results[1].scheduled,
      confirmed: results[0].confirmed + results[1].confirmed,
    );
  }

  Future<VisitDetails> _details(
      String type, String userId, String day, String token) async {
    final uri = Uri.parse('${THttpHelper.baseUrl}/$type-visits/user/$userId')
        .replace(queryParameters: {'startDate': day, 'endDate': day});
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode != 200) {
      throw AllowanceVisitException(
          'Unable to load $type visits (HTTP ${response.statusCode}). Please retry.');
    }
    final data = jsonDecode(response.body);
    if (data is! List) {
      throw AllowanceVisitException(
          'Unable to verify $type visits. Please retry.');
    }
    final ids = <String>{};
    var total = 0;
    var confirmed = 0;
    for (final item in data) {
      if (item is! Map) {
        continue;
      }
      final visitDate = item['date']?.toString();
      if (visitDate == null ||
          visitDate.length < 10 ||
          visitDate.substring(0, 10) != day) {
        continue;
      }
      final owner = item['user_id']?.toString();
      if (owner != null && owner != userId) {
        continue;
      }
      final id = item['id']?.toString();
      if (id != null && !ids.add(id)) {
        continue;
      }
      total++;
      if (item['confirmed'] == true) confirmed++;
    }
    return VisitDetails(
        total: total, confirmed: confirmed, scheduled: total - confirmed);
  }
}
