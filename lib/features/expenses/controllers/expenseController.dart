import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../utils/local_storage/auth_manager.dart';
import '../models/expanseModel.dart'; // Ensure this path is correct

class ExpenseController with ChangeNotifier {
  AuthManager authManager = AuthManager();

  // This method returns a Future, which will be handled by FutureBuilder
  Future<List<Expense>> fetchExpenses() async {
    String? userId = await authManager.getUserId(); // Get user ID

    try {
      final response = await http.get(
        Uri.parse("https://medi-glucks-erp.onrender.com/api/expenses?userId=$userId"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Expense.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      throw Exception('Error fetching expenses: $e');
    }
  }
}


