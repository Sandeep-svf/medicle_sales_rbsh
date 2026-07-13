import 'package:equatable/equatable.dart';

class AreaModel extends Equatable {
  final String id;
  final String headquarterId;

  final String postOffice;
  final String pincode;

  final double latitude;
  final double longitude;

  final double radius;

  final int doctorCount;

  final int chemistCount;

  final int stockistCount;

  /// Backend already sends the colors for this area.
  final List<String> colors;

  /// Keep for compatibility with existing UI.
  final List<String> beatIds;

  final bool selected;
  final bool visible;

  const AreaModel({
    required this.id,
    required this.headquarterId,
    required this.postOffice,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.radius = 700,
    this.doctorCount = 0,
    this.chemistCount = 0,
    this.stockistCount = 0,
    this.colors = const [],
    this.beatIds = const [],
    this.selected = false,
    this.visible = true,
  });

  AreaModel copyWith({
    String? id,
    String? headquarterId,
    String? postOffice,
    String? pincode,
    double? latitude,
    double? longitude,
    double? radius,
    int? doctorCount,
    int? chemistCount,
    int? stockistCount,
    List<String>? colors,
    List<String>? beatIds,
    bool? selected,
    bool? visible,
  }) {
    return AreaModel(
      id: id ?? this.id,
      headquarterId: headquarterId ?? this.headquarterId,
      postOffice: postOffice ?? this.postOffice,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      doctorCount: doctorCount ?? this.doctorCount,
      chemistCount: chemistCount ?? this.chemistCount,
      stockistCount: stockistCount ?? this.stockistCount,
      colors: colors ?? this.colors,
      beatIds: beatIds ?? this.beatIds,
      selected: selected ?? this.selected,
      visible: visible ?? this.visible,
    );
  }

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json["id"] ?? "",
      headquarterId: json["headquarterId"] ?? "",
      postOffice: json["postOffice"] ?? "",
      pincode: json["pincode"] ?? "",
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0,
      radius: (json["radius"] as num?)?.toDouble() ?? 700,
      doctorCount: json["doctorCount"] ?? 0,
      chemistCount: json["chemistCount"] ?? 0,
      stockistCount: json["stockistCount"] ?? 0,
      colors: List<String>.from(json["colors"] ?? []),
      beatIds: List<String>.from(json["beatIds"] ?? []),
      selected: json["selected"] ?? false,
      visible: json["visible"] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "headquarterId": headquarterId,
    "postOffice": postOffice,
    "pincode": pincode,
    "latitude": latitude,
    "longitude": longitude,
    "radius": radius,
    "doctorCount": doctorCount,
    "chemistCount": chemistCount,
    "stockistCount": stockistCount,
    "colors": colors,
    "beatIds": beatIds,
    "selected": selected,
    "visible": visible,
  };

  @override
  List<Object?> get props => [
    id,
    headquarterId,
    postOffice,
    pincode,
    latitude,
    longitude,
    radius,
    doctorCount,
    chemistCount,
    stockistCount,
    colors,
    beatIds,
    selected,
    visible,
  ];
}