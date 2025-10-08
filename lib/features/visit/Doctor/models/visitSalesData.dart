import 'dart:convert';
import 'package:intl/intl.dart';

/// =======================
/// Models
/// =======================

class VisitSalesLogModel {
  final String id;            // visit id (required; defaults to "")
  final String doctorId;      // doctor_id
  final String userId;        // user_id

  /// Date as sent by server (e.g. "2025-04-26")
  final String? dateStr;

  /// Parsed date from [dateStr] (nullable if parse fails)
  final DateTime? date;

  final String? notes;
  final double? latitude;
  final double? longitude;
  final bool confirmed;
  final String? remark;
  final String? productId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VisitDoctor? doctor;
  final VisitUser? user;

  VisitSalesLogModel({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.confirmed,
    this.dateStr,
    this.date,
    this.notes,
    this.latitude,
    this.longitude,
    this.remark,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.doctor,
    this.user,
  });

  factory VisitSalesLogModel.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return VisitSalesLogModel(
        id: "",
        doctorId: "",
        userId: "",
        confirmed: false,
      );
    }

    String _s(dynamic v) => v?.toString() ?? "";
    String? _sn(dynamic v) => (v == null || v.toString().trim().isEmpty) ? null : v.toString().trim();
    double? _d(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    // date handling
    final String? rawDate = _sn(j['date']); // "YYYY-MM-DD"
    DateTime? parsedDate;
    if (rawDate != null) {
      try {
        parsedDate = DateFormat('yyyy-MM-dd').parse(rawDate, true).toLocal();
      } catch (_) {
        parsedDate = null;
      }
    }

    DateTime? _dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    return VisitSalesLogModel(
      id: _s(j['id']).trim(),
      doctorId: _s(j['doctor_id']).trim(),
      userId: _s(j['user_id']).trim(),
      dateStr: rawDate,
      date: parsedDate,
      notes: _sn(j['notes']),
      latitude: _d(j['latitude']),
      longitude: _d(j['longitude']),
      confirmed: (j['confirmed'] ?? false) == true,
      remark: _sn(j['remark']),
      productId: _sn(j['product_id']),
      createdAt: _dt(j['created_at']),
      updatedAt: _dt(j['updated_at']),
      doctor: (j['doctor'] is Map) ? VisitDoctor.fromJson(j['doctor']) : null,
      user: (j['user'] is Map) ? VisitUser.fromJson(j['user']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "doctor_id": doctorId,
    "user_id": userId,
    // Keep the server’s original date format on write-back
    "date": dateStr,
    "notes": notes,
    "latitude": latitude,
    "longitude": longitude,
    "confirmed": confirmed,
    "remark": remark,
    "product_id": productId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "doctor": doctor?.toJson(),
    "user": user?.toJson(),
  };

  /// Convenience: parse a JSON array string -> List<VisitSalesLogModel>
  static List<VisitSalesLogModel> listFromRawJson(String raw) {
    final data = json.decode(raw);
    if (data is List) {
      return data
          .map<VisitSalesLogModel>((e) => VisitSalesLogModel.fromJson(e as Map<String, dynamic>?))
          .toList();
    }
    return const <VisitSalesLogModel>[];
  }

  /// Convenience: List<VisitSalesLogModel> -> JSON array string
  static String listToRawJson(List<VisitSalesLogModel> items) =>
      json.encode(items.map((e) => e.toJson()).toList());
}

class VisitDoctor {
  final String id;
  final String name;
  final String? specialization;

  VisitDoctor({
    required this.id,
    required this.name,
    this.specialization,
  });

  factory VisitDoctor.fromJson(Map<String, dynamic>? j) {
    if (j == null) return VisitDoctor(id: "", name: "");
    String _s(dynamic v) => v?.toString() ?? "";
    String? _sn(dynamic v) => (v == null || v.toString().trim().isEmpty) ? null : v.toString().trim();

    return VisitDoctor(
      id: _s(j['id']).trim(),
      name: _s(j['name']).trim(),
      specialization: _sn(j['specialization']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "specialization": specialization,
  };
}

class VisitUser {
  final String id;
  final String name;
  final String? email;

  VisitUser({
    required this.id,
    required this.name,
    this.email,
  });

  factory VisitUser.fromJson(Map<String, dynamic>? j) {
    if (j == null) return VisitUser(id: "", name: "");
    String _s(dynamic v) => v?.toString() ?? "";
    String? _sn(dynamic v) => (v == null || v.toString().trim().isEmpty) ? null : v.toString().trim();

    return VisitUser(
      id: _s(j['id']).trim(),
      name: _s(j['name']).trim(),
      email: _sn(j['email']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
  };
}
