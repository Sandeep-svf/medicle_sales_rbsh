import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../model/Stokist.dart';


class StokistListController extends GetxController {
  var isLoading = false.obs;
  var stokistList = <Data>[].obs;

  static const String _baseUrl = THttpHelper.baseUrl;
  final AuthManager authManager = AuthManager();
  late String headOffice;

  @override
  void onInit() {
    super.onInit();
    fetchStokist();
  }

  Future<void> fetchStokist() async {
    debugPrint("httpStockist: Fetching stockist list...");
    isLoading.value = true;

    try {
      headOffice = (await authManager.getHeadOffice())!;
      debugPrint("httpStockist: Retrieved Head Office: $headOffice");

      final url = Uri.parse("$_baseUrl/stockists/by-head-office/$headOffice");
      debugPrint("httpStockist: Request URL: $url");

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("httpStockist: HTTP Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        debugPrint("httpStockist: Parsed JSON: $jsonData");

        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> dataJson = jsonData['data'];

          final List<Data> parsedList = dataJson.map((item) {
            try {
              final stockist = Data.fromJson(item);
              debugPrint("httpStockist: Parsed Stockist firmName: ${stockist.firmName}");
              return stockist;
            } catch (e) {
              debugPrint("httpStockist: Skipping item due to parse error: $e");
              return null;
            }
          }).whereType<Data>().toList();

          stokistList.assignAll(parsedList);
          debugPrint("httpStockist: Successfully assigned ${stokistList.length} stockists.");
        } else {
          debugPrint("httpStockist: Invalid or empty 'data' list.");
        }
      } else {
        debugPrint("httpStockist: Server responded with status code ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("httpStockist: Exception occurred: $e");
    } finally {
      isLoading.value = false;
      debugPrint("httpStockist: Fetching completed.");
    }
  }
}
