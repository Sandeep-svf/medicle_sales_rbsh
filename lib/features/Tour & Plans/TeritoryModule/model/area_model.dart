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
      beatIds: beatIds ?? this.beatIds,
      selected: selected ?? this.selected,
      visible: visible ?? this.visible,
    );
  }

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json["id"],
      headquarterId: json["headquarterId"],
      postOffice: json["postOffice"],
      pincode: json["pincode"],
      latitude: (json["latitude"] as num).toDouble(),
      longitude: (json["longitude"] as num).toDouble(),
      radius: (json["radius"] ?? 700).toDouble(),
      doctorCount: json["doctorCount"] ?? 0,
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
    beatIds,
    selected,
    visible,
  ];
}