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
import '../models/headoffice.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var user = Rxn<UserModel>(); // Store user model in state

  static const String _baseUrl = THttpHelper.baseUrl;

  Future<void> login(String email, String password, String deviceID) async {
    print("AuthController: login() initiated for email: $email | deviceID: $deviceID");

    if (email.isEmpty || password.isEmpty) {
      print("AuthController: Validation failed - Email or Password is empty");
      Get.snackbar("Error", "Email and Password cannot be empty");
      return;
    }

    try {
      print("AuthController: Setting isLoading to true");
      isLoading.value = true;

      // Close any existing dialogs before opening a new one
      if (Get.isDialogOpen ?? false) {
        print("AuthController: Closing existing dialog");
        Get.back();
      }

      print("AuthController: Showing Loading Dialog");
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

      print("AuthController: Sending POST request to $_baseUrl/auth/login");
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password, "deviceId" : deviceID}),
       // body: jsonEncode({"email": email, "password": password}),
      );

      print("AuthController: deviceID  - deviceID: ${deviceID}");

      print("AuthController: Response received - Status Code: ${response.statusCode}");
      print("AuthController: Raw Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      // Close loading overlay
      if (Get.isDialogOpen ?? false) {
        print("AuthController: Closing loading overlay");
        Get.back();
      }

      if (response.statusCode == 200) {
        print("AuthController: Login Successful, checking for 'user' key in response");
        // Ensure 'user' key exists before parsing
        if (data.containsKey("user")) {
          print("AuthController: 'user' key found, parsing UserModel");
          // Parse the JSON into UserModel
          UserModel userModel = UserModel.fromJson(data);

          // Extract the token
          String? token = userModel.token;
          print("AuthController: Token extracted");

          // Initialize AuthManager
          AuthManager authManager = AuthManager();

          print("AuthController: Saving user data, ID, role, and token to AuthManager");
          // Save the full UserModel
          await authManager.saveUserData(userModel);

          // Save only the User ID
          await authManager.saveUserId(userModel.user!.id);
          await authManager.saveUserRole(userModel.user!.role);

          print("AuthController: auth check role saved -> ${userModel.user!.role}");

          // Save the auth token
          await authManager.saveAuthToken(token!);

          user.value = userModel; // Update state
          print("AuthController: User state updated in GetX controller");

          print("AuthController: Navigating to DashboardScreen");
          // Navigate to Dashboard
          Get.offAll(() => DashboardScreen());
        } else {
          print("AuthController Error: 'user' key missing from server response");
          Get.snackbar("AuthController Error", "Invalid response from server");
        }
      } else {
        print("AuthController Error: Login Failed with message -> ${data["message"]}");
        Get.snackbar("AuthController Error", data["message"] ?? "Login Failed");
      }
    } catch (e) {
      print("AuthController Error: Exception caught during login -> $e");
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close loading overlay in case of error
      }
      Get.snackbar("AuthController Error", "Something went wrong: $e");
    } finally {
      print("AuthController: Resetting isLoading to false");
      isLoading.value = false;
    }
  }

  /* // Load user from SharedPreferences
  Future<void> loadUser() async {
    print("AuthController: loadUser() called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString("userData");

    if (userData != null) {
      print("AuthController: userData found in SharedPreferences, parsing...");
      user.value = UserModel.fromJsonString(userData);
    } else {
      print("AuthController: No userData found in SharedPreferences");
    }
  }*/

  // Logout function to clear user data
  Future<void> logout() async {
    print("AuthController: logout() initiated");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("AuthController: Removing 'userData' from SharedPreferences");
    await prefs.remove("userData");
    user.value = null;
    print("AuthController: Navigating to LoginScreen");
    Get.offAll(() => const LoginScreen());
  }
}