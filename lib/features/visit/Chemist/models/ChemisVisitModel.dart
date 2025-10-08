import 'dart:convert';
import 'package:intl/intl.dart';

class ChemistVisitModel {
  final String id;               // visit id
  final String chemistId;        // chemist_id
  final String userId;           // user_id

  // Server sends date as "YYYY-MM-DD"
  final String? dateStr;         // raw
  final DateTime? date;          // parsed (nullable if parse fails)

  final String? notes;
  final bool confirmed;

  // Lat/Lng can be null or string; keep both raw and parsed
  final String? latitudeStr;
  final String? longitudeStr;
  final double? latitude;
  final double? longitude;

  final DateTime? createdAt;     // ISO
  final DateTime? updatedAt;     // ISO

  final ChemistInfo? chemist;    // nested "Chemist"

  ChemistVisitModel({
    required this.id,
    required this.chemistId,
    required this.userId,
    required this.confirmed,
    this.dateStr,
    this.date,
    this.notes,
    this.latitudeStr,
    this.longitudeStr,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.chemist,
  });

  factory ChemistVisitModel.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return ChemistVisitModel(
        id: "",
        chemistId: "",
        userId: "",
        confirmed: false,
      );
    }

    String _s(dynamic v) => v?.toString() ?? "";
    String? _sn(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    DateTime? _iso(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

    DateTime? _ymd(String? raw) {
      if (raw == null) return null;
      try {
        // parse as UTC (true) then convert to local
        return DateFormat('yyyy-MM-dd').parse(raw, true).toLocal();
      } catch (_) {
        return null;
      }
    }

    double? _dbl(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final rawDate = _sn(j['date']);
    final latStr  = _sn(j['latitude']);
    final lngStr  = _sn(j['longitude']);

    return ChemistVisitModel(
      id: _s(j['id']).trim(),
      chemistId: _s(j['chemist_id']).trim(),
      userId: _s(j['user_id']).trim(),
      confirmed: (j['confirmed'] ?? false) == true,
      dateStr: rawDate,
      date: _ymd(rawDate),
      notes: _sn(j['notes']),
      latitudeStr: latStr,
      longitudeStr: lngStr,
      latitude: _dbl(latStr),
      longitude: _dbl(lngStr),
      createdAt: _iso(j['created_at']),
      updatedAt: _iso(j['updated_at']),
      // Some APIs may send "Chemist" or "chemist" — handle both
      chemist: (j['Chemist'] is Map)
          ? ChemistInfo.fromJson(j['Chemist'] as Map<String, dynamic>)
          : (j['chemist'] is Map)
          ? ChemistInfo.fromJson(j['chemist'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "chemist_id": chemistId,
    "user_id": userId,
    "date": dateStr, // keep original format
    "notes": notes,
    "confirmed": confirmed,
    "latitude": latitudeStr,   // keep original strings (server expects strings)
    "longitude": longitudeStr,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "Chemist": chemist?.toJson(),
  };

  // List helpers
  static List<ChemistVisitModel> listFromRawJson(String raw) {
    final data = json.decode(raw);
    if (data is List) {
      return data.map<ChemistVisitModel>((e) => ChemistVisitModel.fromJson(e as Map<String, dynamic>?)).toList();
    }
    return const <ChemistVisitModel>[];
  }

  static String listToRawJson(List<ChemistVisitModel> items) =>
      json.encode(items.map((e) => e.toJson()).toList());
}

class ChemistInfo {
  final String id;
  final String firmName;
  final String? contactPersonName;
  final String? designation;
  final String? mobileNo;
  final String? emailId;
  final String? drugLicenseNumber;
  final String? gstNo;
  final String? address;
  final String? latitudeStr;
  final String? longitudeStr;
  final double? latitude;
  final double? longitude;
  final int? yearsInBusiness;
  final String? headOfficeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChemistInfo({
    required this.id,
    required this.firmName,
    this.contactPersonName,
    this.designation,
    this.mobileNo,
    this.emailId,
    this.drugLicenseNumber,
    this.gstNo,
    this.address,
    this.latitudeStr,
    this.longitudeStr,
    this.latitude,
    this.longitude,
    this.yearsInBusiness,
    this.headOfficeId,
    this.createdAt,
    this.updatedAt,
  });

  factory ChemistInfo.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return ChemistInfo(id: "", firmName: "");
    }

    String _s(dynamic v) => v?.toString() ?? "";
    String? _sn(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }
    double? _dbl(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }
    int? _int(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }
    DateTime? _iso(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

    final latStr = _sn(j['latitude']);
    final lngStr = _sn(j['longitude']);

    return ChemistInfo(
      id: _s(j['id']).trim(),
      firmName: _s(j['firm_name']).trim(),
      contactPersonName: _sn(j['contact_person_name']),
      designation: _sn(j['designation']),
      mobileNo: _sn(j['mobile_no']),
      emailId: _sn(j['email_id']),
      drugLicenseNumber: _sn(j['drug_license_number']),
      gstNo: _sn(j['gst_no']),
      address: _sn(j['address']),
      latitudeStr: latStr,
      longitudeStr: lngStr,
      latitude: _dbl(latStr),
      longitude: _dbl(lngStr),
      yearsInBusiness: _int(j['years_in_business']),
      headOfficeId: _sn(j['head_office_id']),
      createdAt: _iso(j['created_at']),
      updatedAt: _iso(j['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "firm_name": firmName,
    "contact_person_name": contactPersonName,
    "designation": designation,
    "mobile_no": mobileNo,
    "email_id": emailId,
    "drug_license_number": drugLicenseNumber,
    "gst_no": gstNo,
    "address": address,
    "latitude": latitudeStr,   // keep original strings
    "longitude": longitudeStr,
    "years_in_business": yearsInBusiness,
    "head_office_id": headOfficeId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}



/*
class ChemistVisitModel {
  final String? id;
  final Chemist? chemist;
  final String user;
  final DateTime date;
  final String notes;
  final bool confirmed;
  final DateTime createdAt;

  ChemistVisitModel({
    this.id,
    this.chemist,
    required this.user,
    required this.date,
    required this.notes,
    required this.confirmed,
    required this.createdAt,
  });

  factory ChemistVisitModel.fromJson(Map<String, dynamic> json) {
    return ChemistVisitModel(
      id: json["_id"] ?? '', // Default empty string if null
      chemist: json["chemist"] != null ? Chemist.fromJson(json["chemist"]) : null,
      user: json["user"] ?? '', // Default empty string if null
      date: json["date"] != null ? DateTime.parse(json["date"]) : DateTime.now(), // Handle null date
      notes: json["notes"] ?? '', // Default empty string if null
      confirmed: json["confirmed"] ?? false, // Default false if null
      createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : DateTime.now(), // Handle null date
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "chemist": chemist?.toJson(),
      "user": user,
      "date": date.toIso8601String(),
      "notes": notes,
      "confirmed": confirmed,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}

class Chemist {
  final String id;
  final String firmName;
  final String contactPersonName;
  final String designation;
  final String mobileNo;
  final String emailId;
  final String drugLicenseNumber;
  final String gstNo;
  final String address;
  final double latitude;
  final double longitude;
  final int yearsInBusiness;
  final List<AnnualTurnover> annualTurnover;
  final String headOffice;
  final DateTime createdAt;

  Chemist({
    required this.id,
    required this.firmName,
    required this.contactPersonName,
    required this.designation,
    required this.mobileNo,
    required this.emailId,
    required this.drugLicenseNumber,
    required this.gstNo,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.yearsInBusiness,
    required this.annualTurnover,
    required this.headOffice,
    required this.createdAt,
  });

  factory Chemist.fromJson(Map<String, dynamic> json) {
    var turnoverList = (json["annualTurnover"] as List?)
        ?.map((item) => AnnualTurnover.fromJson(item))
        .toList() ?? [];

    return Chemist(
      id: json["_id"] ?? '',
      firmName: json["firmName"] ?? '',
      contactPersonName: json["contactPersonName"] ?? '',
      designation: json["designation"] ?? '',
      mobileNo: json["mobileNo"] ?? '',
      emailId: json["emailId"] ?? '',
      drugLicenseNumber: json["drugLicenseNumber"] ?? '',
      gstNo: json["gstNo"] ?? '',
      address: json["address"] ?? '',
      latitude: json["latitude"]?.toDouble() ?? 0.0,
      longitude: json["longitude"]?.toDouble() ?? 0.0,
      yearsInBusiness: json["yearsInBusiness"] ?? 0,
      annualTurnover: turnoverList,
      headOffice: json["headOffice"] ?? '',
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "firmName": firmName,
      "contactPersonName": contactPersonName,
      "designation": designation,
      "mobileNo": mobileNo,
      "emailId": emailId,
      "drugLicenseNumber": drugLicenseNumber,
      "gstNo": gstNo,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "yearsInBusiness": yearsInBusiness,
      "annualTurnover": annualTurnover.map((item) => item.toJson()).toList(),
      "headOffice": headOffice,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}

class AnnualTurnover {
  final int year;
  final double amount;
  final String? sId;

  AnnualTurnover({
    required this.year,
    required this.amount,
    this.sId,
  });

  factory AnnualTurnover.fromJson(Map<String, dynamic> json) {
    return AnnualTurnover(
      year: json["year"] ?? 0,
      amount: json["amount"]?.toDouble() ?? 0.0,
      sId: json["_id"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['year'] = this.year;
    data['amount'] = this.amount;
    data['_id'] = this.sId;
    return data;
  }
}

class Data {
  String? sId;
  Chemist? chemist;
  String? user;
  String? date;
  String? notes;
  bool? confirmed;
  String? createdAt;
  int? iV;

  Data({
    this.sId,
    this.chemist,
    this.user,
    this.date,
    this.notes,
    this.confirmed,
    this.createdAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] ?? '';
    chemist = json['chemist'] != null ? Chemist.fromJson(json['chemist']) : null;
    user = json['user'] ?? '';
    date = json['date'] ?? '';
    notes = json['notes'] ?? '';
    confirmed = json['confirmed'] ?? false;
    createdAt = json['createdAt'] ?? '';
    iV = json['__v'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    if (this.chemist != null) {
      data['chemist'] = this.chemist!.toJson();
    }
    data['user'] = this.user;
    data['date'] = this.date;
    data['notes'] = this.notes;
    data['confirmed'] = this.confirmed;
    data['createdAt'] = this.createdAt;
    data['__v'] = this.iV;
    return data;
  }
}
*/
