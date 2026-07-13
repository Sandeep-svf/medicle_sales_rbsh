import 'package:equatable/equatable.dart';

class BeatModel extends Equatable {
  final String id;

  final String headquarterId;

  final String beatName;

  /// Hex color from API (Example: #FF5733)
  final String color;

  final int doctorCount;

  final int areaCount;

  final DateTime createdAt;

  final String createdBy;

  final bool active;

  const BeatModel({
    required this.id,
    required this.headquarterId,
    required this.beatName,
    required this.color,
    required this.createdAt,
    required this.createdBy,
    this.doctorCount = 0,
    this.areaCount = 0,
    this.active = true,
  });

  BeatModel copyWith({
    String? id,
    String? headquarterId,
    String? beatName,
    String? color,
    int? doctorCount,
    int? areaCount,
    DateTime? createdAt,
    String? createdBy,
    bool? active,
  }) {
    return BeatModel(
      id: id ?? this.id,
      headquarterId: headquarterId ?? this.headquarterId,
      beatName: beatName ?? this.beatName,
      color: color ?? this.color,
      doctorCount: doctorCount ?? this.doctorCount,
      areaCount: areaCount ?? this.areaCount,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      active: active ?? this.active,
    );
  }

  factory BeatModel.fromJson(Map<String, dynamic> json) {
    return BeatModel(
      id: json["id"] ?? "",

      headquarterId: json["headquarterId"] ?? "",

      beatName: json["beatName"] ?? "",

      color: json["color"] ?? "#FF0000",

      doctorCount: json["doctorCount"] ?? 0,

      areaCount: json["areaCount"] ?? 0,

      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),

      createdBy: json["createdBy"] ?? "",

      active: json["active"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "headquarterId": headquarterId,
      "beatName": beatName,
      "color": color,
      "doctorCount": doctorCount,
      "areaCount": areaCount,
      "createdAt": createdAt.toIso8601String(),
      "createdBy": createdBy,
      "active": active,
    };
  }



  @override
  List<Object?> get props => [
    id,
    headquarterId,
    beatName,
    color,
    doctorCount,
    areaCount,
    createdAt,
    createdBy,
    active,
  ];
}