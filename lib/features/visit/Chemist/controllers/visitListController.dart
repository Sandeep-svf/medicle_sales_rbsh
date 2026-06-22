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



  Future<List<dynamic>> fetchAreas() async {
    try {
      final token = await authManager.getAuthToken();

      final response = await http.get(
        Uri.parse('${THttpHelper.baseUrl}/areas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("AREAS STATUS => ${response.statusCode}");
      debugPrint("AREAS RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json is Map && json['data'] is List) {
          return json['data'];
        }
      }

      return [];
    } catch (e) {
      debugPrint('fetchAreas Error: $e');
      return [];
    }
  }

  Future<String?> createArea({
    required String areaName,
    required String pincode,
    required String postOffice,
    required String headOfficeId,
  }) async {
    try {
      final token = await authManager.getAuthToken();

      final response = await http.post(
        Uri.parse('${THttpHelper.baseUrl}/areas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': areaName,
          'pincode': pincode,
          'post_office': postOffice,
          'head_office_id': headOfficeId,
        }),
      );

      debugPrint(
        "CREATE AREA STATUS => ${response.statusCode}",
      );

      debugPrint(
        "CREATE AREA RESPONSE => ${response.body}",
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        final data = jsonDecode(response.body);

        if (data['data'] != null &&
            data['data']['id'] != null) {
          return data['data']['id'];
        }

        if (data['id'] != null) {
          return data['id'];
        }
      }

      return null;
    } catch (e) {
      debugPrint(
        'createArea Error: $e',
      );

      return null;
    }
  }

  Future<bool> assignAreaToChemist({
    required String chemistId,
    required String areaId,
  }) async {
    try {
      final token =
      await authManager.getAuthToken();

      debugPrint(
        "ASSIGN AREA STATUS => ${chemistId}",
      );

      debugPrint(
        "ASSIGN AREA STATUS => ${areaId}",
      );

      debugPrint(
        "ASSIGN URL => ${THttpHelper.baseUrl}/chemist/$chemistId",
      );


      final response = await http.put(
        Uri.parse(
          '${THttpHelper.baseUrl}/chemists/$chemistId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'areaId': areaId,
        }),
      );


      debugPrint(
        "ASSIGN BODY => ${jsonEncode({
          'areaId': areaId,
        })}",
      );

      debugPrint(
        "ASSIGN AREA STATUS => ${response.statusCode}",
      );

      debugPrint(
        "ASSIGN AREA RESPONSE => ${response.body}",
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint(
        'assignAreaToChemist Error => $e',
      );

      return false;
    }
  }

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