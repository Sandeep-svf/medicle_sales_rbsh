import 'doctor_model_parsing.dart';

const Object _doctorDtoUnset = Object();

class DoctorDto {
  const DoctorDto({
    required this.id,
    required this.name,
    required this.specialization,
    required this.clinicName,
    required this.clinicAddress,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.email,
    required this.phone,
    required this.registrationNumber,
    required this.yearsOfExperience,
    required this.dateOfBirth,
    required this.qualification,
    required this.consultationFee,
    required this.availableTimings,
    required this.geoImageUrl,
    required this.gender,
    required this.anniversary,
    required this.priority,
    required this.headOfficeId,
    required this.headOfficeName,
    required this.areaId,
    required this.areaName,
    required this.ucpmpAnnualCap,
    required this.createdByName,
    required this.clientGeneratedId,
    required this.syncVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? name;
  final String? specialization;
  final String? clinicName;
  final String? clinicAddress;
  final String? location;
  final num? latitude;
  final num? longitude;
  final String? email;
  final String? phone;
  final String? registrationNumber;
  final int? yearsOfExperience;
  final DateTime? dateOfBirth;
  final String? qualification;
  final num? consultationFee;
  final String? availableTimings;
  final String? geoImageUrl;
  final String? gender;
  final DateTime? anniversary;
  final String? priority;
  final String? headOfficeId;
  final String? headOfficeName;
  final String? areaId;
  final String? areaName;
  final num? ucpmpAnnualCap;
  final String? createdByName;
  final String? clientGeneratedId;
  final BigInt syncVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DoctorDto.fromJson(Map<String, dynamic> json) {
    return DoctorDto(
      id: DoctorModelParsing.requiredIdentifier(json['id'], 'id'),
      name: DoctorModelParsing.nullableString(json['name'], 'name'),
      specialization: DoctorModelParsing.nullableString(
        json['specialization'],
        'specialization',
      ),
      clinicName: DoctorModelParsing.nullableString(
        json['clinicName'],
        'clinicName',
      ),
      clinicAddress: DoctorModelParsing.nullableString(
        json['clinicAddress'],
        'clinicAddress',
      ),
      location: DoctorModelParsing.nullableString(
        json['location'],
        'location',
      ),
      latitude: DoctorModelParsing.nullableNumber(
        json['latitude'],
        'latitude',
      ),
      longitude: DoctorModelParsing.nullableNumber(
        json['longitude'],
        'longitude',
      ),
      email: DoctorModelParsing.nullableString(json['email'], 'email'),
      phone: DoctorModelParsing.nullableString(json['phone'], 'phone'),
      registrationNumber: DoctorModelParsing.nullableString(
        json['registrationNumber'],
        'registrationNumber',
      ),
      yearsOfExperience: DoctorModelParsing.nullableInteger(
        json['yearsOfExperience'],
        'yearsOfExperience',
      ),
      dateOfBirth: DoctorModelParsing.nullableCalendarDate(
        json['dateOfBirth'],
        'dateOfBirth',
      ),
      qualification: DoctorModelParsing.nullableString(
        json['qualification'],
        'qualification',
      ),
      consultationFee: DoctorModelParsing.nullableNumber(
        json['consultationFee'],
        'consultationFee',
      ),
      availableTimings: DoctorModelParsing.nullableString(
        json['availableTimings'],
        'availableTimings',
      ),
      geoImageUrl: DoctorModelParsing.nullableString(
        json['geoImageUrl'],
        'geoImageUrl',
      ),
      gender: DoctorModelParsing.nullableString(json['gender'], 'gender'),
      anniversary: DoctorModelParsing.nullableCalendarDate(
        json['anniversary'],
        'anniversary',
      ),
      priority: DoctorModelParsing.nullableString(
        json['priority'],
        'priority',
      ),
      headOfficeId: DoctorModelParsing.nullableIdentifier(
        json['headOfficeId'],
        'headOfficeId',
      ),
      headOfficeName: DoctorModelParsing.nullableString(
        json['headOfficeName'],
        'headOfficeName',
      ),
      areaId: DoctorModelParsing.nullableIdentifier(
        json['areaId'],
        'areaId',
      ),
      areaName: DoctorModelParsing.nullableString(
        json['areaName'],
        'areaName',
      ),
      ucpmpAnnualCap: DoctorModelParsing.nullableNumber(
        json['ucpmpAnnualCap'],
        'ucpmpAnnualCap',
      ),
      createdByName: DoctorModelParsing.nullableString(
        json['createdByName'],
        'createdByName',
      ),
      clientGeneratedId: DoctorModelParsing.clientGeneratedId(json),
      syncVersion: DoctorModelParsing.requiredVersion(
        json['syncVersion'],
        'syncVersion',
      ),
      createdAt: DoctorModelParsing.nullableTimestamp(
        json['createdAt'],
        'createdAt',
      ),
      updatedAt: DoctorModelParsing.nullableTimestamp(
        json['updatedAt'],
        'updatedAt',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'email': email,
      'phone': phone,
      'registrationNumber': registrationNumber,
      'yearsOfExperience': yearsOfExperience,
      'dateOfBirth': DoctorModelParsing.encodeCalendarDate(dateOfBirth),
      'qualification': qualification,
      'consultationFee': consultationFee,
      'availableTimings': availableTimings,
      'geoImageUrl': geoImageUrl,
      'gender': gender,
      'anniversary': DoctorModelParsing.encodeCalendarDate(anniversary),
      'priority': priority,
      'headOfficeId': headOfficeId,
      'headOfficeName': headOfficeName,
      'areaId': areaId,
      'areaName': areaName,
      'ucpmpAnnualCap': ucpmpAnnualCap,
      'createdByName': createdByName,
      'clientGeneratedId': clientGeneratedId,
      'syncVersion': syncVersion.toString(),
      'createdAt': DoctorModelParsing.encodeTimestamp(createdAt),
      'updatedAt': DoctorModelParsing.encodeTimestamp(updatedAt),
    };
  }

  DoctorDto copyWith({
    String? id,
    Object? name = _doctorDtoUnset,
    Object? specialization = _doctorDtoUnset,
    Object? clinicName = _doctorDtoUnset,
    Object? clinicAddress = _doctorDtoUnset,
    Object? location = _doctorDtoUnset,
    Object? latitude = _doctorDtoUnset,
    Object? longitude = _doctorDtoUnset,
    Object? email = _doctorDtoUnset,
    Object? phone = _doctorDtoUnset,
    Object? registrationNumber = _doctorDtoUnset,
    Object? yearsOfExperience = _doctorDtoUnset,
    Object? dateOfBirth = _doctorDtoUnset,
    Object? qualification = _doctorDtoUnset,
    Object? consultationFee = _doctorDtoUnset,
    Object? availableTimings = _doctorDtoUnset,
    Object? geoImageUrl = _doctorDtoUnset,
    Object? gender = _doctorDtoUnset,
    Object? anniversary = _doctorDtoUnset,
    Object? priority = _doctorDtoUnset,
    Object? headOfficeId = _doctorDtoUnset,
    Object? headOfficeName = _doctorDtoUnset,
    Object? areaId = _doctorDtoUnset,
    Object? areaName = _doctorDtoUnset,
    Object? ucpmpAnnualCap = _doctorDtoUnset,
    Object? createdByName = _doctorDtoUnset,
    Object? clientGeneratedId = _doctorDtoUnset,
    BigInt? syncVersion,
    Object? createdAt = _doctorDtoUnset,
    Object? updatedAt = _doctorDtoUnset,
  }) {
    return DoctorDto(
      id: id ?? this.id,
      name: identical(name, _doctorDtoUnset) ? this.name : name as String?,
      specialization: identical(specialization, _doctorDtoUnset)
          ? this.specialization
          : specialization as String?,
      clinicName: identical(clinicName, _doctorDtoUnset)
          ? this.clinicName
          : clinicName as String?,
      clinicAddress: identical(clinicAddress, _doctorDtoUnset)
          ? this.clinicAddress
          : clinicAddress as String?,
      location: identical(location, _doctorDtoUnset)
          ? this.location
          : location as String?,
      latitude: identical(latitude, _doctorDtoUnset)
          ? this.latitude
          : latitude as num?,
      longitude: identical(longitude, _doctorDtoUnset)
          ? this.longitude
          : longitude as num?,
      email: identical(email, _doctorDtoUnset) ? this.email : email as String?,
      phone: identical(phone, _doctorDtoUnset) ? this.phone : phone as String?,
      registrationNumber: identical(registrationNumber, _doctorDtoUnset)
          ? this.registrationNumber
          : registrationNumber as String?,
      yearsOfExperience: identical(yearsOfExperience, _doctorDtoUnset)
          ? this.yearsOfExperience
          : yearsOfExperience as int?,
      dateOfBirth: identical(dateOfBirth, _doctorDtoUnset)
          ? this.dateOfBirth
          : dateOfBirth as DateTime?,
      qualification: identical(qualification, _doctorDtoUnset)
          ? this.qualification
          : qualification as String?,
      consultationFee: identical(consultationFee, _doctorDtoUnset)
          ? this.consultationFee
          : consultationFee as num?,
      availableTimings: identical(availableTimings, _doctorDtoUnset)
          ? this.availableTimings
          : availableTimings as String?,
      geoImageUrl: identical(geoImageUrl, _doctorDtoUnset)
          ? this.geoImageUrl
          : geoImageUrl as String?,
      gender:
          identical(gender, _doctorDtoUnset) ? this.gender : gender as String?,
      anniversary: identical(anniversary, _doctorDtoUnset)
          ? this.anniversary
          : anniversary as DateTime?,
      priority: identical(priority, _doctorDtoUnset)
          ? this.priority
          : priority as String?,
      headOfficeId: identical(headOfficeId, _doctorDtoUnset)
          ? this.headOfficeId
          : headOfficeId as String?,
      headOfficeName: identical(headOfficeName, _doctorDtoUnset)
          ? this.headOfficeName
          : headOfficeName as String?,
      areaId:
          identical(areaId, _doctorDtoUnset) ? this.areaId : areaId as String?,
      areaName: identical(areaName, _doctorDtoUnset)
          ? this.areaName
          : areaName as String?,
      ucpmpAnnualCap: identical(ucpmpAnnualCap, _doctorDtoUnset)
          ? this.ucpmpAnnualCap
          : ucpmpAnnualCap as num?,
      createdByName: identical(createdByName, _doctorDtoUnset)
          ? this.createdByName
          : createdByName as String?,
      clientGeneratedId: identical(clientGeneratedId, _doctorDtoUnset)
          ? this.clientGeneratedId
          : clientGeneratedId as String?,
      syncVersion: syncVersion ?? this.syncVersion,
      createdAt: identical(createdAt, _doctorDtoUnset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _doctorDtoUnset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }
}
