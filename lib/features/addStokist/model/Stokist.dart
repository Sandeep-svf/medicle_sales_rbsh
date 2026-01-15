// new code
// stockist_model.dart

import 'dart:convert';

StockistResponse stockistResponseFromJson(String str) =>
    StockistResponse.fromJson(json.decode(str));

String stockistResponseToJson(StockistResponse data) =>
    json.encode(data.toJson());

class StockistResponse {
  final bool success;
  final int count;
  final List<Stockist> data;

  StockistResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory StockistResponse.fromJson(Map<String, dynamic> json) =>
      StockistResponse(
        success: json["success"] ?? false,
        count: json["count"] ?? 0,
        data: json["data"] == null
            ? []
            : List<Stockist>.from(
            json["data"].map((x) => Stockist.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Stockist {
  final String id;
  final String firmName;
  final String registeredBusinessName;
  final String natureOfBusiness;
  final String? gstNumber;
  final String? drugLicenseNumber;
  final String? panNumber;
  final String registeredOfficeAddress;
  final String? latitude;
  final String? longitude;
  final String contactPerson;
  final String? designation;
  final String? mobileNumber;
  final String? emailAddress;
  final String? website;
  final int yearsInBusiness;
  final List<String> areasOfOperation;
  final List<String> currentPharmaDistributorships;
  final bool warehouseFacility;
  final int? storageFacilitySize;
  final bool coldStorageAvailable;
  final int? numberOfSalesRepresentatives;
  final BankDetails? bankDetails;
  final String? geoImageUrl;
  final String headOfficeId;
  final String? gstCertificateUrl;
  final String? drugLicenseUrl;
  final String? panCardUrl;
  final String? cancelledChequeUrl;
  final String? businessProfileUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AnnualTurnover> annualTurnover;
  final HeadOffice? headOffice;
  final String internalId; // Mapping for "_id"
  final bool geoImageStatus;

  Stockist({
    required this.id,
    required this.firmName,
    required this.registeredBusinessName,
    required this.natureOfBusiness,
    this.gstNumber,
    this.drugLicenseNumber,
    this.panNumber,
    required this.registeredOfficeAddress,
    this.latitude,
    this.longitude,
    required this.contactPerson,
    this.designation,
    this.mobileNumber,
    this.emailAddress,
    this.website,
    required this.yearsInBusiness,
    required this.areasOfOperation,
    required this.currentPharmaDistributorships,
    required this.warehouseFacility,
    this.storageFacilitySize,
    required this.coldStorageAvailable,
    this.numberOfSalesRepresentatives,
    this.bankDetails,
    this.geoImageUrl,
    required this.headOfficeId,
    this.gstCertificateUrl,
    this.drugLicenseUrl,
    this.panCardUrl,
    this.cancelledChequeUrl,
    this.businessProfileUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.annualTurnover,
    this.headOffice,
    required this.internalId,
    required this.geoImageStatus,
  });

  factory Stockist.fromJson(Map<String, dynamic> json) => Stockist(
    id: json["id"] ?? "",
    firmName: json["firm_name"] ?? "",
    registeredBusinessName: json["registered_business_name"] ?? "",
    natureOfBusiness: json["nature_of_business"] ?? "",
    gstNumber: json["gst_number"],
    drugLicenseNumber: json["drug_license_number"],
    panNumber: json["pan_number"],
    registeredOfficeAddress: json["registered_office_address"] ?? "",
    latitude: json["latitude"],
    longitude: json["longitude"],
    contactPerson: json["contact_person"] ?? "",
    designation: json["designation"],
    mobileNumber: json["mobile_number"],
    emailAddress: json["email_address"],
    website: json["website"],
    yearsInBusiness: json["years_in_business"] ?? 0,
    areasOfOperation: json["areas_of_operation"] == null
        ? []
        : List<String>.from(json["areas_of_operation"].map((x) => x)),
    currentPharmaDistributorships:
    json["current_pharma_distributorships"] == null
        ? []
        : List<String>.from(
        json["current_pharma_distributorships"].map((x) => x)),
    warehouseFacility: json["warehouse_facility"] ?? false,
    storageFacilitySize: json["storage_facility_size"],
    coldStorageAvailable: json["cold_storage_available"] ?? false,
    numberOfSalesRepresentatives: json["number_of_sales_representatives"],
    bankDetails: json["bank_details"] == null ||
        (json["bank_details"] is Map && json["bank_details"].isEmpty)
        ? null
        : BankDetails.fromJson(json["bank_details"]),
    geoImageUrl: json["geo_image_url"],
    headOfficeId: json["head_office_id"] ?? "",
    gstCertificateUrl: json["gst_certificate_url"],
    drugLicenseUrl: json["drug_license_url"],
    panCardUrl: json["pan_card_url"],
    cancelledChequeUrl: json["cancelled_cheque_url"],
    businessProfileUrl: json["business_profile_url"],
    createdAt: json["created_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? DateTime.now()
        : DateTime.parse(json["updated_at"]),
    annualTurnover: json["annual_turnover"] == null
        ? []
        : List<AnnualTurnover>.from(
        json["annual_turnover"].map((x) => AnnualTurnover.fromJson(x))),
    headOffice: json["headOffice"] == null
        ? null
        : HeadOffice.fromJson(json["headOffice"]),
    internalId: json["_id"] ?? "",
    geoImageStatus: json["geo_image_status"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firm_name": firmName,
    "registered_business_name": registeredBusinessName,
    "nature_of_business": natureOfBusiness,
    "gst_number": gstNumber,
    "drug_license_number": drugLicenseNumber,
    "pan_number": panNumber,
    "registered_office_address": registeredOfficeAddress,
    "latitude": latitude,
    "longitude": longitude,
    "contact_person": contactPerson,
    "designation": designation,
    "mobile_number": mobileNumber,
    "email_address": emailAddress,
    "website": website,
    "years_in_business": yearsInBusiness,
    "areas_of_operation":
    List<dynamic>.from(areasOfOperation.map((x) => x)),
    "current_pharma_distributorships":
    List<dynamic>.from(currentPharmaDistributorships.map((x) => x)),
    "warehouse_facility": warehouseFacility,
    "storage_facility_size": storageFacilitySize,
    "cold_storage_available": coldStorageAvailable,
    "number_of_sales_representatives": numberOfSalesRepresentatives,
    "bank_details": bankDetails?.toJson(),
    "geo_image_url": geoImageUrl,
    "head_office_id": headOfficeId,
    "gst_certificate_url": gstCertificateUrl,
    "drug_license_url": drugLicenseUrl,
    "pan_card_url": panCardUrl,
    "cancelled_cheque_url": cancelledChequeUrl,
    "business_profile_url": businessProfileUrl,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "annual_turnover":
    List<dynamic>.from(annualTurnover.map((x) => x.toJson())),
    "headOffice": headOffice?.toJson(),
    "_id": internalId,
    "geo_image_status": geoImageStatus,
  };
}

class AnnualTurnover {
  final int year;
  final int amount;

  AnnualTurnover({
    required this.year,
    required this.amount,
  });

  factory AnnualTurnover.fromJson(Map<String, dynamic> json) => AnnualTurnover(
    year: json["year"] ?? 0,
    amount: json["amount"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "year": year,
    "amount": amount,
  };
}

class BankDetails {
  final String? branch;
  final String? bankName; // Handles both 'bankName' and 'bank_name'
  final String? ifscCode; // Handles both 'ifscCode' and 'ifsc' and 'ifsc_code'
  final String? accountNumber; // Handles 'accountNumber' and 'account_number'
  final String? accountHolderName; // Handles 'account_holder_name'

  BankDetails({
    this.branch,
    this.bankName,
    this.ifscCode,
    this.accountNumber,
    this.accountHolderName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
    branch: json["branch"],
    // The JSON has mixed casing for bank keys, so we check multiple possibilities
    bankName: json["bankName"] ?? json["bank_name"],
    ifscCode: json["ifscCode"] ?? json["ifsc"] ?? json["ifsc_code"],
    accountNumber: json["accountNumber"] ?? json["account_number"],
    accountHolderName: json["account_holder_name"],
  );

  Map<String, dynamic> toJson() => {
    "branch": branch,
    "bankName": bankName,
    "ifscCode": ifscCode,
    "accountNumber": accountNumber,
    "account_holder_name": accountHolderName,
  };
}

class HeadOffice {
  final String id;
  final String name;

  HeadOffice({
    required this.id,
    required this.name,
  });

  factory HeadOffice.fromJson(Map<String, dynamic> json) => HeadOffice(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

//old code
/*
class StockistResponse {
  final bool success;
  final int count;
  final List<Stockist> data;

  StockistResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory StockistResponse.fromJson(Map<String, dynamic> json) {
    return StockistResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Stockist.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'count': count,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class Stockist {
  final String id;
  final String firmName;
  final String registeredBusinessName;
  final String natureOfBusiness;
  final String gstNumber;
  final String drugLicenseNumber;
  final String panNumber;
  final String registeredOfficeAddress;
  final String latitude;
  final String longitude;
  final String contactPerson;
  final String designation;
  final String mobileNumber;
  final String emailAddress;
  final String website;
  final int yearsInBusiness;
  final List<String> areasOfOperation;
  final List<String> currentPharmaDistributorships;
  final bool warehouseFacility;
  final int storageFacilitySize;
  final bool coldStorageAvailable;
  final int numberOfSalesRepresentatives;
  final BankDetails? bankDetails;
  final String headOfficeId;
  final String createdAt;
  final String updatedAt;
  final List<AnnualTurnover> annualTurnover;
  final HeadOffice? headOffice;

  Stockist({
    required this.id,
    required this.firmName,
    required this.registeredBusinessName,
    required this.natureOfBusiness,
    required this.gstNumber,
    required this.drugLicenseNumber,
    required this.panNumber,
    required this.registeredOfficeAddress,
    required this.latitude,
    required this.longitude,
    required this.contactPerson,
    required this.designation,
    required this.mobileNumber,
    required this.emailAddress,
    required this.website,
    required this.yearsInBusiness,
    required this.areasOfOperation,
    required this.currentPharmaDistributorships,
    required this.warehouseFacility,
    required this.storageFacilitySize,
    required this.coldStorageAvailable,
    required this.numberOfSalesRepresentatives,
    this.bankDetails,
    required this.headOfficeId,
    required this.createdAt,
    required this.updatedAt,
    required this.annualTurnover,
    this.headOffice,
  });

  factory Stockist.fromJson(Map<String, dynamic> json) {
    return Stockist(
      id: json['id'] ?? '',
      firmName: json['firm_name'] ?? '',
      registeredBusinessName: json['registered_business_name'] ?? '',
      natureOfBusiness: json['nature_of_business'] ?? '',
      gstNumber: json['gst_number'] ?? '',
      drugLicenseNumber: json['drug_license_number'] ?? '',
      panNumber: json['pan_number'] ?? '',
      registeredOfficeAddress: json['registered_office_address'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      designation: json['designation'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      emailAddress: json['email_address'] ?? '',
      website: json['website'] ?? '',
      yearsInBusiness: json['years_in_business'] ?? 0,
      areasOfOperation: (json['areas_of_operation'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      currentPharmaDistributorships:
      (json['current_pharma_distributorships'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      warehouseFacility: json['warehouse_facility'] ?? false,
      storageFacilitySize: json['storage_facility_size'] ?? 0,
      coldStorageAvailable: json['cold_storage_available'] ?? false,
      numberOfSalesRepresentatives:
      json['number_of_sales_representatives'] ?? 0,
      bankDetails: json['bank_details'] != null &&
          (json['bank_details'] as Map<String, dynamic>).isNotEmpty
          ? BankDetails.fromJson(json['bank_details'])
          : null,
      headOfficeId: json['head_office_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      annualTurnover: (json['annual_turnover'] as List<dynamic>?)
          ?.map((e) => AnnualTurnover.fromJson(e))
          .toList() ??
          [],
      headOffice: json['headOffice'] != null
          ? HeadOffice.fromJson(json['headOffice'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firm_name': firmName,
    'registered_business_name': registeredBusinessName,
    'nature_of_business': natureOfBusiness,
    'gst_number': gstNumber,
    'drug_license_number': drugLicenseNumber,
    'pan_number': panNumber,
    'registered_office_address': registeredOfficeAddress,
    'latitude': latitude,
    'longitude': longitude,
    'contact_person': contactPerson,
    'designation': designation,
    'mobile_number': mobileNumber,
    'email_address': emailAddress,
    'website': website,
    'years_in_business': yearsInBusiness,
    'areas_of_operation': areasOfOperation,
    'current_pharma_distributorships': currentPharmaDistributorships,
    'warehouse_facility': warehouseFacility,
    'storage_facility_size': storageFacilitySize,
    'cold_storage_available': coldStorageAvailable,
    'number_of_sales_representatives': numberOfSalesRepresentatives,
    'bank_details': bankDetails?.toJson(),
    'head_office_id': headOfficeId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'annual_turnover': annualTurnover.map((e) => e.toJson()).toList(),
    'headOffice': headOffice?.toJson(),
  };
}

class AnnualTurnover {
  final int year;
  final int amount;

  AnnualTurnover({required this.year, required this.amount});

  factory AnnualTurnover.fromJson(Map<String, dynamic> json) {
    return AnnualTurnover(
      year: json['year'] ?? 0,
      amount: json['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'year': year,
    'amount': amount,
  };
}

class HeadOffice {
  final String id;
  final String name;

  HeadOffice({required this.id, required this.name});

  factory HeadOffice.fromJson(Map<String, dynamic> json) {
    return HeadOffice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class BankDetails {
  final String bankName;
  final String branch;
  final String ifscCode;
  final String accountNumber;

  BankDetails({
    required this.bankName,
    required this.branch,
    required this.ifscCode,
    required this.accountNumber,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bankName'] ?? json['bank_name'] ?? '',
      branch: json['branch'] ?? '',
      ifscCode: json['ifscCode'] ?? json['ifsc'] ?? '',
      accountNumber: json['accountNumber'] ?? json['account_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'bank_name': bankName,
    'branch': branch,
    'ifsc': ifscCode,
    'account_number': accountNumber,
  };
}
*/
