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
      id: json['_id'] as String?,
      stockist: json['stockist'] != null
          ? Stockist.fromJson(json['stockist'] as Map<String, dynamic>)
          : null,
      user: json['user'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      notes: json['notes'] as String?,
      confirmed: json['confirmed'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
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
      id: json['_id'] as String?,
      firmName: json['firmName'] as String?,
      registeredBusinessName: json['registeredBusinessName'] as String?,
      natureOfBusiness: json['natureOfBusiness'] as String?,
      gstNumber: json['gstNumber'] as String?,
      drugLicenseNumber: json['drugLicenseNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      registeredOfficeAddress: json['registeredOfficeAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactPerson: json['contactPerson'] as String?,
      designation: json['designation'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      emailAddress: json['emailAddress'] as String?,
      website: json['website'] as String?,
      yearsInBusiness: json['yearsInBusiness'] as int?,
      areasOfOperation: (json['areasOfOperation'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      currentPharmaDistributorships:
      (json['currentPharmaDistributorships'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      annualTurnover: (json['annualTurnover'] as List<dynamic>?)
          ?.map((e) => AnnualTurnover.fromJson(e as Map<String, dynamic>))
          .toList(),
      warehouseFacility: json['warehouseFacility'] as bool?,
      storageFacilitySize: json['storageFacilitySize'] as int?,
      coldStorageAvailable: json['coldStorageAvailable'] as bool?,
      numberOfSalesRepresentatives:
      json['numberOfSalesRepresentatives'] as int?,
      headOffice: json['headOffice'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
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
      year: json['year'] as int?,
      amount: json['amount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'amount': amount,
    };
  }
}
