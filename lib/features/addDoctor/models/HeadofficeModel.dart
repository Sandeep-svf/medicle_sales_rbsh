import 'dart:convert';

class HeadofficeModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  HeadofficeModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory HeadofficeModel.fromJson(Map<String, dynamic> json) => HeadofficeModel(
    id: json["_id"],
    name: json["name"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

List<HeadofficeModel> cityFromJson(String str) =>
    List<HeadofficeModel>.from(json.decode(str).map((x) => HeadofficeModel.fromJson(x)));

String cityToJson(List<HeadofficeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
