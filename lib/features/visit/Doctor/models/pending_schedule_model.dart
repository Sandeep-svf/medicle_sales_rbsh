class PendingScheduleModel {
  const PendingScheduleModel({
    required this.localId,
    required this.doctorLocalId,
    required this.userId,
    required this.date,
    required this.notes,
    required this.remark,
    required this.doctorName,
    required this.doctorLatitude,
    required this.doctorLongitude,
    required this.createdAt,
    this.areaId,
    this.areaName,
    this.serverDoctorId,
    this.serverVisitId,
    this.lastError,
  });

  final String localId;
  final String doctorLocalId;
  final String? serverDoctorId;
  final String userId;
  final String date;
  final String notes;
  final String remark;
  final String doctorName;
  final double? doctorLatitude;
  final double? doctorLongitude;
  final DateTime createdAt;
  final String? areaId;
  final String? areaName;
  final String? serverVisitId;
  final String? lastError;

  bool get isUploaded => serverVisitId?.trim().isNotEmpty == true;

  PendingScheduleModel copyWith({
    String? serverDoctorId,
    String? serverVisitId,
    String? lastError,
    bool clearError = false,
  }) {
    return PendingScheduleModel(
      localId: localId,
      doctorLocalId: doctorLocalId,
      serverDoctorId: serverDoctorId ?? this.serverDoctorId,
      userId: userId,
      date: date,
      notes: notes,
      remark: remark,
      doctorName: doctorName,
      doctorLatitude: doctorLatitude,
      doctorLongitude: doctorLongitude,
      createdAt: createdAt,
      areaId: areaId,
      areaName: areaName,
      serverVisitId: serverVisitId ?? this.serverVisitId,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'localId': localId,
      'doctorLocalId': doctorLocalId,
      'serverDoctorId': serverDoctorId,
      'userId': userId,
      'date': date,
      'notes': notes,
      'remark': remark,
      'doctorName': doctorName,
      'doctorLatitude': doctorLatitude,
      'doctorLongitude': doctorLongitude,
      'createdAt': createdAt.toIso8601String(),
      'areaId': areaId,
      'areaName': areaName,
      'serverVisitId': serverVisitId,
      'lastError': lastError,
    };
  }

  factory PendingScheduleModel.fromMap(Map<String, dynamic> map) {
    return PendingScheduleModel(
      localId: map['localId'].toString(),
      doctorLocalId: map['doctorLocalId'].toString(),
      serverDoctorId: _nullableString(map['serverDoctorId']),
      userId: map['userId'].toString(),
      date: map['date'].toString(),
      notes: map['notes']?.toString() ?? '',
      remark: map['remark']?.toString() ?? '',
      doctorName: map['doctorName']?.toString() ?? 'Doctor',
      doctorLatitude: _nullableDouble(map['doctorLatitude']),
      doctorLongitude: _nullableDouble(map['doctorLongitude']),
      createdAt: DateTime.parse(map['createdAt'].toString()),
      areaId: _nullableString(map['areaId']),
      areaName: _nullableString(map['areaName']),
      serverVisitId: _nullableString(map['serverVisitId']),
      lastError: _nullableString(map['lastError']),
    );
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static double? _nullableDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
