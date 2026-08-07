class StockistLocationModel {
  final String id;
  final String stockistCode;
  final String stockistName;
  final String areaId;
  final String headquarterId;
  final String firmName;
  final String category;
  final double latitude;
  final double longitude;
  final bool active;

  StockistLocationModel({
    required this.id,
    required this.stockistCode,
    required this.stockistName,
    required this.areaId,
    required this.headquarterId,
    required this.firmName,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.active,
  });

  factory StockistLocationModel.fromJson(Map<String, dynamic> json) {
    return StockistLocationModel(
      id: json["id"] ?? "",
      stockistCode: json["stockistCode"] ?? "",
      stockistName: json["stockistName"] ?? "",
      areaId: json["areaId"] ?? "",
      headquarterId: json["headquarterId"] ?? "",
      firmName: json["firmName"] ?? "",
      category: json["category"] ?? "",
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
      active: json["active"] ?? false,
    );
  }
}