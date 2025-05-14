class Stockist {
  bool? success;
  String? message;
  List<Data>? data;

  Stockist({this.success, this.message, this.data});

  Stockist.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  BankDetails? bankDetails;
  String? sId;
  String? firmName;
  String? registeredBusinessName;
  String? natureOfBusiness;
  String? gstNumber;
  String? drugLicenseNumber;
  String? panNumber;
  String? registeredOfficeAddress;
  double? latitude;
  double? longitude;
  String? contactPerson;
  String? designation;
  String? mobileNumber;
  String? emailAddress;
  String? website;
  int? yearsInBusiness;
  List<String>? areasOfOperation;
  List<String>? currentPharmaDistributorships;
  List<AnnualTurnover>? annualTurnover;
  bool? warehouseFacility;
  int? storageFacilitySize;
  bool? coldStorageAvailable;
  int? numberOfSalesRepresentatives;
  HeadOffice? headOffice;
  String? createdAt;
  int? iV;

  Data(
      {this.bankDetails,
        this.sId,
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
        this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    bankDetails = json['bankDetails'] != null
        ? new BankDetails.fromJson(json['bankDetails'])
        : null;
    sId = json['_id'];
    firmName = json['firmName'];
    registeredBusinessName = json['registeredBusinessName'];
    natureOfBusiness = json['natureOfBusiness'];
    gstNumber = json['gstNumber'];
    drugLicenseNumber = json['drugLicenseNumber'];
    panNumber = json['panNumber'];
    registeredOfficeAddress = json['registeredOfficeAddress'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    contactPerson = json['contactPerson'];
    designation = json['designation'];
    mobileNumber = json['mobileNumber'];
    emailAddress = json['emailAddress'];
    website = json['website'];
    yearsInBusiness = json['yearsInBusiness'];
    areasOfOperation = json['areasOfOperation'].cast<String>();
    currentPharmaDistributorships =
        json['currentPharmaDistributorships'].cast<String>();
    if (json['annualTurnover'] != null) {
      annualTurnover = <AnnualTurnover>[];
      json['annualTurnover'].forEach((v) {
        annualTurnover!.add(new AnnualTurnover.fromJson(v));
      });
    }
    warehouseFacility = json['warehouseFacility'];
    storageFacilitySize = json['storageFacilitySize'];
    coldStorageAvailable = json['coldStorageAvailable'];
    numberOfSalesRepresentatives = json['numberOfSalesRepresentatives'];
    headOffice = json['headOffice'] != null
        ? new HeadOffice.fromJson(json['headOffice'])
        : null;
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.bankDetails != null) {
      data['bankDetails'] = this.bankDetails!.toJson();
    }
    data['_id'] = this.sId;
    data['firmName'] = this.firmName;
    data['registeredBusinessName'] = this.registeredBusinessName;
    data['natureOfBusiness'] = this.natureOfBusiness;
    data['gstNumber'] = this.gstNumber;
    data['drugLicenseNumber'] = this.drugLicenseNumber;
    data['panNumber'] = this.panNumber;
    data['registeredOfficeAddress'] = this.registeredOfficeAddress;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['contactPerson'] = this.contactPerson;
    data['designation'] = this.designation;
    data['mobileNumber'] = this.mobileNumber;
    data['emailAddress'] = this.emailAddress;
    data['website'] = this.website;
    data['yearsInBusiness'] = this.yearsInBusiness;
    data['areasOfOperation'] = this.areasOfOperation;
    data['currentPharmaDistributorships'] = this.currentPharmaDistributorships;
    if (this.annualTurnover != null) {
      data['annualTurnover'] =
          this.annualTurnover!.map((v) => v.toJson()).toList();
    }
    data['warehouseFacility'] = this.warehouseFacility;
    data['storageFacilitySize'] = this.storageFacilitySize;
    data['coldStorageAvailable'] = this.coldStorageAvailable;
    data['numberOfSalesRepresentatives'] = this.numberOfSalesRepresentatives;
    if (this.headOffice != null) {
      data['headOffice'] = this.headOffice!.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['__v'] = this.iV;
    return data;
  }
}

class BankDetails {
  String? bankName;
  String? branch;
  String? accountNumber;
  String? ifscCode;

  BankDetails({this.bankName, this.branch, this.accountNumber, this.ifscCode});

  BankDetails.fromJson(Map<String, dynamic> json) {
    bankName = json['bankName'];
    branch = json['branch'];
    accountNumber = json['accountNumber'];
    ifscCode = json['ifscCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bankName'] = this.bankName;
    data['branch'] = this.branch;
    data['accountNumber'] = this.accountNumber;
    data['ifscCode'] = this.ifscCode;
    return data;
  }
}

class AnnualTurnover {
  int? year;
  int? amount;
  String? sId;

  AnnualTurnover({this.year, this.amount, this.sId});

  AnnualTurnover.fromJson(Map<String, dynamic> json) {
    year = json['year'];
    amount = json['amount'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['year'] = this.year;
    data['amount'] = this.amount;
    data['_id'] = this.sId;
    return data;
  }
}

class HeadOffice {
  String? sId;
  String? name;
  String? createdAt;
  String? updatedAt;
  int? iV;

  HeadOffice({this.sId, this.name, this.createdAt, this.updatedAt, this.iV});

  HeadOffice.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}