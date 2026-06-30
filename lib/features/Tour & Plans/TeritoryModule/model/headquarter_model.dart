import 'package:equatable/equatable.dart';

class HeadquarterModel extends Equatable {
  final String id;
  final String code;
  final String name;
  final String state;

  final double latitude;
  final double longitude;
  final double zoom;

  final bool active;

  const HeadquarterModel({
    required this.id,
    required this.code,
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.zoom,
    this.active = true,
  });

  HeadquarterModel copyWith({
    String? id,
    String? code,
    String? name,
    String? state,
    double? latitude,
    double? longitude,
    double? zoom,
    bool? active,
  }) {
    return HeadquarterModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoom: zoom ?? this.zoom,
      active: active ?? this.active,
    );
  }

  factory HeadquarterModel.fromJson(Map<String, dynamic> json) {
    return HeadquarterModel(
      id: json["id"],
      code: json["code"],
      name: json["name"],
      state: json["state"],
      latitude: (json["latitude"] as num).toDouble(),
      longitude: (json["longitude"] as num).toDouble(),
      zoom: (json["zoom"] as num).toDouble(),
      active: json["active"] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "name": name,
    "state": state,
    "latitude": latitude,
    "longitude": longitude,
    "zoom": zoom,
    "active": active,
  };

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    state,
    latitude,
    longitude,
    zoom,
    active,
  ];
}