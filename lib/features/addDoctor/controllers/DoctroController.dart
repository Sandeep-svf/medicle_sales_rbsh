import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import 'dart:convert';
import '../../../utils/http/http_client.dart';
import '../../authentication/controllers/AuthController.dart';
import '../models/DoctorModelList.dart';

class DoctorListController extends GetxController {
  var isLoading = false.obs;
  var doctorList = <Doctor>[].obs; // Updated model reference

  static const String _baseUrl = THttpHelper.baseUrl;
  AuthManager authManager = AuthManager();
  late String headOffice="";

  Future<void> fetchDoctorList() async {
    print("Doctors Data: Fetching doctor list...");
    try {
      isLoading.value = true;

      headOffice = (await authManager.getHeadOffice())!;
     // final headOffice = (await authManager.getHeadOffice()) ?? '';

      print("Doctors Data: headOffice $headOffice");
      print("Doctors Data: $_baseUrl/doctors/by-head-office/$headOffice");
      final response = await http.get(

        Uri.parse("$_baseUrl/doctors/by-head-office/$headOffice"),
        headers: {"Content-Type": "application/json"},
      );

      print("Response: ${response.body}");

      if (Get.isDialogOpen!) Get.back(); // Close the loading dialog

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        // Debugging log to check the API response
        print("Doctors Data: $jsonData");

        // Update doctor list if data is fetched
        doctorList.assignAll(jsonData.map((json) => Doctor.fromJson(json)).toList());
      } else {
        Get.snackbar("Error", "Failed to load doctors: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Doctors Data: falling in catch block $e");
      if (Get.isDialogOpen!) Get.back(); // Ensure dialog is closed
      Get.snackbar("Error", "Something went wrong: $e",
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
