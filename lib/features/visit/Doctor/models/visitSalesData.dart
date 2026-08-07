import 'dart:convert';
import 'package:intl/intl.dart';

class VisitSalesLogModel {
  final String id;
  final String doctorId;
  final String userId;

  final String? dateStr;
  final DateTime? date;

  final String? notes;
  final double? latitude;
  final double? longitude;

  final bool confirmed;

  final String? remark;
  final String? productId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? headOfficeId;

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
    this.headOfficeId,
    this.doctor,
    this.user,
  });

  factory VisitSalesLogModel.fromJson(
      Map<String, dynamic>? j,
      ) {
    if (j == null) {
      return VisitSalesLogModel(
        id: "",
        doctorId: "",
        userId: "",
        confirmed: false,
      );
    }

    String _s(dynamic v) =>
        v?.toString() ?? "";

    String? _sn(dynamic v) {
      if (v == null) return null;

      final value =
      v.toString().trim();

      return value.isEmpty
          ? null
          : value;
    }

    double? _d(dynamic v) {
      if (v == null) return null;

      if (v is num) {
        return v.toDouble();
      }

      return double.tryParse(
        v.toString(),
      );
    }

    DateTime? _dt(dynamic v) {
      if (v == null) return null;

      return DateTime.tryParse(
        v.toString(),
      );
    }

    final String? rawDate =
    _sn(j['date']);

    DateTime? parsedDate;

    if (rawDate != null) {
      try {
        parsedDate =
            DateFormat(
              'yyyy-MM-dd',
            )
                .parse(
              rawDate,
              true,
            )
                .toLocal();
      } catch (_) {}
    }

    return VisitSalesLogModel(
      id: _s(j['id']).trim(),
      doctorId:
      _s(j['doctor_id']).trim(),
      userId:
      _s(j['user_id']).trim(),

      dateStr: rawDate,
      date: parsedDate,

      notes: _sn(j['notes']),

      latitude: _d(
        j['latitude'],
      ),

      longitude: _d(
        j['longitude'],
      ),

      confirmed:
      j['confirmed'] == true,

      remark: _sn(j['remark']),

      productId:
      _sn(j['product_id']),

      createdAt:
      _dt(j['created_at']),

      updatedAt:
      _dt(j['updated_at']),

      headOfficeId: _sn(
        j['headOfficeId'] ??
            j['head_office_id'],
      ),

      doctor:
      (j['doctor'] is Map)
          ? VisitDoctor.fromJson(
        j['doctor'],
      )
          : null,

      user:
      (j['user'] is Map)
          ? VisitUser.fromJson(
        j['user'],
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "doctor_id": doctorId,
    "user_id": userId,
    "date": dateStr,
    "notes": notes,
    "latitude": latitude,
    "longitude": longitude,
    "confirmed": confirmed,
    "remark": remark,
    "product_id": productId,
    "created_at":
    createdAt?.toIso8601String(),
    "updated_at":
    updatedAt?.toIso8601String(),
    "headOfficeId": headOfficeId,
    "doctor": doctor?.toJson(),
    "user": user?.toJson(),
  };

  static List<VisitSalesLogModel>
  listFromRawJson(String raw) {
    try {
      final data = json.decode(raw);

      if (data is List) {
        return data
            .map<
            VisitSalesLogModel>(
              (e) =>
              VisitSalesLogModel
                  .fromJson(
                e as Map<
                    String,
                    dynamic>,
              ),
        )
            .toList();
      }
    } catch (_) {}

    return const <
        VisitSalesLogModel>[];
  }
}

class VisitDoctor {
  final String id;
  final String name;
  final String? specialization;

  final String? areaId;
  final String? headOfficeId;

  final double? latitude;
  final double? longitude;

  final bool geoImageStatus;

  VisitDoctor({
    required this.id,
    required this.name,
    this.specialization,
    this.areaId,
    this.headOfficeId,
    this.latitude,
    this.longitude,
    this.geoImageStatus = false,
  });

  factory VisitDoctor.fromJson(
      Map<String, dynamic>? j,
      ) {
    if (j == null) {
      return VisitDoctor(
        id: "",
        name: "",
      );
    }

    String _s(dynamic v) => v?.toString() ?? "";

    String? _sn(dynamic v) {
      if (v == null) return null;

      final value = v.toString().trim();

      return value.isEmpty ? null : value;
    }

    double? _d(dynamic v) {
      if (v == null) return null;

      if (v is num) {
        return v.toDouble();
      }

      return double.tryParse(v.toString());
    }

    return VisitDoctor(
      id: _s(j['id']).trim(),
      name: _s(j['name']).trim(),

      specialization: _sn(
        j['specialization'],
      ),

      areaId: _sn(
        j['areaId'],
      ),

      headOfficeId: _sn(
        j['headOfficeId'],
      ),

      latitude: _d(
        j['latitude'],
      ),

      longitude: _d(
        j['longitude'],
      ),

      geoImageStatus:
      j['geo_image_status'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "specialization": specialization,
    "areaId": areaId,
    "headOfficeId": headOfficeId,
    "latitude": latitude,
    "longitude": longitude,
    "geo_image_status": geoImageStatus,
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

  factory VisitUser.fromJson(
      Map<String, dynamic>? j,
      ) {
    if (j == null) {
      return VisitUser(
        id: "",
        name: "",
      );
    }

    String _s(dynamic v) =>
        v?.toString() ?? "";

    String? _sn(dynamic v) {
      if (v == null) return null;

      final value =
      v.toString().trim();

      return value.isEmpty
          ? null
          : value;
    }

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