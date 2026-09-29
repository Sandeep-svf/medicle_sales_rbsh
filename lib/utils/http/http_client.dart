import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:medicle_sales_rbsh/utils/http/api_http.dart' as http;

import '../local_storage/auth_manager.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'api_ui_feedback.dart';

class THttpHelper {
  static const String defaultBaseUrl = 'https://test.gluckscare.com/api';
  static String _baseUrl = defaultBaseUrl;
  static String? _backendUrl;
  static String? _companyLogoPath;

  static String get baseUrl => _baseUrl;
  static String? get companyLogoUrl {
    final path = _companyLogoPath;
    final backend = _backendUrl;
    if (path == null || path.isEmpty || backend == null || backend.isEmpty) {
      return null;
    }
    final parsedPath = Uri.tryParse(path);
    if (parsedPath?.hasScheme == true) return path;
    return Uri.parse('${backend.replaceFirst(RegExp(r'/+$'), '')}/')
        .resolve(path.replaceFirst(RegExp(r'^/+'), ''))
        .toString();
  }

  static void configureCompany({String? backendUrl, String? logoUrl}) {
    if (backendUrl == null || backendUrl.trim().isEmpty) return;
    final normalizedBackend = backendUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    _backendUrl = normalizedBackend;
    _baseUrl = normalizedBackend.endsWith('/api')
        ? normalizedBackend
        : '$normalizedBackend/api';
    _companyLogoPath = logoUrl;
  }

  static void resetCompany() {
    _baseUrl = defaultBaseUrl;
    _backendUrl = null;
    _companyLogoPath = null;
  }

  // newly added for pass auth token as well
  static Future<Map<String, dynamic>> authGet(
    String endpoint,
  ) async {
    final token = await AuthManager().getAuthToken();

    return _send(() => http.get(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ));
  }

  static Future<Map<String, dynamic>> authPost(
    String endpoint,
    dynamic data,
  ) async {
    final token = await AuthManager().getAuthToken();

    return _send(() => http.post(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(data),
        ));
  }

  static Future<Map<String, dynamic>> authPut(
    String endpoint,
    dynamic data,
  ) async {
    final token = await AuthManager().getAuthToken();

    return _send(() => http.put(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(data),
        ));
  }

  static Future<Map<String, dynamic>> authDelete(
    String endpoint,
  ) async {
    final token = await AuthManager().getAuthToken();

    return _send(() => http.delete(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ));
  }

  // Helper method to make a GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    return _send(() => http.get(Uri.parse('$baseUrl/$endpoint')));
  }

  // Helper method to make a POST request
  static Future<Map<String, dynamic>> post(
      String endpoint, dynamic data) async {
    return _send(() => http.post(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        ));
  }

  // Helper method to make a PUT request
  static Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    return _send(() => http.put(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        ));
  }

  // Helper method to make a DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    return _send(() => http.delete(Uri.parse('$baseUrl/$endpoint')));
  }

  static Future<Map<String, dynamic>> _send(
      Future<http.Response> Function() request) async {
    try {
      return _handleResponse(await request());
    } on SocketException catch (error) {
      throw ApiException(statusCode: 0, message: ApiUiFeedback.message(error));
    } on http.ClientException catch (error) {
      throw ApiException(statusCode: 0, message: ApiUiFeedback.message(error));
    } on TimeoutException catch (error) {
      throw ApiException(statusCode: 0, message: ApiUiFeedback.message(error));
    }
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
          message: TTexts.uiTextInvalidRequestPleaseCheckYourInput,
        );

      case 401:
        throw ApiException(
          statusCode: 401,
          message: TTexts.uiTextSessionExpiredPleaseLoginAgain,
        );

      case 403:
        throw ApiException(
          statusCode: 403,
          message: TTexts.uiTextYouDonTHavePermissionToPerformThis,
        );

      case 404:
        throw ApiException(
          statusCode: 404,
          message: TTexts.uiTextRequestedResourceNotFound,
        );

      case 405:
        throw ApiException(
          statusCode: 405,
          message: TTexts.uiTextMethodNotAllowed,
        );

      case 408:
        throw ApiException(
          statusCode: 408,
          message: TTexts.uiTextRequestTimedOut,
        );

      case 409:
        throw ApiException(
          statusCode: 409,
          message: TTexts.uiTextConflictDetectedDataAlreadyExists,
        );

      case 410:
        throw ApiException(
          statusCode: 410,
          message: TTexts.uiTextRequestedResourceIsNoLongerAvailable,
        );

      case 415:
        throw ApiException(
          statusCode: 415,
          message: TTexts.uiTextUnsupportedMediaType,
        );

      case 422:
        throw ApiException(
          statusCode: 422,
          message: TTexts.uiTextValidationFailedPleaseCheckYourInput,
        );

      case 429:
        throw ApiException(
          statusCode: 429,
          message: TTexts.uiTextTooManyRequestsPleaseTryAgainLater,
        );

      case 500:
        throw ApiException(
          statusCode: 500,
          message: TTexts.uiTextInternalServerError,
        );

      case 501:
        throw ApiException(
          statusCode: 501,
          message: TTexts.uiTextFeatureNotImplemented,
        );

      case 502:
        throw ApiException(
          statusCode: 502,
          message: TTexts.uiTextBadGateway,
        );

      case 503:
        throw ApiException(
          statusCode: 503,
          message: TTexts.uiTextServiceTemporarilyUnavailable,
        );

      case 504:
        throw ApiException(
          statusCode: 504,
          message: TTexts.uiTextGatewayTimeout,
        );

      default:
        throw ApiException(
          statusCode: response.statusCode,
          message: TTexts.uiTextUnexpectedErrorOccurred,
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
