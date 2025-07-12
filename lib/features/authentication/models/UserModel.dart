import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;
  final String headOfficeId; //  changed

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    required this.headOfficeId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["user"]?["id"] ?? "",
      name: json["user"]?["name"] ?? "",
      email: json["user"]?["email"] ?? "",
      role: json["user"]?["role"] ?? "",
      token: json["token"] ?? "",
      headOfficeId: json["user"]?["headOffice"] ?? "", // <-- fix here
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user": {
        "id": id,
        "name": name,
        "email": email,
        "role": role,
        "headOffice": headOfficeId, // optional: include for consistency
      },
      "token": token,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}
