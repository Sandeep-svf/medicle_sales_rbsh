import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../model/clinic.dart';

class ClinicListController extends GetxController {
  var isLoading = false.obs;

  // 1. ORIGINAL LIST (Preserved for other screens)
  var clinicList = <Clinic>[].obs;

  // 2. FILTERED LIST (For Search Sheet)
  var filteredClinicList = <Clinic>[].obs;

  static const String _baseUrl = THttpHelper.baseUrl;
  AuthManager authManager = AuthManager();
  late String headOffice = "";

  @override
  void onInit() {
    super.onInit();
  }


  Future<List<dynamic>> fetchAreas() async {
    try {
      final token =
      await authManager.getAuthToken();

      final response = await http.get(
        Uri.parse("$_baseUrl/areas"),
        headers: {
          "Content-Type":
          "application/json",
          "Authorization":
          "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse =
        jsonDecode(response.body);

        return jsonResponse["data"] ?? [];
      }

      return [];
    } catch (e) {
      print(
        "ClinicListController fetchAreas Error: $e",
      );
      return [];
    }
  }


  Future<void> assignAreaToChemist({
    required String chemistId,
    required String areaId,
  }) async {
    try {
      final token =
      await authManager.getAuthToken();

      final response = await http.put(
        Uri.parse(
          "$_baseUrl/chemists/$chemistId",
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
        await fetchClinicList();

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

      final token =
      await authManager.getAuthToken();

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

      if (response.statusCode == 201 ||
          response.statusCode == 200) {

        final jsonResponse =
        jsonDecode(response.body);

        final String createdAreaId =
        jsonResponse["data"]["id"];

        Get.snackbar(
          "Success",
          "Area created successfully!",
        );

        return createdAreaId;
      }

      Get.snackbar(
        "Error",
        "Failed creating area",
      );

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


  Future<void> fetchClinicList() async {
    print("httpChemist: Fetching chemist list...");

    try {
      isLoading.value = true;
      final token  = await authManager.getAuthToken();

      print("httpChemist: Head Office: $headOffice");

      final response = await http.get(
        Uri.parse("$_baseUrl/chemists/my-chemists"),
        headers: {"Content-Type": "application/json",'Authorization': 'Bearer $token'},
      );

      print("httpChemist: Response: ${response.body}");

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          var data = jsonData['data'] ?? [];

          if (data is List) {
            // Assign to BOTH lists
            List<Clinic> loadedData = data.map<Clinic>((json) => Clinic.fromJson(json)).toList();

            clinicList.assignAll(loadedData);
            filteredClinicList.assignAll(loadedData); // Sync filtered list

            print("httpChemist: Successfully fetched clinic list.");
          } else {
            Get.snackbar("Warning", "Invalid data format received.");
          }
        } else {
          Get.snackbar("Warning", jsonData['message']);
        }
      } else {
        Get.snackbar("Note", "No Chemist added yet.: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("httpChemist: Exception caught: $e");
      }
      if (Get.isDialogOpen ?? false) Get.back();
    } finally {
      print("httpChemist: Fetching completed.");
      isLoading.value = false;
    }
  }

  // 3. FILTER LOGIC
  void filterClinics(String query) {
    if (query.isEmpty) {
      filteredClinicList.assignAll(clinicList);
    } else {
      filteredClinicList.assignAll(clinicList.where((clinic) {
        return (clinic.firmName ?? "").toLowerCase().contains(query.toLowerCase());
      }).toList());
    }
  }



/*Future<void> fetchClinicList() async {
    print("httpChemist: Fetching chemist list...");

    try {
      isLoading.value = true;
      headOffice = (await authManager.getHeadOffice())!;

      print("httpChemist: Head Office: $headOffice");

      final response = await http.get(
        Uri.parse("$_baseUrl/chemists/by-head-office/$headOffice"),
        headers: {"Content-Type": "application/json"},
      );

      print("httpChemist: Response: ${response.body}");

      // Close loading dialog if open
      if (Get.isDialogOpen!) Get.back();

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Check if 'success' flag is true
        if (jsonData['success'] == true) {
          // Only assign the data if success is true
          clinicList.assignAll(
            jsonData['Data'].map<Clinic>((json) => Clinic.fromJson(json)).toList(),
          );
          Get.snackbar(
            "Success",
            jsonData['message'], // Display the success message from the response
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          print("httpChemist: Successfully fetched clinic list.");
        } else {
          // If success is false, show message from the response
          Get.snackbar(
            "Error",
            jsonData['message'],
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          print("httpChemist: Error fetching data: ${jsonData['message']}");
        }
      } else {
        // Handle status codes other than 200 (e.g., 500, 404)
        Get.snackbar(
          "Error",
          "Failed to load chemists. Status code: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        print("httpChemist: Error: Failed to load chemists. Status code: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("httpChemist: Exception caught: $e");
      }
      // Ensure dialog is closed if any error occurs
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      print("httpChemist: Fetching completed.");
      isLoading.value = false;
    }
  }*/
}
