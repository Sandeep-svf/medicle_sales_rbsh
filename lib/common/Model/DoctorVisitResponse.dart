import 'dart:convert';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class VisitConfirmResponse {
  final bool status;
  final bool success;
  final String message;
  final int distance;

  VisitConfirmResponse({
    required this.status,
    required this.success,
    required this.message,
    required this.distance,
  });

  /// Factory: JSON -> Dart object
  factory VisitConfirmResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return VisitConfirmResponse(
        status: false,
        success: false,
        message: TTexts.uiTextNoResponse,
        distance: 0,
      );
    }

    return VisitConfirmResponse(
      status: json['status'] ?? false,
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      distance: json['distance'] ?? 0,
    );
  }

  /// Dart object -> JSON
  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "success": success,
      "message": message,
      "distance": distance,
    };
  }

  /// Parse from raw JSON string
  static VisitConfirmResponse fromRawJson(String str) =>
      VisitConfirmResponse.fromJson(json.decode(str));

  /// Convert to raw JSON string
  String toRawJson() => json.encode(toJson());
}
