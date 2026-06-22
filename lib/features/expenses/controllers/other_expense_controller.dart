import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:medicle_sales_rbsh/utils/constants/api_constants.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';

import '../../../utils/local_storage/auth_manager.dart';
import '../models/other_expense_request.dart';



class OtherExpenseController {

  static const String baseUrl =
      THttpHelper.baseUrl;

  final AuthManager authManager = AuthManager();

  /// Upload Bill
  static Future<String?> uploadBill(
      String filePath,
      ) async {
    try {

      final token =
      await AuthManager()
          .getAuthToken();

      var request =
      http.MultipartRequest(
        'POST',
        Uri.parse(
          '$baseUrl/expenses/upload-bill',
        ),
      );

      request.headers.addAll({
        "Authorization":
        "Bearer $token",
      });

      request.files.add(
        await http.MultipartFile
            .fromPath(
          'bill',
          filePath,
          contentType: MediaType(
            'image',
            'jpeg',
          ),

        ),
      );

      final streamedResponse =
      await request.send();

      final response =
      await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint(
        "OtherExpenseController: Upload Status Code = ${response.statusCode}",
      );

      debugPrint(
        "OtherExpenseController: Upload Response = ${response.body}",
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final jsonData =
        jsonDecode(response.body);

        return jsonData['imageUrl'];
      }

      return null;
    } catch (e) {
      debugPrint(
        "OtherExpenseController: Upload Exception = $e",
      );
      return null;
    }
  }

  /// Create Other Expense
  static Future<bool> createOtherExpense(
      OtherExpenseRequest request,
      ) async {
    try {

      final token =
      await AuthManager()
          .getAuthToken();

      debugPrint(
        "OtherExpenseController: Token = $token",
      );

      final response =
      await http.post(
        Uri.parse("$baseUrl/expenses"),
        headers: {
          "Content-Type":
          "application/json",
          "Authorization":
          "Bearer $token",
        },
        body: jsonEncode(
          request.toJson(),
        ),
      );

      debugPrint(
        "OtherExpenseController: Status Code = ${response.statusCode}",
      );

      debugPrint(
        "OtherExpenseController: Response = ${response.body}",
      );

      return response.statusCode ==
          201 ||
          response.statusCode ==
              200;
    } catch (e) {
      debugPrint(
        "OtherExpenseController: Create Expense Exception = $e",
      );

      return false;
    }
  }
}