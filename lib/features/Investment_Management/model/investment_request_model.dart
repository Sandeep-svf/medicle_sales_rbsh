import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvestmentRequestResponse {
  final bool success;
  final int count;
  final List<InvestmentRequest> data;

  InvestmentRequestResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory InvestmentRequestResponse.fromJson(Map<String, dynamic> json) {
    final requests = (json['data'] as List?)
            ?.whereType<Map>()
            .map((item) => InvestmentRequest.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList() ??
        [];

    return InvestmentRequestResponse(
      success: json['success'] ?? false,
      count: _asInt(json['count']) ?? requests.length,
      data: requests,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "count": count,
        "data": data.map((e) => e.toJson()).toList(),
      };
}

class InvestmentRequest {
  final String? id;
  final String? userId;
  final String? doctorId;
  final double? supportValueMtd;

  final String? paymentMode;
  final double? amount;
  final String? purpose;

  final String? bankDetails;
  final String? paymentProof;
  final String? upiId;

  final List<InvestmentItem> items;

  final String? justification;
  final String? rejectionReason;
  final String? status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final InvestmentDoctor? doctor;
  final InvestmentUser? user;

  final String? doctorName;
  final String? userName;

  bool get isCash => paymentMode == "Cash";

  bool get isNeft => paymentMode == "NEFT";

  bool get isUpi => paymentMode == "UPI";

  bool get isGift => paymentMode == "Items/Gift";

  bool get hasProof => paymentProof != null && paymentProof!.isNotEmpty;

  bool get hasItems => items.isNotEmpty;

  bool get canEdit {
    final normalizedStatus = status?.trim().toLowerCase();
    return normalizedStatus == "draft" || normalizedStatus == "rejected";
  }

  String get displayDoctorName =>
      doctor?.name ?? doctorName ?? "Unknown Doctor";

  String get displayAmount {
    final value = amount;
    if (value == null) return "-";

    final decimals = value == value.truncateToDouble() ? 0 : 2;
    return "₹${value.toStringAsFixed(decimals)}";
  }

  String get displayPurpose => purpose ?? justification ?? "-";

  String get displayStatus => status ?? "-";

  String get displayDate {
    if (createdAt == null) return "-";
    return DateFormat("dd MMM yyyy").format(createdAt!);
  }

  String get avatarLetter {
    if (displayDoctorName.isEmpty) return "?";
    return displayDoctorName[0].toUpperCase();
  }

  Color get paymentColor {
    switch (paymentMode) {
      case "Cash":
        return Colors.green;

      case "NEFT":
        return Colors.blue;

      case "UPI":
        return Colors.deepPurple;

      case "Items/Gift":
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  IconData get paymentIcon {
    switch (paymentMode) {
      case "Cash":
        return Icons.currency_rupee;

      case "NEFT":
        return Icons.account_balance;

      case "UPI":
        return Icons.qr_code;

      case "Items/Gift":
        return Icons.card_giftcard;

      default:
        return Icons.payments;
    }
  }

  Color get statusColor {
    switch (status) {
      case "Pending":
        return Colors.orange;

      case "Approved":
        return Colors.blue;

      case "Rejected":
        return Colors.red;

      case "Paid":
        return Colors.green;

      case "Draft":
        return Colors.grey;

      default:
        return Colors.grey;
    }
  }

  InvestmentRequest({
    this.id,
    this.userId,
    this.doctorId,
    this.supportValueMtd,
    this.paymentMode,
    this.amount,
    this.purpose,
    this.bankDetails,
    this.paymentProof,
    this.upiId,
    this.items = const [],
    this.justification,
    this.rejectionReason,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.doctor,
    this.user,
    this.doctorName,
    this.userName,
  });

  factory InvestmentRequest.fromJson(Map<String, dynamic> json) {
    return InvestmentRequest(
      id: _asString(json["id"] ?? json["_id"]),
      userId: _asString(json["user_id"]),
      doctorId: _asString(json["doctor_id"]),
      supportValueMtd: _asDouble(json["support_value_mtd"]),
      paymentMode: _asString(json["payment_mode"]),
      amount: _asDouble(json["amount"]),
      purpose: _asString(json["purpose"]),
      bankDetails: _asString(json["bank_details"]),
      paymentProof: _asString(json["payment_proof"]),
      upiId: _asString(json["upi_id"]),
      items: (json["items"] as List?)
              ?.whereType<Map>()
              .map((item) => InvestmentItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList() ??
          [],
      justification: _asString(json["justification"]),
      rejectionReason: _asString(json["rejection_reason"]),
      status: _asString(json["status"]),
      createdAt: _asDateTime(json["created_at"]),
      updatedAt: _asDateTime(json["updated_at"]),
      doctor: json["doctor"] is Map
          ? InvestmentDoctor.fromJson(
              Map<String, dynamic>.from(json["doctor"]),
            )
          : null,
      user: json["user"] is Map
          ? InvestmentUser.fromJson(
              Map<String, dynamic>.from(json["user"]),
            )
          : null,
      doctorName: _asString(json["doctorName"]),
      userName: _asString(json["userName"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "doctor_id": doctorId,
        "support_value_mtd": supportValueMtd,
        "payment_mode": paymentMode,
        "amount": amount,
        "purpose": purpose,
        "bank_details": bankDetails,
        "payment_proof": paymentProof,
        "upi_id": upiId,
        "items": items.map((e) => e.toJson()).toList(),
        "justification": justification,
        "rejection_reason": rejectionReason,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "doctor": doctor?.toJson(),
        "user": user?.toJson(),
        "doctorName": doctorName,
        "userName": userName,
      };
}

class InvestmentItem {
  final String? itemName;
  final int? quantity;
  final double? value;

  InvestmentItem({
    this.itemName,
    this.quantity,
    this.value,
  });

  factory InvestmentItem.fromJson(Map<String, dynamic> json) {
    return InvestmentItem(
      itemName: _asString(json["itemName"]),
      quantity: _asInt(json["quantity"]),
      value: _asDouble(json["value"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "itemName": itemName,
        "quantity": quantity,
        "value": value,
      };
}

class InvestmentDoctor {
  final String? id;
  final String? name;

  InvestmentDoctor({
    this.id,
    this.name,
  });

  factory InvestmentDoctor.fromJson(Map<String, dynamic> json) {
    return InvestmentDoctor(
      id: _asString(json["id"]),
      name: _asString(json["name"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class InvestmentUser {
  final String? id;
  final String? name;
  final String? email;
  final String? stateId;
  final String? headOfficeId;
  final List<String> headOfficeIds;

  InvestmentUser({
    this.id,
    this.name,
    this.email,
    this.stateId,
    this.headOfficeId,
    this.headOfficeIds = const [],
  });

  factory InvestmentUser.fromJson(Map<String, dynamic> json) {
    return InvestmentUser(
      id: _asString(json["id"]),
      name: _asString(json["name"]),
      email: _asString(json["email"]),
      stateId: _asString(json["state_id"]),
      headOfficeId: _asString(json["head_office_id"]),
      headOfficeIds: (json["headOffices"] as List?)
              ?.whereType<Map>()
              .map((office) => _asString(office["id"]))
              .whereType<String>()
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "state_id": stateId,
        "head_office_id": headOfficeId,
        "headOffices": headOfficeIds.map((id) => {"id": id}).toList(),
      };
}

String? _asString(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? "");
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "");
}

DateTime? _asDateTime(dynamic value) {
  final text = _asString(value);
  return text == null ? null : DateTime.tryParse(text);
}
