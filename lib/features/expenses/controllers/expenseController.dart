import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/features/expenses/models/ExpenseDefaultValueModel.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/expanseModel.dart'; // ✅ Ensure correct model path

import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../models/NewExpenseModel.dart';

class ExpenseController with ChangeNotifier {
  final AuthManager authManager = AuthManager();

  Future<List<ExpenseModel>> fetchExpenses() async {
    String? userId = await authManager.getUserId();

    try {
      final response = await http.get(
        Uri.parse("${THttpHelper.baseUrl}/expenses?userId=$userId"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ExpenseModel.fromJson(item)).toList(); //  fixed here
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      throw Exception('Error fetching expenses: $e');
    }
  }

}
