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
