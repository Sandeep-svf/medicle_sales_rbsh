import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';

class AddExpenseController with ChangeNotifier {
  // API URL for adding expense
  final String apiUrl = "${THttpHelper.baseUrl}/expenses";
  AuthManager authManager = AuthManager();

  // Method to add expense
  Future<void> addExpense({
    required String? category,
    required double amount,
    required String description,
    String? bill,
    required BuildContext context,
  }) async {
    debugPrint("AddExpenseController: Starting addExpense");

    String? userId = await authManager.getUserId();
    debugPrint("AddExpenseController: Retrieved userId = $userId");

    final Map<String, dynamic> expenseData = {
      "userId": userId,
      "category": category,
      "amount": amount,
      "description": description,
      "bill": bill ?? "",
    };

    debugPrint("AddExpenseController: Sending POST to $apiUrl with body = $expenseData");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(expenseData),
      );

      debugPrint("AddExpenseController: Response status = ${response.statusCode}");
      debugPrint("AddExpenseController: Response body = ${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully!')),
        );
        debugPrint("AddExpenseController: Expense added successfully.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add expense.')),
        );
        debugPrint("AddExpenseController: Failed to add expense.");
      }
    } catch (e) {
      debugPrint("AddExpenseController: Exception occurred - $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
