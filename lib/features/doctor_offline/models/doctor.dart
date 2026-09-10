const Object _doctorUnset = Object();

enum DoctorLocalSyncState {
  synced,
  pendingCreate;

  static DoctorLocalSyncState fromStorage(String value) {
    return DoctorLocalSyncState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => throw FormatException(
        'Unknown doctor local sync state: $value',
      ),
    );
  }
}

class Doctor {
  const Doctor({
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

  String get displayName {
    final value = name?.trim();
    return value == null || value.isEmpty ? 'Unnamed doctor' : value;
  }

  String get displayClinic {
    final value = clinicName?.trim();
    return value == null || value.isEmpty ? 'Clinic not provided' : value;
  }

  String get displaySpecialization {
    final value = specialization?.trim();
    return value == null || value.isEmpty
        ? 'Specialization not provided'
        : value;
  }

  String get displayPriority {
    final value = priority?.trim();
    return value == null || value.isEmpty ? 'Not set' : value;
  }

  bool get hasValidCoordinates {
    final latitudeValue = latitude?.toDouble();
    final longitudeValue = longitude?.toDouble();
    return latitudeValue != null &&
        longitudeValue != null &&
        latitudeValue >= -90 &&
        latitudeValue <= 90 &&
        longitudeValue >= -180 &&
        longitudeValue <= 180;
  }

  bool matchesSearch(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    return [
      name,
      clinicName,
      specialization,
      location,
      clinicAddress,
      headOfficeName,
      areaName,
      registrationNumber,
    ].whereType<String>().any(
          (value) => value.toLowerCase().contains(normalizedQuery),
        );
  }

  Doctor copyWith({
    String? localId,
    Object? serverId = _doctorUnset,
    Object? clientGeneratedId = _doctorUnset,
    DoctorLocalSyncState? localSyncState,
    Object? syncVersion = _doctorUnset,
    Object? name = _doctorUnset,
    Object? specialization = _doctorUnset,
    Object? clinicName = _doctorUnset,
    Object? clinicAddress = _doctorUnset,
    Object? location = _doctorUnset,
    Object? latitude = _doctorUnset,
    Object? longitude = _doctorUnset,
    Object? email = _doctorUnset,
    Object? phone = _doctorUnset,
    Object? registrationNumber = _doctorUnset,
    Object? yearsOfExperience = _doctorUnset,
    Object? dateOfBirth = _doctorUnset,
    Object? qualification = _doctorUnset,
    Object? consultationFee = _doctorUnset,
    Object? availableTimings = _doctorUnset,
    Object? geoImageUrl = _doctorUnset,
    Object? gender = _doctorUnset,
    Object? anniversary = _doctorUnset,
    Object? priority = _doctorUnset,
    Object? headOfficeId = _doctorUnset,
    Object? headOfficeName = _doctorUnset,
    Object? areaId = _doctorUnset,
    Object? areaName = _doctorUnset,
    Object? ucpmpAnnualCap = _doctorUnset,
    Object? createdByName = _doctorUnset,
    Object? createdAt = _doctorUnset,
    Object? updatedAt = _doctorUnset,
  }) {
    return Doctor(
      localId: localId ?? this.localId,
      serverId: identical(serverId, _doctorUnset)
          ? this.serverId
          : serverId as String?,
      clientGeneratedId: identical(clientGeneratedId, _doctorUnset)
          ? this.clientGeneratedId
          : clientGeneratedId as String?,
      localSyncState: localSyncState ?? this.localSyncState,
      syncVersion: identical(syncVersion, _doctorUnset)
          ? this.syncVersion
          : syncVersion as BigInt?,
      name: identical(name, _doctorUnset) ? this.name : name as String?,
      specialization: identical(specialization, _doctorUnset)
          ? this.specialization
          : specialization as String?,
      clinicName: identical(clinicName, _doctorUnset)
          ? this.clinicName
          : clinicName as String?,
      clinicAddress: identical(clinicAddress, _doctorUnset)
          ? this.clinicAddress
          : clinicAddress as String?,
      location: identical(location, _doctorUnset)
          ? this.location
          : location as String?,
      latitude:
          identical(latitude, _doctorUnset) ? this.latitude : latitude as num?,
      longitude: identical(longitude, _doctorUnset)
          ? this.longitude
          : longitude as num?,
      email: identical(email, _doctorUnset) ? this.email : email as String?,
      phone: identical(phone, _doctorUnset) ? this.phone : phone as String?,
      registrationNumber: identical(registrationNumber, _doctorUnset)
          ? this.registrationNumber
          : registrationNumber as String?,
      yearsOfExperience: identical(yearsOfExperience, _doctorUnset)
          ? this.yearsOfExperience
          : yearsOfExperience as int?,
      dateOfBirth: identical(dateOfBirth, _doctorUnset)
          ? this.dateOfBirth
          : dateOfBirth as DateTime?,
      qualification: identical(qualification, _doctorUnset)
          ? this.qualification
          : qualification as String?,
      consultationFee: identical(consultationFee, _doctorUnset)
          ? this.consultationFee
          : consultationFee as num?,
      availableTimings: identical(availableTimings, _doctorUnset)
          ? this.availableTimings
          : availableTimings as String?,
      geoImageUrl: identical(geoImageUrl, _doctorUnset)
          ? this.geoImageUrl
          : geoImageUrl as String?,
      gender: identical(gender, _doctorUnset) ? this.gender : gender as String?,
      anniversary: identical(anniversary, _doctorUnset)
          ? this.anniversary
          : anniversary as DateTime?,
      priority: identical(priority, _doctorUnset)
          ? this.priority
          : priority as String?,
      headOfficeId: identical(headOfficeId, _doctorUnset)
          ? this.headOfficeId
          : headOfficeId as String?,
      headOfficeName: identical(headOfficeName, _doctorUnset)
          ? this.headOfficeName
          : headOfficeName as String?,
      areaId: identical(areaId, _doctorUnset) ? this.areaId : areaId as String?,
      areaName: identical(areaName, _doctorUnset)
          ? this.areaName
          : areaName as String?,
      ucpmpAnnualCap: identical(ucpmpAnnualCap, _doctorUnset)
          ? this.ucpmpAnnualCap
          : ucpmpAnnualCap as num?,
      createdByName: identical(createdByName, _doctorUnset)
          ? this.createdByName
          : createdByName as String?,
      createdAt: identical(createdAt, _doctorUnset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _doctorUnset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }
}

class DoctorQuery {
  const DoctorQuery({
    this.search = '',
    this.priority,
    this.headOfficeId,
    this.areaId,
  });

  final String search;
  final String? priority;
  final String? headOfficeId;
  final String? areaId;

  bool matches(Doctor doctor) {
    if (!doctor.matchesSearch(search)) return false;
    if (priority != null && doctor.priority != priority) return false;
    if (headOfficeId != null && doctor.headOfficeId != headOfficeId) {
      return false;
    }
    if (areaId != null && doctor.areaId != areaId) return false;
    return true;
  }

  DoctorQuery copyWith({
    String? search,
    Object? priority = _doctorUnset,
    Object? headOfficeId = _doctorUnset,
    Object? areaId = _doctorUnset,
  }) {
    return DoctorQuery(
      search: search ?? this.search,
      priority: identical(priority, _doctorUnset)
          ? this.priority
          : priority as String?,
      headOfficeId: identical(headOfficeId, _doctorUnset)
          ? this.headOfficeId
          : headOfficeId as String?,
      areaId: identical(areaId, _doctorUnset) ? this.areaId : areaId as String?,
    );
  }
}
