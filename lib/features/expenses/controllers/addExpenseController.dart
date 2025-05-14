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
    String? userId = await authManager.getUserId();
    // Data to be sent in the request body
    final Map<String, dynamic> expenseData = {
      "userId": userId,
      "category": category,
      "amount": amount,
      "description": description,
      "bill": bill ?? "", // If bill is not provided, use an empty string
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(expenseData),
      );

      if (response.statusCode == 201) {
        // If the response is successful, show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully!')),
        );
      } else {
        // If there's an error, show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add expense.')),
        );
      }
    } catch (e) {
      // Catch any error and show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
