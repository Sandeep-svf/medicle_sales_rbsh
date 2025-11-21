import '../../../utils/offline_model/BaseOfflineModel.dart';

class CityOfflineModel extends BaseOfflineModel {
  final String id;
  final String name;

  CityOfflineModel({
    required this.id,
    required this.name,
  });

  @override
  String get tableName => 'cities'; // Table name in SQLite

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory CityOfflineModel.fromJson(Map<String, dynamic> json) {
    return CityOfflineModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
    );
  }
}
