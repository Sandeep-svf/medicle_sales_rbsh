import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor_dto.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor_record.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor_sync_models.dart';

Map<String, dynamic> fullDoctorJson({
  String id = '00f08a0d-65e9-443d-964a-b99f5141ccb9',
  Object syncVersion = 1,
  String? name = 'sam 123',
  String? clientGeneratedId,
  String? clientGeneratedIdAlias,
}) {
  return {
    'id': id,
    'name': name,
    'specialization': null,
    'clinicName': null,
    'clinicAddress': null,
    'location': 'Unable to get address.',
    'latitude': 28.58993961,
    'longitude': 77.43492868,
    'email': null,
    'phone': null,
    'registrationNumber': null,
    'yearsOfExperience': null,
    'dateOfBirth': null,
    'qualification': null,
    'consultationFee': null,
    'availableTimings': null,
    'geoImageUrl': null,
    'gender': 'Male',
    'anniversary': null,
    'priority': 'C',
    'headOfficeId': '0c9bc293-9cc9-4013-8ba4-b89002d5b491',
    'headOfficeName': 'Gaya',
    'areaId': 'c79df78a-32be-4532-9da8-faa7ce27b784',
    'areaName': 'alkkdd',
    'ucpmpAnnualCap': 100000,
    'createdByName': null,
    'clientGeneratedId': clientGeneratedId,
    'client_generated_id': clientGeneratedIdAlias,
    'syncVersion': syncVersion,
    'createdAt': '2026-01-06T10:39:34.134Z',
    'updatedAt': '2026-07-01T09:57:58.860Z',
  };
}

DoctorDto fixtureDoctorDto({
  String id = 'doctor-1',
  Object syncVersion = 1,
  String? name = 'Dr. Offline',
  String? clientGeneratedId,
}) {
  final json = fullDoctorJson(
    id: id,
    syncVersion: syncVersion,
    name: name,
    clientGeneratedId: clientGeneratedId,
    clientGeneratedIdAlias: clientGeneratedId,
  );
  json.addAll({
    'specialization': 'Cardiology',
    'clinicName': 'Care Clinic',
    'clinicAddress': '12 Health Road',
    'location': 'Gaya',
    'email': 'doctor@example.com',
    'phone': '+91 99999 00000',
    'registrationNumber': 'REG-123',
    'yearsOfExperience': 12,
    'dateOfBirth': '1980-04-12',
    'qualification': 'MD',
    'consultationFee': 750.5,
    'availableTimings': '10:00 AM - 2:00 PM',
    'geoImageUrl': 'https://example.test/geo-image.jpg',
    'anniversary': '2010-02-14',
    'priority': 'A',
    'ucpmpAnnualCap': 100000.25,
    'createdByName': 'Area Manager',
  });
  return DoctorDto.fromJson(json);
}

DoctorRecord fixtureDoctorRecord({
  String id = 'doctor-1',
  String localId = 'local-doctor-1',
  Object syncVersion = 1,
  String? name = 'Dr. Offline',
  String? clientGeneratedId,
}) {
  return DoctorRecord.fromDto(
    dto: fixtureDoctorDto(
      id: id,
      syncVersion: syncVersion,
      name: name,
      clientGeneratedId: clientGeneratedId,
    ),
    localId: localId,
  );
}

Doctor fixtureDoctor({
  String id = 'doctor-1',
  String localId = 'local-doctor-1',
  Object syncVersion = 1,
  String? name = 'Dr. Offline',
}) {
  return fixtureDoctorRecord(
    id: id,
    localId: localId,
    syncVersion: syncVersion,
    name: name,
  ).toDomain();
}

BootstrapPage fixtureBootstrapPage({
  required BigInt snapshotVersion,
  BigInt? currentServerVersion,
  String? nextCursor,
  bool hasMore = false,
  List<DoctorDto> doctors = const [],
}) {
  return BootstrapPage(
    success: true,
    snapshotVersion: snapshotVersion,
    currentServerVersion: currentServerVersion ?? snapshotVersion,
    nextCursor: nextCursor,
    hasMore: hasMore,
    doctors: doctors,
  );
}

DeltaPage fixtureDeltaPage({
  required BigInt afterVersion,
  required BigInt nextAfterVersion,
  BigInt? currentServerVersion,
  bool hasMore = false,
  List<DoctorDto> upserts = const [],
  List<DoctorDeletion> deletes = const [],
  bool deletionsFieldPresent = true,
}) {
  return DeltaPage(
    success: true,
    currentServerVersion: currentServerVersion ?? nextAfterVersion,
    afterVersion: afterVersion,
    nextAfterVersion: nextAfterVersion,
    hasMore: hasMore,
    upserts: upserts,
    deletes: deletes,
    deletionsFieldPresent: deletionsFieldPresent,
  );
}
