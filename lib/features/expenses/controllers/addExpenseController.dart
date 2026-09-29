import 'dart:convert';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/http/api_http.dart' as http;

import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import '../../../utils/http/api_ui_feedback.dart';
import '../../../utils/loder/api_wait_dialog.dart';

class AddExpenseController with ChangeNotifier {
  String get apiUrl => "${THttpHelper.baseUrl}/expenses";
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
            const SnackBar(content: Text(TTexts.uiTextErrorUserNotLoggedIn)),
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

      final response = await ApiWaitDialog.run(
        context,
        title: TTexts.savingExpense,
        action: () => http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: json.encode(expenseData),
        ),
      );

      debugPrint("Example Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint("[AddExpenseController] Success!");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(TTexts.uiTextExpenseAddedSuccessfully)),
          );
          Navigator.pop(context); // Go back if successful
        }
      } else {
        debugPrint("[AddExpenseController] Failed: ${response.statusCode}");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(TTexts.requestFailed)),
          );
        }
      }
    } catch (e) {
      debugPrint("[AddExpenseController] Exception: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiUiFeedback.message(e))),
        );
      }
    }
  }
}
