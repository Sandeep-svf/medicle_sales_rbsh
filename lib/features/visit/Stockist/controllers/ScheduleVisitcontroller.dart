import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';


class StockistVisitController {
  static const String url = '${THttpHelper.baseUrl}/stockist-visits';

  // Function to create a doctor visit (static method)
  static Future<void> createDoctorVisit({
    required String? doctorId,
    required String date,
    required String notes,
    required BuildContext context,
    required AuthManager authManager, // Passing AuthManager as a parameter
  }) async {
    print("StockistVisitController: createDoctorVisit called");
    print("StockistVisitController: date: $date");

    String? userId = await authManager.getUserId();
    print("StockistVisitController: Retrieved userId: $userId");

    if (userId == null) {
      print("StockistVisitController: User is not authenticated");
      if (context.mounted) {  // Check if context is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not authenticated.')),
        );
      }
      return;
    }

    if (doctorId == null) {
      print("StockistVisitController: Failed to load doctor, doctorId is null");
      if (context.mounted) {  // Check if context is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load doctor.')),
        );
      }
      return;
    }


    // Parse the input string into a DateTime object
    DateTime parsedDate = DateFormat('d-M-yyyy').parse(date);
    // Format the DateTime object into the desired format
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(parsedDate);

    // Print the formatted date
    print(formattedDate);  // Output: 2025-04-26T00:00:00.000Z


    final Map<String, dynamic> requestBody = {
      'stockist_id': doctorId,
      'user_id': userId,
      'date': formattedDate,
      'notes': notes,
    };
    print("StockistVisitController: Request body: $requestBody");

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    print("StockistVisitController: Request headers: $headers");

    try {
      print("StockistVisitController: Sending POST request to $url");
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      print("StockistVisitController: Response status code: ${response.statusCode}");
      print("StockistVisitController: Response body: ${response.body}");

      if (response.statusCode == 201) {
        print("StockistVisitController: Doctor visit successfully created");
        if (context.mounted) {  // Check if context is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doctor schedule successfully created!')),
          );
        }
      } else {
        print("StockistVisitController: Failed to create doctor visit, response not 201");
        if (context.mounted) {  // Check if context is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something went wrong!')),
          );
        }
      }
    } catch (error) {
      print("StockistVisitController: Network error: $error");
      if (context.mounted) {  // Check if context is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $error')),
        );
      }
    }
  }
}
