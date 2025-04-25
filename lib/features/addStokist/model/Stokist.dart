// Turnover Model
class Turnover {
  final int year;
  final int amount;

  Turnover({required this.year, required this.amount});

  factory Turnover.fromJson(Map<String, dynamic> json) => Turnover(
    year: json['year'] ?? 0,
    amount: json['amount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "year": year,
    "amount": amount,
  };
}

// BankDetails Model
class BankDetails {
  final String bankName;
  final String branch;
  final String accountNumber;
  final String ifscCode;

  BankDetails({
    required this.bankName,
    required this.branch,
    required this.accountNumber,
    required this.ifscCode,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
    bankName: json['bankName'] ?? '',
    branch: json['branch'] ?? '',
    accountNumber: json['accountNumber'] ?? '',
    ifscCode: json['ifscCode'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "bankName": bankName,
    "branch": branch,
    "accountNumber": accountNumber,
    "ifscCode": ifscCode,
  };
}

// Stokist Model
class Stokist {
  final String firmName;
  final String registeredBusinessName;
  final String natureOfBusiness;
  final String gstNumber;
  final String drugLicenseNumber;
  final String panNumber;
  final String registeredOfficeAddress;
  final String contactPerson;
  final String designation;
  final String mobileNumber;
  final String emailAddress;
  final String website;
  final int yearsInBusiness;
  final List<String> areasOfOperation;
  final List<String> currentPharmaDistributorships;
  final List<Turnover> annualTurnover;
  final bool warehouseFacility;
  final int storageFacilitySize;
  final bool coldStorageAvailable;
  final int numberOfSalesRepresentatives;
  final BankDetails bankDetails;
  final DateTime createdAt;

  Stokist({
    required this.firmName,
    required this.registeredBusinessName,
    required this.natureOfBusiness,
    required this.gstNumber,
    required this.drugLicenseNumber,
    required this.panNumber,
    required this.registeredOfficeAddress,
    required this.contactPerson,
    required this.designation,
    required this.mobileNumber,
    required this.emailAddress,
    required this.website,
    required this.yearsInBusiness,
    required this.areasOfOperation,
    required this.currentPharmaDistributorships,
    required this.annualTurnover,
    required this.warehouseFacility,
    required this.storageFacilitySize,
    required this.coldStorageAvailable,
    required this.numberOfSalesRepresentatives,
    required this.bankDetails,
    required this.createdAt,
  });

  factory Stokist.fromJson(Map<String, dynamic> json) => Stokist(
    firmName: json['firmName'] ?? '',
    registeredBusinessName: json['registeredBusinessName'] ?? '',
    natureOfBusiness: json['natureOfBusiness'] ?? '',
    gstNumber: json['gstNumber'] ?? '',
    drugLicenseNumber: json['drugLicenseNumber'] ?? '',
    panNumber: json['panNumber'] ?? '',
    registeredOfficeAddress: json['registeredOfficeAddress'] ?? '',
    contactPerson: json['contactPerson'] ?? '',
    designation: json['designation'] ?? '',
    mobileNumber: json['mobileNumber'] ?? '',
    emailAddress: json['emailAddress'] ?? '',
    website: json['website'] ?? '',
    yearsInBusiness: json['yearsInBusiness'] ?? 0,
    areasOfOperation: List<String>.from(json['areasOfOperation'] ?? []),
    currentPharmaDistributorships: List<String>.from(json['currentPharmaDistributorships'] ?? []),
    annualTurnover: (json['annualTurnover'] as List<dynamic>? ?? [])
        .map((e) => Turnover.fromJson(e))
        .toList(),
    warehouseFacility: json['warehouseFacility'] ?? false,
    storageFacilitySize: json['storageFacilitySize'] ?? 0,
    coldStorageAvailable: json['coldStorageAvailable'] ?? false,
    numberOfSalesRepresentatives: json['numberOfSalesRepresentatives'] ?? 0,
    bankDetails: BankDetails.fromJson(json['bankDetails'] ?? {}),
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}
