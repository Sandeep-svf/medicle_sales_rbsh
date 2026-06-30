import 'package:equatable/equatable.dart';

class BeatAreaModel extends Equatable {
  final String beatId;

  final String areaId;

  const BeatAreaModel({
    required this.beatId,
    required this.areaId,
  });

  BeatAreaModel copyWith({
    String? beatId,
    String? areaId,
  }) {
    return BeatAreaModel(
      beatId: beatId ?? this.beatId,
      areaId: areaId ?? this.areaId,
    );
  }

  factory BeatAreaModel.fromJson(Map<String, dynamic> json) {
    return BeatAreaModel(
      beatId: json["beatId"],
      areaId: json["areaId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "beatId": beatId,
      "areaId": areaId,
    };
  }

  @override
  List<Object?> get props => [
    beatId,
    areaId,
  ];
}