import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/features/authentication/screens/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicle_sales_rbsh/features/dashboard/screen/dashboard.dart';


import '../models/UserModel.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var user = Rxn<UserModel>(); // Store user model in state

  static const String _baseUrl = "https://medi-glucks-erp.onrender.com/api/auth";

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and Password cannot be empty");
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse("$_baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Directly pass API response to UserModel (No manual mapping)
        UserModel userModel = UserModel.fromJson(data);

        // Save UserModel as JSON in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("userData", userModel.toJsonString());

        user.value = userModel; // Update state
        Get.snackbar("Success", "Login Successful");
        Get.offAll(() => DashboardScreen());
      } else {
        Get.snackbar("Error", data["message"] ?? "Login Failed");
      }
    } catch (e) {
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
    Get.offAll(() => LoginScreen());
  }
}
