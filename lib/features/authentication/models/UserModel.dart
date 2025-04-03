import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;
  final HeadOffice headOffice; // Added new field for headOffice

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    required this.headOffice, // Initialize the new field
  });

  //  Parse entire API response JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["user"]?["id"] ?? "",
      name: json["user"]?["name"] ?? "",
      email: json["user"]?["email"] ?? "",
      role: json["user"]?["role"] ?? "",
      token: json["token"] ?? "",
      headOffice: HeadOffice.fromJson(json["headOffice"] ?? {}), // Parse headOffice
    );
  }

  //  Convert UserModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      "user": {
        "id": id,
        "name": name,
        "email": email,
        "role": role,
      },
      "token": token,
      "headOffice": headOffice.toJson(), // Include headOffice data
    };
  }

  //  Convert UserModel object to JSON String (for SharedPreferences)
  String toJsonString() => jsonEncode(toJson());

  //  Convert JSON String to UserModel object
  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}

class HeadOffice {
  final String id;
  final String name;

  HeadOffice({
    required this.id,
    required this.name,
  });

  //  Parse headOffice data from JSON
  factory HeadOffice.fromJson(Map<String, dynamic> json) {
    return HeadOffice(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
    );
  }

  //  Convert HeadOffice object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}
