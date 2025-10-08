class Clinic {
  final String id;
  final String firmName;
  final String contactPersonName;
  final String designation;
  final String mobileNo;
  final String emailId;
  final String drugLicenseNumber;
  final String gstNo;
  final String address;
  final String latitude;
  final String longitude;
  final int yearsInBusiness;
  final String headOfficeId;
  final String createdAt;
  final String updatedAt;
  final List<AnnualTurnover> annualTurnover;
  final HeadOffice? headOffice;

  Clinic({
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
    required this.headOfficeId,
    required this.createdAt,
    required this.updatedAt,
    required this.annualTurnover,
    this.headOffice,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] ?? '',
      firmName: json['firm_name'] ?? '',
      contactPersonName: json['contact_person_name'] ?? '',
      designation: json['designation'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      emailId: json['email_id'] ?? '',
      drugLicenseNumber: json['drug_license_number'] ?? '',
      gstNo: json['gst_no'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      yearsInBusiness: json['years_in_business'] ?? 0,
      headOfficeId: json['head_office_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      annualTurnover: (json['annualTurnover'] as List<dynamic>?)
          ?.map((e) => AnnualTurnover.fromJson(e))
          .toList() ??
          [],
      headOffice: json['headOffice'] != null
          ? HeadOffice.fromJson(json['headOffice'])
          : null,
    );
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
      year: json['year'] ?? 0,
      amount: json['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year ?? 0,
      'amount': amount ?? 0,
    };
  }
}

class HeadOffice {
  final String? id;
  final String? name;

  HeadOffice({
    this.id,
    this.name,
  });

  factory HeadOffice.fromJson(Map<String, dynamic> json) {
    return HeadOffice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '',
      'name': name ?? '',
    };
  }
}
