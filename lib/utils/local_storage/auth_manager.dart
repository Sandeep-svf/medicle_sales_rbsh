import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/authentication/models/UserModel.dart';

class AuthManager {
  static const String userKey = "user_data";
  static const String userIdKey = "user_id";
  static const String headOfficeKey = "head_office";
  static const String tokenKey = "token";

  ///  Save User Data in SharedPreferences
  Future<void> saveUserData(UserModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user.toJson()));
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

  /// Get auth token
  Future<String?> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }


  /// Save head office
  Future<void> saveHeadOffice(String headOffice) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(headOfficeKey, headOffice);
  }

  /// Get Head Office
  Future<String?> getHeadOffice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(headOfficeKey);
  }

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
