import 'dart:convert';
import 'package:intl/intl.dart';

/// =======================
/// Visit Sales Log Model
/// =======================

class VisitSalesLogModel {
  final String id;
  final String doctorId;
  final String userId;

  /// Original date string from server (e.g. "2026-01-28")
  final String? dateStr;

  /// Parsed DateTime object for UI logic
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
      // Return a safe empty object if json is null
      return VisitSalesLogModel(
        id: "",
        doctorId: "",
        userId: "",
        confirmed: false,
      );
    }

    // --- Helper Functions for Defensive Parsing ---
    String _s(dynamic v) => v?.toString() ?? "";

    // Returns null if string is empty or null
    String? _sn(dynamic v) => (v == null || v.toString().trim().isEmpty) ? null : v.toString().trim();

    // Safely parses Double (handles Strings "12.5" and Numbers 12.5)
    double? _d(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    // Safely parses DateTime (ISO 8601)
    DateTime? _dt(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

    // --- Specific Logic ---

    // Handle specific date format "yyyy-MM-dd"
    final String? rawDate = _sn(j['date']);
    DateTime? parsedDate;
    if (rawDate != null) {
      try {
        parsedDate = DateFormat('yyyy-MM-dd').parse(rawDate, true).toLocal();
      } catch (_) {
        parsedDate = null; // Fail silently if format changes
      }
    }

    return VisitSalesLogModel(
      id: _s(j['id']).trim(),
      doctorId: _s(j['doctor_id']).trim(),
      userId: _s(j['user_id']).trim(),
      dateStr: rawDate,
      date: parsedDate,
      notes: _sn(j['notes']),
      latitude: _d(j['latitude']),
      longitude: _d(j['longitude']),
      confirmed: j['confirmed'] == true, // strict boolean check
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
    "date": dateStr,
    "notes": notes,
    "latitude": latitude, // Will convert double to number in JSON
    "longitude": longitude,
    "confirmed": confirmed,
    "remark": remark,
    "product_id": productId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "doctor": doctor?.toJson(),
    "user": user?.toJson(),
  };

  /// Helper: Parse list from raw JSON string
  static List<VisitSalesLogModel> listFromRawJson(String raw) {
    try {
      final data = json.decode(raw);
      if (data is List) {
        return data
            .map<VisitSalesLogModel>((e) => VisitSalesLogModel.fromJson(e as Map<String, dynamic>?))
            .toList();
      }
    } catch (e) {
      // print("Error parsing list: $e");
    }
    return const <VisitSalesLogModel>[];
  }
}

/// =======================
/// Doctor Model
/// =======================

class VisitDoctor {
  final String id;
  final String name;
  final String? specialization;
  final bool geoImageStatus;

  VisitDoctor({
    required this.id,
    required this.name,
    this.specialization,
    this.geoImageStatus = false,
  });

  factory VisitDoctor.fromJson(Map<String, dynamic>? j) {
    if (j == null) return VisitDoctor(id: "", name: "");

    String _s(dynamic v) => v?.toString() ?? "";
    String? _sn(dynamic v) => (v == null || v.toString().trim().isEmpty) ? null : v.toString().trim();

    return VisitDoctor(
      id: _s(j['id']).trim(),
      name: _s(j['name']).trim(),
      specialization: _sn(j['specialization']),
      geoImageStatus: j['geo_image_status'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "specialization": specialization,
    "geo_image_status": geoImageStatus,
  };
}

/// =======================
/// User Model
/// =======================

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