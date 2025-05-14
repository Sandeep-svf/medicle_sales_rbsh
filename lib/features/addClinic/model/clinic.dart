class Clinic {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final DateTime createdAt;
  final String drugLicenseNumber;
  final String gstNo;
  final int yearsInBusiness;
  final double latitude;
  final double longitude;
  final HeadOffice headOffice;
  final List<AnnualTurnover> annualTurnover;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.createdAt,
    required this.drugLicenseNumber,
    required this.gstNo,
    required this.yearsInBusiness,
    required this.latitude,
    required this.longitude,
    required this.headOffice,
    required this.annualTurnover,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {

    double parseToDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Clinic(
      id: json['_id'] ?? '',
      name: json['firmName'] ?? '',
      address: json['address'] ?? '',
      phone: json['mobileNo'] ?? '',
      email: json['emailId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      drugLicenseNumber: json['drugLicenseNumber'] ?? '',
      gstNo: json['gstNo'] ?? '',
      yearsInBusiness: json['yearsInBusiness'] ?? 0,
      latitude: parseToDouble(json['latitude'])??0.0,
      longitude: parseToDouble(json['longitude']??0.0),
      headOffice: HeadOffice.fromJson(json['headOffice']),
      annualTurnover: (json['annualTurnover'] as List)
          .map((item) => AnnualTurnover.fromJson(item))
          .toList(),
    );
  }
}

class HeadOffice {
  final String id;
  final String name;

  HeadOffice({required this.id, required this.name});

  factory HeadOffice.fromJson(Map<String, dynamic> json) {
    return HeadOffice(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class AnnualTurnover {
  final int year;
  final double amount;

  AnnualTurnover({required this.year, required this.amount});

  factory AnnualTurnover.fromJson(Map<String, dynamic> json) {
    return AnnualTurnover(
      year: json['year'] ?? 0,
      amount: json['amount']?.toDouble() ?? 0.0,
    );
  }
}
