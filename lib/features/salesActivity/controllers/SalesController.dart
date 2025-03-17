import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/SalesModel.dart';

class SalesController with ChangeNotifier {
  List<SalesLogModel> _salesLogs = [];
  bool _isLoading = false;

  List<SalesLogModel> get salesLogs => _salesLogs;
  bool get isLoading => _isLoading;

  final String apiUrl = "https://your-api.com/get-sales-log"; // Replace with your API URL

  Future<void> fetchSalesLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _salesLogs = data.map((item) => SalesLogModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to fetch sales logs");
      }
    } catch (e) {
      print("Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void addSalesLog(SalesLogModel newLog) {
    _salesLogs.add(newLog);
    notifyListeners();
  }

  void deleteSalesLog(int index) {
    _salesLogs.removeAt(index);
    notifyListeners();
  }
}
