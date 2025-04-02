
class VisitSalesLogModel {
  final String id;
  final Doctor? doctor;
  final User user;
  final DateTime date;
  final String? notes;
  late final bool confirmed;
  final DateTime createdAt;
  final DateTime updatedAt;

  VisitSalesLogModel({
    required this.id,
    this.doctor,
    required this.user,
    required this.date,
    this.notes,
    required this.confirmed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VisitSalesLogModel.fromJson(Map<String, dynamic> json) {
    return VisitSalesLogModel(
      id: json["_id"] ?? "",
      doctor: json["doctor"] != null ? Doctor.fromJson(json["doctor"]) : null,
      user: User.fromJson(json["user"]),
      date: DateTime.parse(json["date"]),
      notes: json["notes"] ?? "No Notes",
      confirmed: json["confirmed"] ?? false,
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "doctor": doctor?.toJson(),
      "user": user.toJson(),
      "date": date.toIso8601String(),
      "notes": notes,
      "confirmed": confirmed,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class Doctor {
  final String? id;
  final String? name;
  final String? specialization;

  Doctor({
    this.id,
    this.name,
    this.specialization,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json["_id"],
      name: json["name"],
      specialization: json["specialization"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "specialization": specialization,
    };
  }
}

class User {
  final String id;
  final String name;

  User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
    };
  }
}
