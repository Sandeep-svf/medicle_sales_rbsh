class BoundaryPoint {
  final String name;
  final String pincode;
  final double latitude;
  final double longitude;

  const BoundaryPoint({
    required this.name,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  factory BoundaryPoint.fromJson(Map<String, dynamic> json) {
    return BoundaryPoint(
      name: json["name"] ?? "",
      pincode: json["pincode"] ?? "",
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "pincode": pincode,
    "latitude": latitude,
    "longitude": longitude,
  };
}