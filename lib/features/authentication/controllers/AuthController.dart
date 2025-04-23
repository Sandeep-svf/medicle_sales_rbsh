import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicle_sales_rbsh/features/dashboard/screen/dashboard.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../models/UserModel.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var user = Rxn<UserModel>(); // Store user model in state

  static const String _baseUrl = THttpHelper.baseUrl;

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and Password cannot be empty");
      return;
    }

    try {
      isLoading.value = true;

      // Close any existing dialogs before opening a new one
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show Loading Dialog
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false, // Prevent back button press
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black87, // Dark background
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Loading...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // White text
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none, // Ensure no underline
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    height: 20, // Adjust circle size
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5, // Slightly thinner stroke
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false, // Prevent user interaction
      );

      final response = await http.post(
        Uri.parse("$_baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      // Close loading overlay
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {
        // Ensure 'user' key exists before parsing
        if (data.containsKey("user")) {
          UserModel userModel = UserModel.fromJson(data);

          AuthManager authManager = AuthManager();
          await authManager.saveUserData(userModel); // Save full user model
          await authManager.saveUserId(userModel.id); // Save only user ID
          await authManager.saveHeadOffice(userModel.headOffice.id); // Save head office

          user.value = userModel; // Update state
         // Get.snackbar("Success", "Login Successful");

          // Navigate to Dashboard
          Get.offAll(() => DashboardScreen());
        } else {
          Get.snackbar("Error", "Invalid response from server");
        }
      } else {
        Get.snackbar("Error", data["message"] ?? "Login Failed");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close loading overlay in case of error
      }
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Load user from SharedPreferences
  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString("userData");

    if (userData != null) {
      user.value = UserModel.fromJsonString(userData);
    }
  }

  // Logout function to clear user data
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("userData");
    user.value = null;
    Get.offAll(() => const LoginScreen());
  }
}
