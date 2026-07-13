import 'dart:convert';
import 'package:http/http.dart' as http;

import '../local_storage/auth_manager.dart';

class THttpHelper {
     // static const String baseUrl = 'https://test.gluckscare.com/api'; // API base URL prod
    // static const String baseUrl = 'https://apiv2.gluckscare.com/api'; // API base URL prod
      static const String baseUrl = 'https://api.gluckscare.com/api'; // API base URL development test


      // newly added for pass auth token as well
      static Future<Map<String, dynamic>> authGet(
          String endpoint,
          ) async {

        final token = await AuthManager().getAuthToken();

        final response = await http.get(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        return _handleResponse(response);
      }


      static Future<Map<String, dynamic>> authPost(
          String endpoint,
          dynamic data,
          ) async {

        final token = await AuthManager().getAuthToken();

        final response = await http.post(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(data),
        );

        return _handleResponse(response);
      }

      static Future<Map<String, dynamic>> authPut(
          String endpoint,
          dynamic data,
          ) async {

        final token = await AuthManager().getAuthToken();

        final response = await http.put(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(data),
        );

        return _handleResponse(response);
      }

      static Future<Map<String, dynamic>> authDelete(
          String endpoint,
          ) async {

        final token = await AuthManager().getAuthToken();

        final response = await http.delete(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        return _handleResponse(response);
      }



  // Helper method to make a GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  // Helper method to make a POST request
  static Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }
  // Helper method to make a PUT request
  static Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }
  // Helper method to make a DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  // Handle the HTTP response
      static Map<String, dynamic> _handleResponse(http.Response response) {
        switch (response.statusCode) {
          case 200:
          case 201:
          case 202:
            return json.decode(response.body);

          case 204:
            return {
              "success": true,
              "message": "Operation completed successfully."
            };

          case 400:
            throw ApiException(
              statusCode: 400,
              message: "Invalid request. Please check your input.",
            );

          case 401:
            throw ApiException(
              statusCode: 401,
              message: "Session expired. Please login again.",
            );

          case 403:
            throw ApiException(
              statusCode: 403,
              message: "You don't have permission to perform this action.",
            );

          case 404:
            throw ApiException(
              statusCode: 404,
              message: "Requested resource not found.",
            );

          case 405:
            throw ApiException(
              statusCode: 405,
              message: "Method not allowed.",
            );

          case 408:
            throw ApiException(
              statusCode: 408,
              message: "Request timed out.",
            );

          case 409:
            throw ApiException(
              statusCode: 409,
              message: "Conflict detected. Data already exists.",
            );

          case 410:
            throw ApiException(
              statusCode: 410,
              message: "Requested resource is no longer available.",
            );

          case 415:
            throw ApiException(
              statusCode: 415,
              message: "Unsupported media type.",
            );

          case 422:
            throw ApiException(
              statusCode: 422,
              message: "Validation failed. Please check your input.",
            );

          case 429:
            throw ApiException(
              statusCode: 429,
              message: "Too many requests. Please try again later.",
            );

          case 500:
            throw ApiException(
              statusCode: 500,
              message: "Internal server error.",
            );

          case 501:
            throw ApiException(
              statusCode: 501,
              message: "Feature not implemented.",
            );

          case 502:
            throw ApiException(
              statusCode: 502,
              message: "Bad gateway.",
            );

          case 503:
            throw ApiException(
              statusCode: 503,
              message: "Service temporarily unavailable.",
            );

          case 504:
            throw ApiException(
              statusCode: 504,
              message: "Gateway timeout.",
            );

          default:
            throw ApiException(
              statusCode: response.statusCode,
              message: "Unexpected error occurred.",
            );
        }
      }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => '[$statusCode] $message';
}
