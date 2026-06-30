import 'dart:ui';

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
    return InvestmentRequestResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List?)
          ?.map((e) => InvestmentRequest.fromJson(e))
          .toList() ??
          [],
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
  final String? supportValueMtd;

  final String? paymentMode;
  final String? amount;
  final String? purpose;

  final String? bankDetails;
  final String? paymentProof;
  final String? upiId;

  final List<InvestmentItem> items;

  final String? justification;
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

  bool get hasProof =>
      paymentProof != null && paymentProof!.isNotEmpty;

  bool get hasItems => items.isNotEmpty;

  String get displayDoctorName =>
      doctor?.name ?? doctorName ?? "Unknown Doctor";

  String get displayAmount =>
      amount == null || amount!.isEmpty ? "-" : "₹$amount";

  String get displayPurpose =>
      purpose ?? justification ?? "-";

  String get displayStatus =>
      status ?? "-";

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
      id: json["id"],
      userId: json["user_id"],
      doctorId: json["doctor_id"],
      supportValueMtd: json["support_value_mtd"],
      paymentMode: json["payment_mode"],
      amount: json["amount"],
      purpose: json["purpose"],
      bankDetails: json["bank_details"],
      paymentProof: json["payment_proof"],
      upiId: json["upi_id"],

      items: (json["items"] as List?)
          ?.map((e) => InvestmentItem.fromJson(e))
          .toList() ??
          [],

      justification: json["justification"],
      status: json["status"],

      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"]),

      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"]),

      doctor: json["doctor"] == null
          ? null
          : InvestmentDoctor.fromJson(json["doctor"]),

      user: json["user"] == null
          ? null
          : InvestmentUser.fromJson(json["user"]),

      doctorName: json["doctorName"],
      userName: json["userName"],
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
  final dynamic value;

  InvestmentItem({
    this.itemName,
    this.quantity,
    this.value,
  });

  factory InvestmentItem.fromJson(Map<String, dynamic> json) {
    return InvestmentItem(
      itemName: json["itemName"],
      quantity: json["quantity"],
      value: json["value"],
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
      id: json["id"],
      name: json["name"],
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

  InvestmentUser({
    this.id,
    this.name,
    this.email,
    this.stateId,
  });

  factory InvestmentUser.fromJson(Map<String, dynamic> json) {
    return InvestmentUser(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      stateId: json["state_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "state_id": stateId,
  };
}