import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../utils/local_storage/auth_manager.dart';
import '../models/expanseModel.dart'; // Ensure this path is correct

class ExpenseController with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  AuthManager authManager = AuthManager();
  late String userId;




  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    userId = (await authManager.getUserId())!;
    debugPrint("ExpenseController: Fetching expenses for user ID: $userId");

    try {
      // Log the API request URL
      final String apiUrl = "https://medi-glucks-erp.onrender.com/api/expenses?userId=$userId";
      debugPrint("ExpenseController: Making GET request to $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      // Log the response status code
      debugPrint("ExpenseController: Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        _isLoading = false;
        // Log the raw response data
        debugPrint("ExpenseController: Response Body: ${response.body}");

        List<dynamic> data = jsonDecode(response.body);
        _expenses = data.map((item) => Expense.fromJson(item)).toList();

        // Log the number of expenses fetched
        debugPrint("ExpenseController: Fetched ${_expenses.length} expenses");
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      debugPrint("ExpenseController: Error fetching expenses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint("ExpenseController: Loading complete, notifyListeners called.");
    }
  }
}
