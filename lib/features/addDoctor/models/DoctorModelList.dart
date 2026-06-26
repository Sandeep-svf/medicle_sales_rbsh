class Doctor {
  final String id;
  final String name;
  final String? specialization;
  final String? clinicName;
  final String? clinicAddress;
  final String? location;
  final String? latitude;
  final String? longitude;
  final String? email;
  final String? phone;
  final String? registrationNumber;
  final int? yearsOfExperience;
  final String? dateOfBirth;
  final String? qualification;
  final dynamic consultationFee;
  final dynamic availableTimings;
  final String? geoImageUrl;
  final String? gender;
  final String? anniversary;
  final String priority;

  final HeadOffice? headOffice;
  final Area? area;

  final bool isAssignedToArea;
  final bool geoImageStatus;

  final String createdAt;
  final String updatedAt;

  final String? lastVisitedDate;
  final int? daysSinceLastVisit;
  final String? lastVisitedDateAny;
  final int? daysSinceLastVisitAny;

  Doctor({
    required this.id,
    required this.name,
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
    required this.priority,
    this.headOffice,
    this.area,
    required this.isAssignedToArea,
    required this.geoImageStatus,
    required this.createdAt,
    required this.updatedAt,
    this.lastVisitedDate,
    this.daysSinceLastVisit,
    this.lastVisitedDateAny,
    this.daysSinceLastVisitAny,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'],
      clinicName: json['clinic_name'],
      clinicAddress: json['clinic_address'],
      location: json['location'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      email: json['email'],
      phone: json['phone'],
      registrationNumber: json['registration_number'],
      yearsOfExperience: json['years_of_experience'],
      dateOfBirth: json['date_of_birth'],
      qualification: json['qualification'],
      consultationFee: json['consultation_fee'],
      availableTimings: json['available_timings'],
      geoImageUrl: json['geo_image_url'],
      gender: json['gender'],
      anniversary: json['anniversary'],
      priority: json['priority'] ?? 'C',
      headOffice: json['headOffice'] != null
          ? HeadOffice.fromJson(json['headOffice'])
          : null,
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
      isAssignedToArea: json['is_assigned_to_area'] ?? false,
      geoImageStatus: json['geo_image_status'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      lastVisitedDate: json['lastVisitedDate'],
      daysSinceLastVisit: json['daysSinceLastVisit'],
      lastVisitedDateAny: json['lastVisitedDateAny'],
      daysSinceLastVisitAny: json['daysSinceLastVisitAny'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'specialization': specialization,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'email': email,
      'phone': phone,
      'registration_number': registrationNumber,
      'years_of_experience': yearsOfExperience,
      'date_of_birth': dateOfBirth,
      'qualification': qualification,
      'consultation_fee': consultationFee,
      'available_timings': availableTimings,
      'geo_image_url': geoImageUrl,
      'gender': gender,
      'anniversary': anniversary,
      'priority': priority,
      'headOffice': headOffice?.toJson(),
      'area': area?.toJson(),
      'is_assigned_to_area': isAssignedToArea,
      'geo_image_status': geoImageStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastVisitedDate': lastVisitedDate,
      'daysSinceLastVisit': daysSinceLastVisit,
      'lastVisitedDateAny': lastVisitedDateAny,
      'daysSinceLastVisitAny': daysSinceLastVisitAny,
    };
  }
}

class HeadOffice {
  final String id;
  final String name;

  HeadOffice({
    required this.id,
    required this.name,
  });

  factory HeadOffice.fromJson(Map<String, dynamic> json) {
    return HeadOffice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Area {
  final String id;
  final String name;

  Area({
    required this.id,
    required this.name,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}