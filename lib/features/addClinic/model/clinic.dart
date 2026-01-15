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
  final String? geoImageUrl;
  final String headOfficeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HeadOffice headOffice;
  final List<AnnualTurnover> annualTurnover;
  final bool geoImageStatus;

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
    this.geoImageUrl,
    required this.headOfficeId,
    required this.createdAt,
    required this.updatedAt,
    required this.headOffice,
    required this.annualTurnover,
    required this.geoImageStatus,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id']?.toString() ?? '',
      firmName: json['firm_name']?.toString() ?? '',
      contactPersonName: json['contact_person_name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      emailId: json['email_id']?.toString() ?? '',
      drugLicenseNumber: json['drug_license_number']?.toString() ?? '',
      gstNo: json['gst_no']?.toString() ?? '',
      address: json['address']?.toString() ?? '',

      // Latitude/Longitude can be null or string, safe fallback to "0.0"
      latitude: json['latitude']?.toString() ?? '0.0',
      longitude: json['longitude']?.toString() ?? '0.0',

      // Safe int parsing
      yearsInBusiness: int.tryParse(json['years_in_business']?.toString() ?? '0') ?? 0,

      geoImageUrl: json['geo_image_url']?.toString(),
      headOfficeId: json['head_office_id']?.toString() ?? '',

      // Safe Date parsing
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),

      // Nested Objects
      headOffice: json['headOffice'] != null
          ? HeadOffice.fromJson(json['headOffice'])
          : HeadOffice(id: '', name: ''),

      // List Parsing
      annualTurnover: (json['annualTurnover'] as List<dynamic>?)
          ?.map((e) => AnnualTurnover.fromJson(e))
          .toList() ?? [],

      geoImageStatus: json['geo_image_status'] ?? false,
    );
  }
}

// --- Nested Models ---

class HeadOffice {
  final String id;
  final String name;

  HeadOffice({required this.id, required this.name});

  factory HeadOffice.fromJson(Map<String, dynamic> json) {
    return HeadOffice(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class AnnualTurnover {
  final int year;
  final double amount;

  AnnualTurnover({required this.year, required this.amount});

  factory AnnualTurnover.fromJson(Map<String, dynamic> json) {
    return AnnualTurnover(
      year: int.tryParse(json['year']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}