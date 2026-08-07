class ChemistLocationModel {
  final String id;
  final String chemistCode;
  final String chemistName;
  final String areaId;
  final String headquarterId;
  final String shopName;
  final String category;
  final double latitude;
  final double longitude;
  final bool active;

  ChemistLocationModel({
    required this.id,
    required this.chemistCode,
    required this.chemistName,
    required this.areaId,
    required this.headquarterId,
    required this.shopName,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.active,
  });

  factory ChemistLocationModel.fromJson(Map<String, dynamic> json) {
    return ChemistLocationModel(
      id: json["id"] ?? "",
      chemistCode: json["chemistCode"] ?? "",
      chemistName: json["chemistName"] ?? "",
      areaId: json["areaId"] ?? "",
      headquarterId: json["headquarterId"] ?? "",
      shopName: json["shopName"] ?? "",
      category: json["category"] ?? "",
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
      active: json["active"] ?? false,
    );
  }
}