import 'package:medicle_sales_rbsh/features/authentication/models/headoffice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/authentication/models/UserModel.dart';

class AuthManager {
  static const String userKey = "user_data";
  static const String userIdKey = "user_id";

  static const String headOfficeKey = "head_offices";
  static const String tokenKey = "token";
  static const String roleKey = "role";



  ///  Save User Data in SharedPreferences
  Future<void> saveUserData(UserModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user.toJson()));
  }



// Save list of head offices to SharedPreferences
  Future<void> saveHeadOffices(List<HeadOfficeCustom> headOffices) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the list of HeadOfficeCustom objects to a list of JSON maps
    List<Map<String, dynamic>> headOfficesJson = headOffices.map((e) => e.toJson()).toList();

    // Convert the list of JSON maps to a JSON string
    String headOfficesJsonString = jsonEncode(headOfficesJson);

    // Store the JSON string in SharedPreferences
    await prefs.setString(headOfficeKey, headOfficesJsonString);
  }

  // Get list of head offices from SharedPreferences
  Future<List<HeadOfficeCustom>?> getHeadOffices() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string
    String? headOfficesJsonString = prefs.getString(headOfficeKey);

    if (headOfficesJsonString != null) {
      // Decode the JSON string into a list of maps
      List<dynamic> decodedList = jsonDecode(headOfficesJsonString);

      // Convert the list of maps into a list of HeadOfficeCustom objects
      List<HeadOfficeCustom> headOfficesList = decodedList
          .map((e) => HeadOfficeCustom.fromJson(Map<String, dynamic>.from(e))) // Use HeadOfficeCustom instead of HeadOffice
          .toList();

      return headOfficesList;
    }
    return null;
  }




  /// Save only User ID
  Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userIdKey, userId);
  }

  /// Save auth token
  Future<void> saveAuthToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  /// Save user role
  Future<void> saveUserRole(String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(roleKey, role);
  }


  /// get user role
  Future<String?> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(roleKey);
  }


  /// Get auth token
  Future<String?> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }


 /* /// Save head office
  Future<void> saveHeadOffice(String headOffice) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(headOfficeKey, headOffice);
  }

  /// Get Head Office
  Future<String?> getHeadOffice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(headOfficeKey);
  }*/

  ///  Get User ID
  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  /// Get Full User Data
  Future<UserModel?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  ///  Logout (Clear Data)
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
  }
}
