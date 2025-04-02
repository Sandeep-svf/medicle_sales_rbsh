import 'dart:convert';

class SalesData {
  String? id;
  Doctor? doctor;
  User user;
  DateTime date;
  String? notes;
  bool confirmed;
  DateTime createdAt;
  DateTime updatedAt;

  SalesData({
    this.id,
    this.doctor,
    required this.user,
    required this.date,
    this.notes,
    required this.confirmed,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON constructor
  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      id: json['_id'] as String?,
      doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
      user: User.fromJson(json['user']),
      date: DateTime.parse(json['date']),
      notes: json['notes'] as String?,
      confirmed: json['confirmed'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'doctor': doctor?.toJson(),
      'user': user.toJson(),
      'date': date.toIso8601String(),
      'notes': notes,
      'confirmed': confirmed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Doctor {
  String? id;
  String? name;
  String? specialization;

  Doctor({
    this.id,
    this.name,
    this.specialization,
  });

  // From JSON constructor
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      specialization: json['specialization'] as String?,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'specialization': specialization,
    };
  }
}

class User {
  String id;
  String name;

  User({
    required this.id,
    required this.name,
  });

  // From JSON constructor
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}
