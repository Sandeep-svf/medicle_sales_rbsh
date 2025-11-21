import '../../../utils/offline_model/BaseOfflineModel.dart';

class DoctorOfflineModel extends BaseOfflineModel {
  final String? id; // UUID
  final String name;
  final String? specialization;
  final String? location;
  final double latitude;
  final double longitude;
  final String? email;
  final String? phone;
  final String? registrationNumber;
  final int? yearsOfExperience;
  final String? dateOfBirth;
  final String? gender;
  final String? anniversary;
  final String headOfficeId;

  DoctorOfflineModel({
    this.id,
    required this.name,
    this.specialization,
    this.location,
    required this.latitude,
    required this.longitude,
    this.email,
    this.phone,
    this.registrationNumber,
    this.yearsOfExperience,
    this.dateOfBirth,
    this.gender,
    this.anniversary,
    required this.headOfficeId,
  });

  factory DoctorOfflineModel.fromJson(Map<String, dynamic> json) {
    return DoctorOfflineModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      specialization: json['specialization'],
      location: json['location'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      email: json['email'],
      phone: json['phone'],
      registrationNumber: json['registration_number'],
      yearsOfExperience: json['years_of_experience'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      anniversary: json['anniversary'],
      headOfficeId: json['headOfficeId'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'headOfficeId': headOfficeId,
      'latitude': latitude,
      'longitude': longitude,
      if (specialization != null) 'specialization': specialization,
      if (location != null) 'location': location,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (registrationNumber != null) 'registration_number': registrationNumber,
      if (yearsOfExperience != null) 'years_of_experience': yearsOfExperience,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (anniversary != null) 'anniversary': anniversary,
    };
  }

  @override
  String get tableName => 'doctors';
}
