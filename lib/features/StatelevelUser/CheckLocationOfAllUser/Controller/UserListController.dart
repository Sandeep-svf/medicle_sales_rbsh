import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';

import '../../../../utils/local_storage/auth_manager.dart';
import '../../../authentication/models/UserModel.dart';
import '../Model/UserListResponseModel.dart';


class UserListController extends GetxController {
  var isLoading = false.obs;
  var userList = <Usert>[].obs;

  static const String _baseUrl = THttpHelper.baseUrl; // Replace with your base URL
  AuthManager authManager = AuthManager();

  @override
  void onInit() {
    super.onInit();
  }

  // Function to fetch the Usert list based on the state
  Future<void> fetchUserListByState(String state) async {
    print("[UserListController] Fetching Usert list for state: $state");

    try {
      isLoading.value = true;
      final token = await authManager.getAuthToken();

      // API request to fetch Usert list
      final response = await http.get(
        Uri.parse("$_baseUrl/users/by-state?state=$state"),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      print("[UserListController] Response: ${response.body}");

      // Handle API response
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Ensure success flag is true
        if (jsonData['success'] == true) {
          var data = jsonData['data'] ?? {};
          var usersData = data['users'] ?? [];

          // Debugging output
          print("[UserListController] usersData: $usersData");

          // Ensure that usersData is a List before mapping
          if (usersData is List) {
            // Safe mapping to Usert objects
            userList.assignAll(
              usersData.map<Usert>((json) => Usert.fromJson(json)).toList(),
            );
            Get.snackbar(
              "Success",
              jsonData['message'],  // Display success message
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            print("[UserListController] Successfully fetched Usert list.");
          } else {
            // Handle case where 'users' is not a List
            Get.snackbar(
              "Error",
              "Invalid data format for 'users'. Expected a List.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
            print("[UserListController] Error: 'users' is not a list.");
          }
        } else {
          // If success is false, show message from the response
          Get.snackbar(
            "Error",
            jsonData['message'],
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          print("[UserListController] Error: ${jsonData['message']}");
        }
      } else {
        // Handle non-200 status codes
        Get.snackbar(
          "Error",
          "Failed to load Usert list. Status code: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        print("[UserListController] Failed to load Usert list. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("[UserListController] Exception caught: $e");
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
      isLoading.value = false;
      print("[UserListController] Fetching Usert list completed.");
    }
  }


}






