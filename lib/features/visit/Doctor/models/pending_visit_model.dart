class PendingVisitModel {
  final String visitId;
  final double userLatitude;
  final double userLongitude;
  final String notes;
  final List<String> productIds;
  final DateTime createdAt;

  PendingVisitModel({
    required this.visitId,
    required this.userLatitude,
    required this.userLongitude,
    required this.notes,
    required this.productIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'visitId': visitId,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'notes': notes,
      'productIds': productIds.join(','),
      'createdAt': createdAt.toIso8601String(),
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
      productIds: map['productIds'] == null ||
          map['productIds'].toString().isEmpty
          ? []
          : map['productIds'].toString().split(','),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}