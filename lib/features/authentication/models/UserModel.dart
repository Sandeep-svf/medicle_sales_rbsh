import 'dart:convert';


class UserModel {
  final String? token;
  final User? user;

  UserModel({this.token, this.user});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool emailVerified;
  final List<HeadOffice>? headOffices;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.emailVerified,
    this.headOffices,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      emailVerified: json['emailVerified'] ?? false,
      headOffices: (json['headOffices'] as List?)
          ?.map((e) => HeadOffice.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'emailVerified': emailVerified,
      'headOffices': headOffices?.map((e) => e.toJson()).toList(),
    };
  }
}

class HeadOffice {
  final String? id;
  final String? name;

  HeadOffice({this.id, this.name});

  factory HeadOffice.fromJson(Map<String, dynamic> json) {
    return HeadOffice(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}



