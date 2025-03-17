import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  // ✅ Parse entire API response JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["user"]?["id"] ?? "",
      name: json["user"]?["name"] ?? "",
      email: json["user"]?["email"] ?? "",
      role: json["user"]?["role"] ?? "",
      token: json["token"] ?? "",
    );
  }

  // ✅ Convert UserModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      "user": {
        "id": id,
        "name": name,
        "email": email,
        "role": role,
      },
      "token": token,
    };
  }

  // ✅ Convert UserModel object to JSON String (for SharedPreferences)
  String toJsonString() => jsonEncode(toJson());

  // ✅ Convert JSON String to UserModel object
  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}
