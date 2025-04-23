import 'dart:convert';
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


  @override
  void onInit() {
    // fetchClinics();
    super.onInit();
  }

  Future<void> fetchClinicList() async {
    print("Doctors Data: Fetching doctor list...");
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse("$_baseUrl/chemists"),
        headers: {"Content-Type": "application/json"},
      );

      print("Response: ${response.body}");

      if (Get.isDialogOpen!) Get.back(); // Close the loading dialog

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        // Debugging log to check the API response
        print("Doctors Data: $jsonData");

        // Update doctor list if data is fetched
        clinicList
            .assignAll(jsonData.map((json) => Clinic.fromJson(json)).toList());

        isLoading.value = false;
        print("Doctors Data: list length:  ${clinicList.length}");
      } else {
        Get.snackbar(
          "Error",
          "Failed to load Chemist: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Doctors Data: falling in catch block $e");
      if (Get.isDialogOpen!) Get.back(); // Ensure dialog is closed
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      print("Doctors Data: Falling in finally block");
      isLoading.value = false;
    }
  }

}
