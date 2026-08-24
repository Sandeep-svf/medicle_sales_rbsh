import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../utils/http/http_client.dart';

class InvestmentApiService {
  static const Duration requestTimeout = Duration(seconds: 30);

  static String get requestsUrl => "${THttpHelper.baseUrl}/investment-requests";

  static String get headOfficeRequestsUrl => "$requestsUrl/by-head-office";

  static String requestUrl(String id) =>
      "$requestsUrl/${Uri.encodeComponent(id.trim())}";

  static String approveUrl(String id) => "${requestUrl(id)}/approve";

  static String rejectUrl(String id) => "${requestUrl(id)}/reject";

  Future<http.Response> fetchRequests({
    required String token,
    String? status,
    bool byHeadOffice = false,
  }) {
    final baseUrl = byHeadOffice ? headOfficeRequestsUrl : requestsUrl;
    final trimmedStatus = status?.trim();
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: trimmedStatus == null || trimmedStatus.isEmpty
          ? null
          : {"status": trimmedStatus},
    );

    return http
        .get(
          uri,
          headers: _authorizationHeaders(token),
        )
        .timeout(requestTimeout);
  }

  Future<http.Response> createRequest({
    required String token,
    required Map<String, dynamic> payload,
    Uint8List? paymentProofBytes,
    String? paymentProofFilename,
  }) async {
    if (paymentProofBytes == null || paymentProofBytes.isEmpty) {
      return _sendJson(
        method: "POST",
        url: requestsUrl,
        token: token,
        payload: payload,
      );
    }

    return _sendMultipart(
      method: "POST",
      url: requestsUrl,
      token: token,
      payload: payload,
      paymentProofBytes: paymentProofBytes,
      paymentProofFilename: paymentProofFilename,
    );
  }

  Future<http.Response> updateRequest({
    required String token,
    required String id,
    required Map<String, dynamic> payload,
    Uint8List? paymentProofBytes,
    String? paymentProofFilename,
  }) {
    if (paymentProofBytes != null && paymentProofBytes.isNotEmpty) {
      return _sendMultipart(
        method: "PUT",
        url: requestUrl(id),
        token: token,
        payload: payload,
        paymentProofBytes: paymentProofBytes,
        paymentProofFilename: paymentProofFilename,
      );
    }

    return _sendJson(
      method: "PUT",
      url: requestUrl(id),
      token: token,
      payload: payload,
    );
  }

  Future<http.Response> approveRequest({
    required String token,
    required String id,
  }) {
    return http
        .put(
          Uri.parse(approveUrl(id)),
          headers: _authorizationHeaders(token),
        )
        .timeout(requestTimeout);
  }

  Future<http.Response> rejectRequest({
    required String token,
    required String id,
    required String rejectionReason,
  }) {
    return _sendJson(
      method: "PUT",
      url: rejectUrl(id),
      token: token,
      payload: {"rejection_reason": rejectionReason.trim()},
    );
  }

  String responseMessage(
    http.Response response, {
    required String fallback,
  }) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        for (final key in const ["message", "msg", "error"]) {
          final value = decoded[key];

          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }

          if (value is Map || value is List) {
            final nestedMessage = _flattenError(value);
            if (nestedMessage.isNotEmpty) {
              return nestedMessage;
            }
          }
        }

        final validationMessage = _flattenError(decoded["errors"]);
        if (validationMessage.isNotEmpty) {
          return validationMessage;
        }
      }
    } catch (_) {}

    return fallback;
  }

  Future<http.Response> _sendJson({
    required String method,
    required String url,
    required String token,
    required Map<String, dynamic> payload,
  }) {
    final uri = Uri.parse(url);
    final headers = {
      ..._authorizationHeaders(token),
      "Content-Type": "application/json",
    };
    final body = jsonEncode(payload);

    switch (method) {
      case "POST":
        return http
            .post(uri, headers: headers, body: body)
            .timeout(requestTimeout);
      case "PUT":
        return http
            .put(uri, headers: headers, body: body)
            .timeout(requestTimeout);
      default:
        throw ArgumentError.value(method, "method", "Unsupported HTTP method");
    }
  }

  Future<http.Response> _sendMultipart({
    required String method,
    required String url,
    required String token,
    required Map<String, dynamic> payload,
    required Uint8List paymentProofBytes,
    String? paymentProofFilename,
  }) async {
    final filename = paymentProofFilename?.trim().isNotEmpty == true
        ? paymentProofFilename!.trim()
        : "payment_proof.jpg";
    final contentType = http.MultipartFile.fromBytes(
      "contentType",
      const <int>[],
    ).contentType.change(
          mimeType: _imageMimeType(filename, paymentProofBytes),
        );
    final request = http.MultipartRequest(method, Uri.parse(url));

    request.headers.addAll(_authorizationHeaders(token));

    for (final entry in payload.entries) {
      request.fields[entry.key] = _multipartFieldValue(entry.value);
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        "paymentProof",
        paymentProofBytes,
        filename: filename,
        contentType: contentType,
      ),
    );

    final streamedResponse = await request.send().timeout(requestTimeout);
    return http.Response.fromStream(streamedResponse).timeout(requestTimeout);
  }

  Map<String, String> _authorizationHeaders(String token) {
    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    };
  }

  String _multipartFieldValue(dynamic value) {
    if (value is String) {
      return value;
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    return jsonEncode(value);
  }

  String _imageMimeType(String filename, Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return "image/png";
    }

    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return "image/jpeg";
    }

    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == "RIFF" &&
        String.fromCharCodes(bytes.sublist(8, 12)) == "WEBP") {
      return "image/webp";
    }

    final extension = filename.toLowerCase().split('.').last;
    switch (extension) {
      case "png":
        return "image/png";
      case "webp":
        return "image/webp";
      case "gif":
        return "image/gif";
      case "heic":
        return "image/heic";
      case "heif":
        return "image/heif";
      default:
        return "image/jpeg";
    }
  }

  String _flattenError(dynamic value) {
    if (value is String) {
      return value.trim();
    }

    if (value is List) {
      return value
          .map(_flattenError)
          .where((message) => message.isNotEmpty)
          .join("\n");
    }

    if (value is Map) {
      return value.values
          .map(_flattenError)
          .where((message) => message.isNotEmpty)
          .join("\n");
    }

    return "";
  }
}
