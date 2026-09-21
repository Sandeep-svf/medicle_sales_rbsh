class PendingDoctorLocationRequest {
  const PendingDoctorLocationRequest({
    required this.requestKey,
    required this.accountId,
    required this.localDoctorId,
    required this.requestedDoctorId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  final String requestKey;
  final String accountId;
  final String localDoctorId;
  final String requestedDoctorId;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'requestKey': requestKey,
        'accountId': accountId,
        'localDoctorId': localDoctorId,
        'requestedDoctorId': requestedDoctorId,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PendingDoctorLocationRequest.fromMap(Map<String, Object?> map) {
    return PendingDoctorLocationRequest(
      requestKey: map['requestKey']?.toString() ?? '',
      accountId: map['accountId']?.toString() ?? '',
      localDoctorId: map['localDoctorId']?.toString() ?? '',
      requestedDoctorId: map['requestedDoctorId']?.toString() ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt']?.toString() ?? ''),
    );
  }
}
