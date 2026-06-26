class DoctorDetailsResponse {
  bool? success;
  DoctorDetailsModel? data;

  DoctorDetailsResponse({
    this.success,
    this.data,
  });

  factory DoctorDetailsResponse.fromJson(Map<String, dynamic> json) {
    return DoctorDetailsResponse(
      success: json["success"],
      data: json["data"] == null
          ? null
          : DoctorDetailsModel.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data?.toJson(),
    };
  }
}

class DoctorDetailsModel {
  String? id;
  String? name;
  String? specialization;

  String? clinicName;
  String? clinicAddress;

  String? location;
  String? latitude;
  String? longitude;

  String? email;
  String? phone;

  String? registrationNumber;

  int? yearsOfExperience;

  DateTime? dateOfBirth;

  String? qualification;

  double? consultationFee;

  String? availableTimings;

  String? geoImageUrl;

  String? gender;

  DateTime? anniversary;

  String? priority;

  bool? geoImageStatus;

  bool? isAssignedToArea;

  DateTime? createdAt;
  DateTime? updatedAt;

  HeadOffice? headOffice;
  Area? area;

  List<VisitHistory>? visitHistory;

  DoctorDetailsModel({
    this.id,
    this.name,
    this.specialization,
    this.clinicName,
    this.clinicAddress,
    this.location,
    this.latitude,
    this.longitude,
    this.email,
    this.phone,
    this.registrationNumber,
    this.yearsOfExperience,
    this.dateOfBirth,
    this.qualification,
    this.consultationFee,
    this.availableTimings,
    this.geoImageUrl,
    this.gender,
    this.anniversary,
    this.priority,
    this.geoImageStatus,
    this.isAssignedToArea,
    this.createdAt,
    this.updatedAt,
    this.headOffice,
    this.area,
    this.visitHistory,
  });

  factory DoctorDetailsModel.fromJson(Map<String, dynamic> json) {
    return DoctorDetailsModel(
      id: json["_id"]?.toString(),
      name: json["name"]?.toString(),
      specialization: json["specialization"]?.toString(),

      clinicName: json["clinic_name"]?.toString(),
      clinicAddress: json["clinic_address"]?.toString(),

      location: json["location"]?.toString(),
      latitude: json["latitude"]?.toString(),
      longitude: json["longitude"]?.toString(),

      email: json["email"]?.toString(),
      phone: json["phone"]?.toString(),

      registrationNumber:
      json["registration_number"]?.toString(),

      yearsOfExperience: json["years_of_experience"],

      dateOfBirth: json["date_of_birth"] == null
          ? null
          : DateTime.parse(json["date_of_birth"]),

      qualification: json["qualification"]?.toString(),

      consultationFee: json["consultation_fee"] == null
          ? null
          : double.tryParse(
        json["consultation_fee"].toString(),
      ),

      availableTimings:
      json["available_timings"]?.toString(),

      geoImageUrl: json["geo_image_url"]?.toString(),

      gender: json["gender"]?.toString(),

      anniversary: json["anniversary"] == null
          ? null
          : DateTime.parse(json["anniversary"]),

      priority: json["priority"]?.toString(),

      geoImageStatus: json["geo_image_status"],

      isAssignedToArea: json["is_assigned_to_area"],

      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]),

      updatedAt: json["updatedAt"] == null
          ? null
          : DateTime.parse(json["updatedAt"]),

      headOffice: json["headOffice"] == null
          ? null
          : HeadOffice.fromJson(json["headOffice"]),

      area: json["area"] == null
          ? null
          : Area.fromJson(json["area"]),

      visitHistory: json["visit_history"] == null
          ? []
          : List<VisitHistory>.from(
        json["visit_history"]
            .map((x) => VisitHistory.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "specialization": specialization,
      "clinic_name": clinicName,
      "clinic_address": clinicAddress,
      "location": location,
      "latitude": latitude,
      "longitude": longitude,
      "email": email,
      "phone": phone,
      "registration_number": registrationNumber,
      "years_of_experience": yearsOfExperience,
      "date_of_birth":
      dateOfBirth?.toIso8601String(),
      "qualification": qualification,
      "consultation_fee": consultationFee,
      "available_timings": availableTimings,
      "geo_image_url": geoImageUrl,
      "gender": gender,
      "anniversary":
      anniversary?.toIso8601String(),
      "priority": priority,
      "geo_image_status": geoImageStatus,
      "is_assigned_to_area": isAssignedToArea,
      "createdAt":
      createdAt?.toIso8601String(),
      "updatedAt":
      updatedAt?.toIso8601String(),
      "headOffice": headOffice?.toJson(),
      "area": area?.toJson(),
      "visit_history":
      visitHistory?.map((e) => e.toJson()).toList(),
    };
  }
}

class HeadOffice {
  String? id;
  String? name;

  HeadOffice({
    this.id,
    this.name,
  });

  factory HeadOffice.fromJson(
      Map<String, dynamic> json) {
    return HeadOffice(
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}

class Area {
  String? id;
  String? name;

  Area({
    this.id,
    this.name,
  });

  factory Area.fromJson(
      Map<String, dynamic> json) {
    return Area(
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}

class VisitHistory {
  String? id;
  DateTime? date;
  String? notes;

  String? latitude;
  String? longitude;

  bool? confirmed;

  String? remark;

  List<String>? productsDetailed;
  List<String>? giftsGiven;

  String? userName;
  String? userEmail;

  Product? product;

  DateTime? createdAt;
  DateTime? updatedAt;

  VisitHistory({
    this.id,
    this.date,
    this.notes,
    this.latitude,
    this.longitude,
    this.confirmed,
    this.remark,
    this.productsDetailed,
    this.giftsGiven,
    this.userName,
    this.userEmail,
    this.product,
    this.createdAt,
    this.updatedAt,
  });

  factory VisitHistory.fromJson(Map<String, dynamic> json) {
    return VisitHistory(
      id: json["id"]?.toString(),

      date: json["date"] == null
          ? null
          : DateTime.parse(json["date"]),

      notes: json["notes"]?.toString(),

      latitude: json["latitude"]?.toString(),

      longitude: json["longitude"]?.toString(),

      confirmed: json["confirmed"],

      remark: json["remark"]?.toString(),

      productsDetailed: json["products_detailed"] == null
          ? []
          : List<String>.from(json["products_detailed"]),

      giftsGiven: json["gifts_given"] == null
          ? []
          : List<String>.from(json["gifts_given"]),

      userName: json["userName"]?.toString(),

      userEmail: json["userEmail"]?.toString(),

      product: json["product"] == null
          ? null
          : Product.fromJson(json["product"]),

      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]),

      updatedAt: json["updatedAt"] == null
          ? null
          : DateTime.parse(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date?.toIso8601String(),
      "notes": notes,
      "latitude": latitude,
      "longitude": longitude,
      "confirmed": confirmed,
      "remark": remark,
      "products_detailed": productsDetailed,
      "gifts_given": giftsGiven,
      "userName": userName,
      "userEmail": userEmail,
      "product": product?.toJson(),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}

class Product {
  int? id;
  String? name;

  Product({
    this.id,
    this.name,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      name: json["name"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}