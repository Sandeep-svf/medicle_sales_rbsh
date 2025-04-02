import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/storage_utility.dart';

class AddSalesController {
  static const String _baseUrl = THttpHelper.baseUrl;
  static const apiUrl = '$_baseUrl/sales';
  String? userId;
  AuthManager authManager = AuthManager();

  // Fetching user id from shared preferences
  Future<void> addSales({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController salesRepController,
    required TextEditingController callNotesController,
  }) async {
    userId = await authManager.getUserId();
    final Map<String, dynamic> salesData = {
      "doctorName": nameController.text,
      "salesRep": salesRepController.text,
      "callNotes": callNotesController.text,
      "userId": userId
    };

    // Log the sales data to check what's being sent
    debugPrint("SalesController: Sales Data: ${json.encode(salesData)}");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(salesData),
      );

      // Log the response code and body
      debugPrint("SalesController: Response Code: ${response.statusCode}");
      debugPrint("SalesController: Response Body: ${response.body}");

      if (response.statusCode == 201) {
        // If the response is successful, show success snack bar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sales added successfully!')),
        );
        // Close the dialog
        Navigator.pop(context);
      } else {
        // If there's an error, show error snack bar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong.')),
        );
      }
    } catch (e) {
      // Log the error
      debugPrint("SalesController: Error occurred: $e");

      // Catch any error and show error snack bar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
