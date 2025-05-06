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
      id: json["_id"],
      chemist: json["chemist"] != null
          ? Chemist.fromJson(json["chemist"])
          : null,
      user: json["user"],
      date: DateTime.parse(json["date"]),
      notes: json["notes"],
      confirmed: json["confirmed"],
      createdAt: DateTime.parse(json["createdAt"]),
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
    var turnoverList = (json["annualTurnover"] as List)
        .map((item) => AnnualTurnover.fromJson(item))
        .toList();

    return Chemist(
      id: json["_id"],
      firmName: json["firmName"],
      contactPersonName: json["contactPersonName"],
      designation: json["designation"],
      mobileNo: json["mobileNo"],
      emailId: json["emailId"],
      drugLicenseNumber: json["drugLicenseNumber"],
      gstNo: json["gstNo"],
      address: json["address"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      yearsInBusiness: json["yearsInBusiness"],
      annualTurnover: turnoverList,
      headOffice: json["headOffice"],
      createdAt: DateTime.parse(json["createdAt"]),
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

  AnnualTurnover({
    required this.year,
    required this.amount,
  });

  factory AnnualTurnover.fromJson(Map<String, dynamic> json) {
    return AnnualTurnover(
      year: json["year"],
      amount: json["amount"]?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "year": year,
      "amount": amount,
    };
  }
}
