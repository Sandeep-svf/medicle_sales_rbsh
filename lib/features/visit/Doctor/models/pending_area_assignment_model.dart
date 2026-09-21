class PendingAreaAssignmentModel {
  const PendingAreaAssignmentModel({
    required this.localId,
    required this.doctorLocalId,
    required this.userId,
    required this.areaId,
    required this.areaName,
    required this.createdAt,
    this.serverDoctorId,
    this.uploaded = false,
    this.lastError,
  });

  final String localId;
  final String doctorLocalId;
  final String? serverDoctorId;
  final String userId;
  final String areaId;
  final String areaName;
  final DateTime createdAt;
  final bool uploaded;
  final String? lastError;

  Map<String, dynamic> toMap() {
    return {
      'localId': localId,
      'doctorLocalId': doctorLocalId,
      'serverDoctorId': serverDoctorId,
      'userId': userId,
      'areaId': areaId,
      'areaName': areaName,
      'createdAt': createdAt.toIso8601String(),
      'uploaded': uploaded ? 1 : 0,
      'lastError': lastError,
    };
  }

  factory PendingAreaAssignmentModel.fromMap(Map<String, dynamic> map) {
    return PendingAreaAssignmentModel(
      localId: map['localId'].toString(),
      doctorLocalId: map['doctorLocalId'].toString(),
      serverDoctorId: _nullableString(map['serverDoctorId']),
      userId: map['userId'].toString(),
      areaId: map['areaId'].toString(),
      areaName: map['areaName']?.toString() ?? '',
      createdAt: DateTime.parse(map['createdAt'].toString()),
      uploaded: map['uploaded'] == true || map['uploaded'] == 1,
      lastError: _nullableString(map['lastError']),
    );
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
