import 'doctor.dart';
import 'doctor_dto.dart';
import 'doctor_model_parsing.dart';

const Object _doctorRecordUnset = Object();

class DoctorRecord {
  const DoctorRecord({
    required this.localId,
    required this.serverId,
    required this.clientGeneratedId,
    required this.localSyncState,
    required this.syncVersion,
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
    required this.createdAt,
    required this.updatedAt,
  });

  final String localId;
  final String? serverId;
  final String? clientGeneratedId;
  final DoctorLocalSyncState localSyncState;
  final BigInt? syncVersion;
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DoctorRecord.fromDto({
    required DoctorDto dto,
    required String localId,
    String? existingClientGeneratedId,
  }) {
    return DoctorRecord(
      localId: localId,
      serverId: dto.id,
      clientGeneratedId: dto.clientGeneratedId ?? existingClientGeneratedId,
      localSyncState: DoctorLocalSyncState.synced,
      syncVersion: dto.syncVersion,
      name: dto.name,
      specialization: dto.specialization,
      clinicName: dto.clinicName,
      clinicAddress: dto.clinicAddress,
      location: dto.location,
      latitude: dto.latitude,
      longitude: dto.longitude,
      email: dto.email,
      phone: dto.phone,
      registrationNumber: dto.registrationNumber,
      yearsOfExperience: dto.yearsOfExperience,
      dateOfBirth: dto.dateOfBirth,
      qualification: dto.qualification,
      consultationFee: dto.consultationFee,
      availableTimings: dto.availableTimings,
      geoImageUrl: dto.geoImageUrl,
      gender: dto.gender,
      anniversary: dto.anniversary,
      priority: dto.priority,
      headOfficeId: dto.headOfficeId,
      headOfficeName: dto.headOfficeName,
      areaId: dto.areaId,
      areaName: dto.areaName,
      ucpmpAnnualCap: dto.ucpmpAnnualCap,
      createdByName: dto.createdByName,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory DoctorRecord.fromDomain(Doctor doctor) {
    return DoctorRecord(
      localId: doctor.localId,
      serverId: doctor.serverId,
      clientGeneratedId: doctor.clientGeneratedId,
      localSyncState: doctor.localSyncState,
      syncVersion: doctor.syncVersion,
      name: doctor.name,
      specialization: doctor.specialization,
      clinicName: doctor.clinicName,
      clinicAddress: doctor.clinicAddress,
      location: doctor.location,
      latitude: doctor.latitude,
      longitude: doctor.longitude,
      email: doctor.email,
      phone: doctor.phone,
      registrationNumber: doctor.registrationNumber,
      yearsOfExperience: doctor.yearsOfExperience,
      dateOfBirth: doctor.dateOfBirth,
      qualification: doctor.qualification,
      consultationFee: doctor.consultationFee,
      availableTimings: doctor.availableTimings,
      geoImageUrl: doctor.geoImageUrl,
      gender: doctor.gender,
      anniversary: doctor.anniversary,
      priority: doctor.priority,
      headOfficeId: doctor.headOfficeId,
      headOfficeName: doctor.headOfficeName,
      areaId: doctor.areaId,
      areaName: doctor.areaName,
      ucpmpAnnualCap: doctor.ucpmpAnnualCap,
      createdByName: doctor.createdByName,
      createdAt: doctor.createdAt,
      updatedAt: doctor.updatedAt,
    );
  }

  factory DoctorRecord.fromJson(Map<String, dynamic> json) {
    final syncStateValue = DoctorModelParsing.requiredIdentifier(
      json['localSyncState'],
      'localSyncState',
    );
    return DoctorRecord(
      localId: DoctorModelParsing.requiredIdentifier(
        json['localId'],
        'localId',
      ),
      serverId: DoctorModelParsing.nullableIdentifier(
        json['serverId'],
        'serverId',
      ),
      clientGeneratedId: DoctorModelParsing.nullableIdentifier(
        json['clientGeneratedId'],
        'clientGeneratedId',
      ),
      localSyncState: DoctorLocalSyncState.fromStorage(syncStateValue),
      syncVersion: DoctorModelParsing.nullableVersion(
        json['syncVersion'],
        'syncVersion',
      ),
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
      'localId': localId,
      'serverId': serverId,
      'clientGeneratedId': clientGeneratedId,
      'localSyncState': localSyncState.name,
      'syncVersion': syncVersion?.toString(),
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
      'createdAt': DoctorModelParsing.encodeTimestamp(createdAt),
      'updatedAt': DoctorModelParsing.encodeTimestamp(updatedAt),
    };
  }

  Doctor toDomain() {
    return Doctor(
      localId: localId,
      serverId: serverId,
      clientGeneratedId: clientGeneratedId,
      localSyncState: localSyncState,
      syncVersion: syncVersion,
      name: name,
      specialization: specialization,
      clinicName: clinicName,
      clinicAddress: clinicAddress,
      location: location,
      latitude: latitude,
      longitude: longitude,
      email: email,
      phone: phone,
      registrationNumber: registrationNumber,
      yearsOfExperience: yearsOfExperience,
      dateOfBirth: dateOfBirth,
      qualification: qualification,
      consultationFee: consultationFee,
      availableTimings: availableTimings,
      geoImageUrl: geoImageUrl,
      gender: gender,
      anniversary: anniversary,
      priority: priority,
      headOfficeId: headOfficeId,
      headOfficeName: headOfficeName,
      areaId: areaId,
      areaName: areaName,
      ucpmpAnnualCap: ucpmpAnnualCap,
      createdByName: createdByName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  DoctorRecord copyWith({
    String? localId,
    Object? serverId = _doctorRecordUnset,
    Object? clientGeneratedId = _doctorRecordUnset,
    DoctorLocalSyncState? localSyncState,
    Object? syncVersion = _doctorRecordUnset,
    Object? name = _doctorRecordUnset,
    Object? specialization = _doctorRecordUnset,
    Object? clinicName = _doctorRecordUnset,
    Object? clinicAddress = _doctorRecordUnset,
    Object? location = _doctorRecordUnset,
    Object? latitude = _doctorRecordUnset,
    Object? longitude = _doctorRecordUnset,
    Object? email = _doctorRecordUnset,
    Object? phone = _doctorRecordUnset,
    Object? registrationNumber = _doctorRecordUnset,
    Object? yearsOfExperience = _doctorRecordUnset,
    Object? dateOfBirth = _doctorRecordUnset,
    Object? qualification = _doctorRecordUnset,
    Object? consultationFee = _doctorRecordUnset,
    Object? availableTimings = _doctorRecordUnset,
    Object? geoImageUrl = _doctorRecordUnset,
    Object? gender = _doctorRecordUnset,
    Object? anniversary = _doctorRecordUnset,
    Object? priority = _doctorRecordUnset,
    Object? headOfficeId = _doctorRecordUnset,
    Object? headOfficeName = _doctorRecordUnset,
    Object? areaId = _doctorRecordUnset,
    Object? areaName = _doctorRecordUnset,
    Object? ucpmpAnnualCap = _doctorRecordUnset,
    Object? createdByName = _doctorRecordUnset,
    Object? createdAt = _doctorRecordUnset,
    Object? updatedAt = _doctorRecordUnset,
  }) {
    return DoctorRecord(
      localId: localId ?? this.localId,
      serverId: identical(serverId, _doctorRecordUnset)
          ? this.serverId
          : serverId as String?,
      clientGeneratedId: identical(clientGeneratedId, _doctorRecordUnset)
          ? this.clientGeneratedId
          : clientGeneratedId as String?,
      localSyncState: localSyncState ?? this.localSyncState,
      syncVersion: identical(syncVersion, _doctorRecordUnset)
          ? this.syncVersion
          : syncVersion as BigInt?,
      name: identical(name, _doctorRecordUnset) ? this.name : name as String?,
      specialization: identical(specialization, _doctorRecordUnset)
          ? this.specialization
          : specialization as String?,
      clinicName: identical(clinicName, _doctorRecordUnset)
          ? this.clinicName
          : clinicName as String?,
      clinicAddress: identical(clinicAddress, _doctorRecordUnset)
          ? this.clinicAddress
          : clinicAddress as String?,
      location: identical(location, _doctorRecordUnset)
          ? this.location
          : location as String?,
      latitude: identical(latitude, _doctorRecordUnset)
          ? this.latitude
          : latitude as num?,
      longitude: identical(longitude, _doctorRecordUnset)
          ? this.longitude
          : longitude as num?,
      email:
          identical(email, _doctorRecordUnset) ? this.email : email as String?,
      phone:
          identical(phone, _doctorRecordUnset) ? this.phone : phone as String?,
      registrationNumber: identical(registrationNumber, _doctorRecordUnset)
          ? this.registrationNumber
          : registrationNumber as String?,
      yearsOfExperience: identical(yearsOfExperience, _doctorRecordUnset)
          ? this.yearsOfExperience
          : yearsOfExperience as int?,
      dateOfBirth: identical(dateOfBirth, _doctorRecordUnset)
          ? this.dateOfBirth
          : dateOfBirth as DateTime?,
      qualification: identical(qualification, _doctorRecordUnset)
          ? this.qualification
          : qualification as String?,
      consultationFee: identical(consultationFee, _doctorRecordUnset)
          ? this.consultationFee
          : consultationFee as num?,
      availableTimings: identical(availableTimings, _doctorRecordUnset)
          ? this.availableTimings
          : availableTimings as String?,
      geoImageUrl: identical(geoImageUrl, _doctorRecordUnset)
          ? this.geoImageUrl
          : geoImageUrl as String?,
      gender: identical(gender, _doctorRecordUnset)
          ? this.gender
          : gender as String?,
      anniversary: identical(anniversary, _doctorRecordUnset)
          ? this.anniversary
          : anniversary as DateTime?,
      priority: identical(priority, _doctorRecordUnset)
          ? this.priority
          : priority as String?,
      headOfficeId: identical(headOfficeId, _doctorRecordUnset)
          ? this.headOfficeId
          : headOfficeId as String?,
      headOfficeName: identical(headOfficeName, _doctorRecordUnset)
          ? this.headOfficeName
          : headOfficeName as String?,
      areaId: identical(areaId, _doctorRecordUnset)
          ? this.areaId
          : areaId as String?,
      areaName: identical(areaName, _doctorRecordUnset)
          ? this.areaName
          : areaName as String?,
      ucpmpAnnualCap: identical(ucpmpAnnualCap, _doctorRecordUnset)
          ? this.ucpmpAnnualCap
          : ucpmpAnnualCap as num?,
      createdByName: identical(createdByName, _doctorRecordUnset)
          ? this.createdByName
          : createdByName as String?,
      createdAt: identical(createdAt, _doctorRecordUnset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _doctorRecordUnset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }
}
