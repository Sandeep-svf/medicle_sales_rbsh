import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../model/Stokist.dart';

class StokistListController extends GetxController {
  var isLoading = false.obs;

  // 1. Original List
  var stokistList = <Stockist>[].obs;

  // 2. Filtered List (For Search)
  var filteredStokistList = <Stockist>[].obs;

  static const String _baseUrl = THttpHelper.baseUrl;
  final AuthManager authManager = AuthManager();

  @override
  void onInit() {
    super.onInit();
    fetchStokist();
  }


  Future<List<dynamic>> fetchAreas() async {
    try {
      final token = await authManager.getAuthToken();

      final response = await http.get(
        Uri.parse("$_baseUrl/areas"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse["data"] ?? [];
      }

      return [];
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<void> assignAreaToStockist({
    required String stockistId,
    required String areaId,
  }) async {
    try {
      final token =
      await authManager.getAuthToken();

      final response = await http.put(
        Uri.parse(
          "$_baseUrl/stockists/$stockistId",
        ),
        headers: {
          "Content-Type":
          "application/json",
          "Authorization":
          "Bearer $token",
        },
        body: jsonEncode({
          "areaId": areaId,
        }),
      );

      if (response.statusCode == 200) {
        await fetchStokist();

        Get.snackbar(
          "Success",
          "Area Assigned",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }


  Future<String?> createNewArea({
    required String name,
    required String pincode,
    required String postOffice,
    required String headOfficeId,
  }) async {
    try {
      isLoading.value = true;

      final token = await authManager.getAuthToken();

      final response = await http.post(
        Uri.parse("$_baseUrl/areas"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "pincode": pincode,
          "post_office": postOffice,
          "head_office_id": headOfficeId,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        final jsonResponse =
        jsonDecode(response.body);

        final String areaId =
        jsonResponse["data"]["id"];

        Get.snackbar(
          "Success",
          "Area Created",
        );

        return areaId;
      }

      return null;
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStokist() async {
    debugPrint("httpStockist: Fetching stockist list...");
    isLoading.value = true;

    try {
      final token = await authManager.getAuthToken();
      final url = Uri.parse("$_baseUrl/stockists/my-stockists");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> dataJson = jsonData['data'];

          final List<Stockist> parsedList = dataJson.map((item) {
            try {
              return Stockist.fromJson(item);
            } catch (e) {
              return null;
            }
          }).whereType<Stockist>().toList();

          // Assign to BOTH lists
          stokistList.assignAll(parsedList);
          filteredStokistList.assignAll(parsedList);

          debugPrint("httpStockist: Successfully assigned ${stokistList.length} stockists.");
        }
      } else {
        debugPrint("httpStockist: Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("httpStockist: Exception occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 3. Search Logic
  void filterStockists(String query) {
    if (query.isEmpty) {
      filteredStokistList.assignAll(stokistList);
    } else {
      filteredStokistList.assignAll(stokistList.where((s) =>
          (s.firmName ?? "").toLowerCase().contains(query.toLowerCase())
      ).toList());
    }
  }
}

// old code
/*class StokistListController extends GetxController {
  var isLoading = false.obs;
  var stokistList = <Stockist>[].obs;

  static const String _baseUrl = THttpHelper.baseUrl;
  final AuthManager authManager = AuthManager();
 // late String headOffice;

  @override
  void onInit() {
    super.onInit();
    fetchStokist();
  }

  Future<void> fetchStokist() async {
    debugPrint("httpStockist: Fetching stockist list...");
    isLoading.value = true;

    try {
      //headOffice = (await authManager.getHeadOffice())!;
    //  debugPrint("httpStockist: Retrieved Head Office: $headOffice");

      final token = await authManager.getAuthToken();
     // final url = Uri.parse("$_baseUrl/stockists/by-head-office/$headOffice");
      final url = Uri.parse("$_baseUrl/stockists/my-stockists");
      debugPrint("httpStockist: Request URL: $url");

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json",'Authorization': 'Bearer $token'},
      );

      debugPrint("httpStockist: HTTP Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        debugPrint("httpStockist: Parsed JSON: $jsonData");

        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> dataJson = jsonData['data'];

          final List<Stockist> parsedList = dataJson.map((item) {
            try {
              final stockist = Stockist.fromJson(item);
              debugPrint("httpStockist: Parsed Stockist firmName: ${stockist.firmName}");
              return stockist;
            } catch (e) {
              debugPrint("httpStockist: Skipping item due to parse error: $e");
              return null;
            }
          }).whereType<Stockist>().toList();

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
}*/
