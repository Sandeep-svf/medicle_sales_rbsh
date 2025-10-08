import 'dart:convert';
import 'package:intl/intl.dart';

class StockistVisit {
  final String id;
  final String stockistId;
  final String userId;

  // Server date as string + parsed
  final String? dateStr;     // e.g., "2025-04-25"
  final DateTime? date;

  final String? notes;
  final bool confirmed;

  // lat/lng can be null or string/number; keep raw + parsed
  final String? latitudeStr;
  final String? longitudeStr;
  final double? latitude;
  final double? longitude;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final StockistInfo? stockist; // nested "Stockist"

  StockistVisit({
    required this.id,
    required this.stockistId,
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
    this.stockist,
  });

  factory StockistVisit.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return StockistVisit(
        id: "",
        stockistId: "",
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
      try { return DateFormat('yyyy-MM-dd').parse(raw, true).toLocal(); } catch (_) { return null; }
    }
    double? _dbl(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final rawDate = _sn(j['date']);
    final latStr  = _sn(j['latitude']);
    final lngStr  = _sn(j['longitude']);

    return StockistVisit(
      id: _s(j['id']).trim(),
      stockistId: _s(j['stockist_id']).trim(),
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
      stockist: (j['Stockist'] is Map)
          ? StockistInfo.fromJson(j['Stockist'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "stockist_id": stockistId,
    "user_id": userId,
    "date": dateStr,                 // keep server format
    "notes": notes,
    "confirmed": confirmed,
    "latitude": latitudeStr,         // keep original strings
    "longitude": longitudeStr,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "Stockist": stockist?.toJson(),
  };

  // Helpers for list encode/decode
  static List<StockistVisit> listFromRawJson(String raw) {
    final decoded = json.decode(raw);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((m) => StockistVisit.fromJson(m))
          .toList(growable: false);
    }
    return const <StockistVisit>[];
  }

  static String listToRawJson(List<StockistVisit> items) =>
      json.encode(items.map((e) => e.toJson()).toList());
}

class StockistInfo {
  final String id;
  final String firmName;
  final String? registeredBusinessName;
  final String? natureOfBusiness;
  final String? gstNumber;
  final String? drugLicenseNumber;
  final String? panNumber;
  final String? registeredOfficeAddress;

  final String? latitudeStr;
  final String? longitudeStr;
  final double? latitude;
  final double? longitude;

  final String? contactPerson;
  final String? designation;
  final String? mobileNumber;
  final String? emailAddress;
  final String? website;

  final int? yearsInBusiness;
  final List<String> areasOfOperation;
  final List<String> currentPharmaDistributorships;

  final bool warehouseFacility;
  final int? storageFacilitySize;
  final bool coldStorageAvailable;
  final int? numberOfSalesRepresentatives;

  final BankDetails? bankDetails;

  final String? headOfficeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StockistInfo({
    required this.id,
    required this.firmName,
    this.registeredBusinessName,
    this.natureOfBusiness,
    this.gstNumber,
    this.drugLicenseNumber,
    this.panNumber,
    this.registeredOfficeAddress,
    this.latitudeStr,
    this.longitudeStr,
    this.latitude,
    this.longitude,
    this.contactPerson,
    this.designation,
    this.mobileNumber,
    this.emailAddress,
    this.website,
    this.yearsInBusiness,
    this.areasOfOperation = const [],
    this.currentPharmaDistributorships = const [],
    this.warehouseFacility = false,
    this.storageFacilitySize,
    this.coldStorageAvailable = false,
    this.numberOfSalesRepresentatives,
    this.bankDetails,
    this.headOfficeId,
    this.createdAt,
    this.updatedAt,
  });

  factory StockistInfo.fromJson(Map<String, dynamic>? j) {
    if (j == null) return StockistInfo(id: "", firmName: "");

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
    bool _bool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return false;
    }
    DateTime? _iso(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

    List<String> _strList(dynamic v) {
      if (v is List) return v.map((e) => e?.toString() ?? "").where((s) => s.isNotEmpty).toList();
      return const <String>[];
    }

    final latStr = _sn(j['latitude']);
    final lngStr = _sn(j['longitude']);

    return StockistInfo(
      id: _s(j['id']).trim(),
      firmName: _s(j['firm_name']).trim(),
      registeredBusinessName: _sn(j['registered_business_name']),
      natureOfBusiness: _sn(j['nature_of_business']),
      gstNumber: _sn(j['gst_number']),
      drugLicenseNumber: _sn(j['drug_license_number']),
      panNumber: _sn(j['pan_number']),
      registeredOfficeAddress: _sn(j['registered_office_address']),
      latitudeStr: latStr,
      longitudeStr: lngStr,
      latitude: _dbl(latStr),
      longitude: _dbl(lngStr),
      contactPerson: _sn(j['contact_person']),
      designation: _sn(j['designation']),
      mobileNumber: _sn(j['mobile_number']),
      emailAddress: _sn(j['email_address']),
      website: _sn(j['website']),
      yearsInBusiness: _int(j['years_in_business']),
      areasOfOperation: _strList(j['areas_of_operation']),
      currentPharmaDistributorships: _strList(j['current_pharma_distributorships']),
      warehouseFacility: _bool(j['warehouse_facility']),
      storageFacilitySize: _int(j['storage_facility_size']),
      coldStorageAvailable: _bool(j['cold_storage_available']),
      numberOfSalesRepresentatives: _int(j['number_of_sales_representatives']),
      bankDetails: (j['bank_details'] is Map)
          ? BankDetails.fromJson(j['bank_details'] as Map<String, dynamic>)
          : null,
      headOfficeId: _sn(j['head_office_id']),
      createdAt: _iso(j['created_at']),
      updatedAt: _iso(j['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "firm_name": firmName,
    "registered_business_name": registeredBusinessName,
    "nature_of_business": natureOfBusiness,
    "gst_number": gstNumber,
    "drug_license_number": drugLicenseNumber,
    "pan_number": panNumber,
    "registered_office_address": registeredOfficeAddress,
    "latitude": latitudeStr,     // keep original strings
    "longitude": longitudeStr,
    "contact_person": contactPerson,
    "designation": designation,
    "mobile_number": mobileNumber,
    "email_address": emailAddress,
    "website": website,
    "years_in_business": yearsInBusiness,
    "areas_of_operation": areasOfOperation,
    "current_pharma_distributorships": currentPharmaDistributorships,
    "warehouse_facility": warehouseFacility,
    "storage_facility_size": storageFacilitySize,
    "cold_storage_available": coldStorageAvailable,
    "number_of_sales_representatives": numberOfSalesRepresentatives,
    "bank_details": bankDetails?.toJson(),
    "head_office_id": headOfficeId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class BankDetails {
  final String? branch;
  final String? bankName;
  final String? ifscCode;
  final String? accountNumber;

  BankDetails({
    this.branch,
    this.bankName,
    this.ifscCode,
    this.accountNumber,
  });

  factory BankDetails.fromJson(Map<String, dynamic>? j) {
    if (j == null) return BankDetails();
    String? _sn(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }
    return BankDetails(
      branch: _sn(j['branch']),
      bankName: _sn(j['bankName']),
      ifscCode: _sn(j['ifscCode']),
      accountNumber: _sn(j['accountNumber']),
    );
  }

  Map<String, dynamic> toJson() => {
    "branch": branch,
    "bankName": bankName,
    "ifscCode": ifscCode,
    "accountNumber": accountNumber,
  };
}





/*
import 'dart:convert';

class StockistVisit {
  final String? id;
  final Stockist? stockist;
  final String? user;
  final DateTime? date;
  final String? notes;
  final bool? confirmed;
  final DateTime? createdAt;

  StockistVisit({
    this.id,
    this.stockist,
    this.user,
    this.date,
    this.notes,
    this.confirmed,
    this.createdAt,
  });

  factory StockistVisit.fromJson(Map<String, dynamic> json) {
    return StockistVisit(
      id: json['_id'],
      stockist: json['stockist'] != null
          ? Stockist.fromJson(json['stockist'])
          : null,
      user: json['user'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      notes: json['notes'],
      confirmed: json['confirmed'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'stockist': stockist?.toJson(),
      'user': user,
      'date': date?.toIso8601String(),
      'notes': notes,
      'confirmed': confirmed,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class Stockist {
  final String? id;
  final String? firmName;
  final String? registeredBusinessName;
  final String? natureOfBusiness;
  final String? gstNumber;
  final String? drugLicenseNumber;
  final String? panNumber;
  final String? registeredOfficeAddress;
  final double? latitude;
  final double? longitude;
  final String? contactPerson;
  final String? designation;
  final String? mobileNumber;
  final String? emailAddress;
  final String? website;
  final int? yearsInBusiness;
  final List<String>? areasOfOperation;
  final List<String>? currentPharmaDistributorships;
  final List<AnnualTurnover>? annualTurnover;
  final bool? warehouseFacility;
  final int? storageFacilitySize;
  final bool? coldStorageAvailable;
  final int? numberOfSalesRepresentatives;
  final String? headOffice;
  final DateTime? createdAt;

  Stockist({
    this.id,
    this.firmName,
    this.registeredBusinessName,
    this.natureOfBusiness,
    this.gstNumber,
    this.drugLicenseNumber,
    this.panNumber,
    this.registeredOfficeAddress,
    this.latitude,
    this.longitude,
    this.contactPerson,
    this.designation,
    this.mobileNumber,
    this.emailAddress,
    this.website,
    this.yearsInBusiness,
    this.areasOfOperation,
    this.currentPharmaDistributorships,
    this.annualTurnover,
    this.warehouseFacility,
    this.storageFacilitySize,
    this.coldStorageAvailable,
    this.numberOfSalesRepresentatives,
    this.headOffice,
    this.createdAt,
  });

  factory Stockist.fromJson(Map<String, dynamic> json) {
    return Stockist(
      id: json['_id'],
      firmName: json['firmName'],
      registeredBusinessName: json['registeredBusinessName'],
      natureOfBusiness: json['natureOfBusiness'],
      gstNumber: json['gstNumber'],
      drugLicenseNumber: json['drugLicenseNumber'],
      panNumber: json['panNumber'],
      registeredOfficeAddress: json['registeredOfficeAddress'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactPerson: json['contactPerson'],
      designation: json['designation'],
      mobileNumber: json['mobileNumber'],
      emailAddress: json['emailAddress'],
      website: json['website'],
      yearsInBusiness: json['yearsInBusiness'],
      areasOfOperation: (json['areasOfOperation'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      currentPharmaDistributorships:
      (json['currentPharmaDistributorships'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      annualTurnover: (json['annualTurnover'] as List<dynamic>?)
          ?.map((e) => AnnualTurnover.fromJson(e))
          .toList(),
      warehouseFacility: json['warehouseFacility'],
      storageFacilitySize: json['storageFacilitySize'],
      coldStorageAvailable: json['coldStorageAvailable'],
      numberOfSalesRepresentatives: json['numberOfSalesRepresentatives'],
      headOffice: json['headOffice'],
      createdAt:
      json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firmName': firmName,
      'registeredBusinessName': registeredBusinessName,
      'natureOfBusiness': natureOfBusiness,
      'gstNumber': gstNumber,
      'drugLicenseNumber': drugLicenseNumber,
      'panNumber': panNumber,
      'registeredOfficeAddress': registeredOfficeAddress,
      'latitude': latitude,
      'longitude': longitude,
      'contactPerson': contactPerson,
      'designation': designation,
      'mobileNumber': mobileNumber,
      'emailAddress': emailAddress,
      'website': website,
      'yearsInBusiness': yearsInBusiness,
      'areasOfOperation': areasOfOperation,
      'currentPharmaDistributorships': currentPharmaDistributorships,
      'annualTurnover': annualTurnover?.map((e) => e.toJson()).toList(),
      'warehouseFacility': warehouseFacility,
      'storageFacilitySize': storageFacilitySize,
      'coldStorageAvailable': coldStorageAvailable,
      'numberOfSalesRepresentatives': numberOfSalesRepresentatives,
      'headOffice': headOffice,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class AnnualTurnover {
  final int? year;
  final int? amount;

  AnnualTurnover({
    this.year,
    this.amount,
  });

  factory AnnualTurnover.fromJson(Map<String, dynamic> json) {
    return AnnualTurnover(
      year: json['year'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'amount': amount,
    };
  }
}
*/
