import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/TravelAllowenceRequestModel.dart';
import '../models/DailyAllowenceRequestModel.dart';

class AllowanceController {
  static const String _baseUrl = 'https://medi-glucks-erp.onrender.com/api/expenses';
  static const String _logPrefix = 'AllowanceController';

  static Future<bool> submitTravelAllowance(TravelAllowanceRequest request) async {
    try {
      debugPrint('$_logPrefix: Sending Travel Allowance request: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      debugPrint('$_logPrefix: Response Status: ${response.statusCode}');
      debugPrint('$_logPrefix: Response Body: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('$_logPrefix: Exception occurred - $e');
      return false;
    }
  }

  static Future<bool> submitDailyAllowance(DailyAllowanceRequest request) async {
    try {
      debugPrint('$_logPrefix: Sending Daily Allowance request: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      debugPrint('$_logPrefix: Response Status: ${response.statusCode}');
      debugPrint('$_logPrefix: Response Body: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('$_logPrefix: Exception occurred - $e');
      return false;
    }
  }


  static Future<bool> updateExpense({
    required String expenseId,
    required Map<String, dynamic> data,
  }) async {
    try {
      debugPrint('$_logPrefix: Sending Daily Allowance request: ${data}');

      final response = await http.put(
        Uri.parse("$_baseUrl/$expenseId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      debugPrint('$_logPrefix: Response Status: ${response.statusCode}');
      debugPrint('$_logPrefix: Response Body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
