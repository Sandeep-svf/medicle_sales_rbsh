import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/storage_utility.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../models/SalesModel.dart';

class SalesController with ChangeNotifier {

  AuthManager authManager = AuthManager();

  List<SalesLogModel> _salesList = [];
  bool _isLoading = false;
  String? userId;

  List<SalesLogModel> get salesList => _salesList;
  bool get isLoading => _isLoading;

  final String fetchApiUrl = THttpHelper.baseUrl;
  final String addApiUrl = THttpHelper.baseUrl;


  /// Fetch sales list from the server
  Future<void> fetchSalesList() async {

    String? userId = await authManager.getUserId();

    if (kDebugMode) {
      print("Sales Controller: user id: $userId");
    }


    _isLoading = true;
    notifyListeners();


    try {
      final response = await http.get(Uri.parse("$fetchApiUrl/sales/user/$userId"));

      if (kDebugMode) {
        print("Sales Controller: user id: $fetchApiUrl/sales/user/$userId");
      }

     // final response = await http.get(Uri.parse("$fetchApiUrl/sales/user/${userId!}"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _salesList = data.map((item) => SalesLogModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to fetch sales logs");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add new sales data via API
  Future<void> addSalesData(
      String name, String salesRep, String time, String callNotes) async {
    try {
      final response = await http.post(
        Uri.parse(addApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "salesRepresentative": salesRep,
          "time": time,
          "callNotes": callNotes,
        }),
      );

      if (response.statusCode == 200) {
        // After successful addition, fetch the updated list
        await fetchSalesList();
      } else {
        throw Exception("Failed to add sales log");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }
}
