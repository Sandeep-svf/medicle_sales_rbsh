import 'dart:convert';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';

class AddExpenseController with ChangeNotifier {
  final String apiUrl = "${THttpHelper.baseUrl}/expenses";
  AuthManager authManager = AuthManager();

  Future<void> addExpense({
    required String? category,
    required double amount,
    required String description,
    String? bill,
    required BuildContext context,
  }) async {
    // 1. Use debugPrint (prints even when system limits standard print)
    debugPrint("[AddExpenseController] Function Called");

    try {
      // 2. Debug Auth Token/User ID explicitly
      debugPrint("[AddExpenseController] Fetching User ID...");
      String? userId = await authManager.getUserId();

      if (userId == null) {
        debugPrint("[AddExpenseController] User ID is NULL. Cannot proceed.");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not logged in')),
          );
        }
        return;
      }
      debugPrint("[AddExpenseController] User ID: $userId");

      final Map<String, dynamic> expenseData = {
        "userId": userId,
        "category": category,
        "amount": amount,
        "description": description,
        "bill": bill ?? "",
      };

      debugPrint("[AddExpenseController] POST URL: $apiUrl");
      debugPrint("[AddExpenseController] Body: $expenseData");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(expenseData),
      );

      debugPrint("Example Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint("[AddExpenseController] Success!");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully!')),
          );
          Navigator.pop(context); // Go back if successful
        }
      } else {
        debugPrint("[AddExpenseController] Failed: ${response.statusCode}");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.body}')),
          );
        }
      }
    } catch (e) {
      debugPrint("[AddExpenseController] Exception: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}