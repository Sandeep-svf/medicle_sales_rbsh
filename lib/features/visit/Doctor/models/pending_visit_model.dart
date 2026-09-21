class PendingVisitModel {
  final String visitId;
  final double userLatitude;
  final double userLongitude;
  final String notes;
  final List<String> productIds;
  final DateTime createdAt;
  final String? localScheduleId;
  final String? serverVisitId;

  PendingVisitModel({
    required this.visitId,
    required this.userLatitude,
    required this.userLongitude,
    required this.notes,
    required this.productIds,
    required this.createdAt,
    this.localScheduleId,
    this.serverVisitId,
  });

  String get uploadVisitId => serverVisitId ?? visitId;

  PendingVisitModel copyWith({
    String? visitId,
    String? serverVisitId,
  }) {
    return PendingVisitModel(
      visitId: visitId ?? this.visitId,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      notes: notes,
      productIds: List<String>.from(productIds),
      createdAt: createdAt,
      localScheduleId: localScheduleId,
      serverVisitId: serverVisitId ?? this.serverVisitId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitId': visitId,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'notes': notes,
      'productIds': productIds.join(','),
      'createdAt': createdAt.toIso8601String(),
      'localScheduleId': localScheduleId,
      'serverVisitId': serverVisitId,
    };
  }

  factory PendingVisitModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return PendingVisitModel(
      visitId: map['visitId'],
      userLatitude: map['userLatitude'],
      userLongitude: map['userLongitude'],
      notes: map['notes'] ?? '',
      productIds:
          map['productIds'] == null || map['productIds'].toString().isEmpty
              ? []
              : map['productIds'].toString().split(','),
      createdAt: DateTime.parse(map['createdAt']),
      localScheduleId: _nullableString(map['localScheduleId']),
      serverVisitId: _nullableString(map['serverVisitId']),
    );
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
