import 'package:intl/intl.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String location;
  final String latitude;
  final String longitude;
  final String email;
  final String phone;
  final String registrationNumber;
  final String? yearsOfExperience; // Keeping as String to be safe, or int?
  final DateTime? dateOfBirth;
  final String? geoImageUrl;
  final String gender;
  final DateTime? anniversary;
  final String priority;
  final String headOfficeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HeadOffice headOffice;
  final bool geoImageStatus;
  final List<dynamic> visitHistory; // Added to support your UI code

  final String? clinicName;
  final String? clinicAddress;
  final String? qualification;
  final dynamic consultationFee;
  final dynamic availableTimings;
  final String? areaId;
  final bool isAssignedToArea;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.email,
    required this.phone,
    required this.registrationNumber,
    this.yearsOfExperience,
    this.dateOfBirth,
    this.geoImageUrl,
    required this.gender,
    this.anniversary,
    required this.priority,
    required this.headOfficeId,
    required this.createdAt,
    required this.updatedAt,
    required this.headOffice,
    required this.geoImageStatus,
    this.visitHistory = const [],

    this.clinicName,
    this.clinicAddress,
    this.qualification,
    this.consultationFee,
    this.availableTimings,
    this.areaId,
    this.isAssignedToArea = false,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Doctor',

      // Handle null strings by providing empty default
      specialization: json['specialization']?.toString() ?? '',
      location: json['location']?.toString() ?? '',

      // Lat/Lng are strings in your JSON, handle nulls
      latitude: json['latitude']?.toString() ?? '0.0',
      longitude: json['longitude']?.toString() ?? '0.0',

      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      registrationNumber: json['registration_number']?.toString() ?? '',

      // Parse Experience (Handle int or string representation)
      yearsOfExperience: json['years_of_experience']?.toString(),

      // Parse Dates (Handle nulls)
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,

      geoImageUrl: json['geo_image_url']?.toString(),

      gender: json['gender']?.toString() ?? 'Unknown',

      anniversary: json['anniversary'] != null
          ? DateTime.tryParse(json['anniversary'])
          : null,

      priority: json['priority']?.toString() ?? 'C',
      headOfficeId: json['headOfficeId']?.toString() ?? '',

      // Parse ISO Dates
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),

      // Parse Nested Object
      headOffice: json['headOffice'] != null
          ? HeadOffice.fromJson(json['headOffice'])
          : HeadOffice(id: '', name: ''),


      geoImageStatus: json["geo_image_status"] ?? false,
      // Default to empty list as it's missing in JSON but used in UI
      visitHistory: json['visitHistory'] ?? [],

      clinicName: json['clinic_name']?.toString(),
      clinicAddress: json['clinic_address']?.toString(),
      qualification: json['qualification']?.toString(),
      consultationFee: json['consultation_fee'],
      availableTimings: json['available_timings'],
      areaId: json['areaId']?.toString(),
      isAssignedToArea: json['is_assigned_to_area'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'email': email,
      'phone': phone,
      'registration_number': registrationNumber,
      'years_of_experience': yearsOfExperience,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'geo_image_url': geoImageUrl,
      'gender': gender,
      'anniversary': anniversary?.toIso8601String(),
      'priority': priority,
      'headOfficeId': headOfficeId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'headOffice': headOffice.toJson(),
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'qualification': qualification,
      'consultation_fee': consultationFee,
      'available_timings': availableTimings,
      'areaId': areaId,
      'is_assigned_to_area': isAssignedToArea,
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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}