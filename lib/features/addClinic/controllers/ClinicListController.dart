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
  var clinicList = <Clinic>[].obs;

  static const String _baseUrl = THttpHelper.baseUrl;
  AuthManager authManager = AuthManager();
  late String headOffice = "";

  @override
  void onInit() {
    super.onInit();
  }


  Future<void> fetchClinicList() async {
    print("httpChemist: Fetching chemist list...");

    try {
      isLoading.value = true;
      //headOffice = (await authManager.getHeadOffice())!;
      final token  = await authManager.getAuthToken();

      print("httpChemist: Head Office: $headOffice");

      final response = await http.get(
        Uri.parse("$_baseUrl/chemists/my-chemists"),
        headers: {"Content-Type": "application/json",'Authorization': 'Bearer $token'},
      );

      print("httpChemist: Response: ${response.body}");

      // Close loading dialog if open
      if (Get.isDialogOpen!) Get.back();

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Check if 'success' flag is true
        if (jsonData['success'] == true) {
          // Check if 'Data' key exists and is not null
          var data = jsonData['data'] ?? [];

          if (data is List) {
            print("httpChemist: Response: data.length: ${data.length}");

            // Only assign the data if it's a valid list
            clinicList.assignAll(
              data.map<Clinic>((json) => Clinic.fromJson(json)).toList(),
            );
            Get.snackbar(
              "Success",
              'Clinic list fetched successfully.', // Display the success message from the response
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            print("httpChemist: Successfully fetched clinic list.");
          } else {
            // Handle case where 'Data' is not a list
            Get.snackbar(
              "Warning",
              "Invalid data format received.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
            print("httpChemist: Error: 'Data' is not a valid list.");
          }
        } else {
          // If success is false, show message from the response
          Get.snackbar(
            "Warning",
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
          "Note",
          "No Chemist added yet.: ${response.statusCode}",
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
     /* Get.snackbar(
        "Warning",
        "Something went wrong: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );*/
    } finally {
      print("httpChemist: Fetching completed.");
      isLoading.value = false;
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
