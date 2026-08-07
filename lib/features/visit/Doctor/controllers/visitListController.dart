import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../models/visitSalesData.dart';
import '../repository/pending_visit_repository.dart';

enum VisitDateFilter {
  today,
  last7Days,
  last15Days,
  custom,
}

class VisitListController with ChangeNotifier {
  final AuthManager authManager = AuthManager();
  final PendingVisitRepository _pendingRepository =
  PendingVisitRepository();

  final RxSet<String> pendingVisits = <String>{}.obs;

  List<VisitSalesLogModel> _visitList = [];
  String? userId;
  bool _isLoading = false;

  List<VisitSalesLogModel> get salesList => _visitList;
  bool get isLoading => _isLoading;

  final String fetchApiUrl = THttpHelper.baseUrl;

  Future<void> loadPendingVisits() async {
    final visits = await _pendingRepository.getPendingVisits();

    pendingVisits.clear();

    pendingVisits.addAll(
      visits.map((e) => e.visitId),
    );
  }

  Future<void> fetchSalesList({
    VisitDateFilter filter = VisitDateFilter.today,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint(
          "VisitListController: ======================================");
      debugPrint(
          "VisitListController: fetchSalesList() started");
      debugPrint(
          "VisitListController: Selected Filter = $filter");

      userId = await authManager.getUserId();

      debugPrint(
          "VisitListController: User ID = $userId");

      if (userId == null || userId!.isEmpty) {
        debugPrint(
            "VisitListController: User ID is null or empty");

        _visitList = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      String apiUrl =
          "$fetchApiUrl/doctor-visits/user/$userId";

      String queryParams = "";

      switch (filter) {
        case VisitDateFilter.today:
          queryParams = "?range=today";
          debugPrint(
              "VisitListController: Applying TODAY filter");
          break;

        case VisitDateFilter.last7Days:
          queryParams = "?range=last7days";
          debugPrint(
              "VisitListController: Applying LAST 7 DAYS filter");
          break;

        case VisitDateFilter.last15Days:
          queryParams = "?range=last15days";
          debugPrint(
              "VisitListController: Applying LAST 15 DAYS filter");
          break;

        case VisitDateFilter.custom:
          if (startDate != null &&
              endDate != null) {
            final formatter =
            DateFormat('yyyy-MM-dd');

            final start =
            formatter.format(startDate);

            final end =
            formatter.format(endDate);

            queryParams =
            "?startDate=$start&endDate=$end";

            debugPrint(
                "VisitListController: Applying CUSTOM filter");
            debugPrint(
                "VisitListController: Start Date = $start");
            debugPrint(
                "VisitListController: End Date = $end");
          } else {
            debugPrint(
                "VisitListController: Custom dates missing. Falling back to TODAY");

            queryParams = "?range=today";
          }
          break;
      }

      final fullUrl =
          "$apiUrl$queryParams";

      debugPrint(
          "VisitListController: API URL = $fullUrl");

      final response =
      await http.get(Uri.parse(fullUrl));

      debugPrint(
          "VisitListController: Status Code = ${response.statusCode}");

      debugPrint(
          "VisitListController: Raw Response = ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data =
        jsonDecode(response.body);

        debugPrint(
            "VisitListController: Records Received = ${data.length}");

        _visitList = data
            .map(
              (item) =>
              VisitSalesLogModel.fromJson(item),
        )
            .toList();

        await loadPendingVisits();

        debugPrint(
            "VisitListController: Records Parsed = ${_visitList.length}");

        if (_visitList.isNotEmpty) {
          debugPrint(
              "VisitListController: First Record Loaded Successfully");
        }
      } else {
        debugPrint(
            "VisitListController: API Failed");

        throw Exception(
          "Failed to fetch sales logs. Status Code: ${response.statusCode}",
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
          "VisitListController: Exception = $e");

      debugPrint(
          "VisitListController: StackTrace = $stackTrace");

      _visitList = [];
    } finally {
      _isLoading = false;

      debugPrint(
          "VisitListController: Loading Finished");

      debugPrint(
          "VisitListController: Final Count = ${_visitList.length}");

      debugPrint(
          "VisitListController: ======================================");

      notifyListeners();
    }
  }


}