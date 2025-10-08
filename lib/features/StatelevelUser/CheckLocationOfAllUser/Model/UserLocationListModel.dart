import 'dart:convert';

class UserLocationListModel {
  final String? country;
  final bool isSuspicious;
  final String id;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String deviceId;
  final double accuracy;
  final int batteryLevel;
  final String networkType;
  final bool isActive;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  UserLocationListModel({
    this.country,
    required this.isSuspicious,
    required this.id,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.deviceId,
    required this.accuracy,
    required this.batteryLevel,
    required this.networkType,
    required this.isActive,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory UserLocationListModel.fromJson(Map<String, dynamic> json) {
    return UserLocationListModel(
      country: json['country'] as String?,
      isSuspicious: json['isSuspicious'] ?? false,
      id: json['_id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      deviceId: json['deviceId'] as String,
      accuracy: json['accuracy'] as double,
      batteryLevel: json['batteryLevel'] as int,
      networkType: json['networkType'] as String,
      isActive: json['isActive'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'isSuspicious': isSuspicious,
      '_id': id,
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'deviceId': deviceId,
      'accuracy': accuracy,
      'batteryLevel': batteryLevel,
      'networkType': networkType,
      'isActive': isActive,
      'timestamp': timestamp.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

// Example Usage
void main() {
  String jsonStr = '''<Your JSON String Here>''';
  Map<String, dynamic> jsonMap = json.decode(jsonStr);

  // If this JSON represents multiple user locations
  List<UserLocationListModel> locationList = List<UserLocationListModel>.from(
      jsonMap['location']?.map((x) => UserLocationListModel.fromJson(x))
  );

  print(locationList);
}
