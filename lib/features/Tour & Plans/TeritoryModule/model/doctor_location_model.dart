import 'package:equatable/equatable.dart';

import '../utils/enumsclass.dart';



class DoctorLocationModel extends Equatable {
  final String id;
  final String doctorCode;
  final String doctorName;

  final String areaId;
  final String headquarterId;

  final String clinicName;
  final String speciality;

  final DoctorCategory category;

  final double latitude;
  final double longitude;

  final VisitStatus visitStatus;

  final bool active;

  const DoctorLocationModel({
    required this.id,
    required this.doctorCode,
    required this.doctorName,
    required this.areaId,
    required this.headquarterId,
    required this.clinicName,
    required this.speciality,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.visitStatus = VisitStatus.pending,
    this.active = true,
  });

  DoctorLocationModel copyWith({
    String? id,
    String? doctorCode,
    String? doctorName,
    String? areaId,
    String? headquarterId,
    String? clinicName,
    String? speciality,
    DoctorCategory? category,
    double? latitude,
    double? longitude,
    VisitStatus? visitStatus,
    bool? active,
  }) {
    return DoctorLocationModel(
      id: id ?? this.id,
      doctorCode: doctorCode ?? this.doctorCode,
      doctorName: doctorName ?? this.doctorName,
      areaId: areaId ?? this.areaId,
      headquarterId: headquarterId ?? this.headquarterId,
      clinicName: clinicName ?? this.clinicName,
      speciality: speciality ?? this.speciality,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      visitStatus: visitStatus ?? this.visitStatus,
      active: active ?? this.active,
    );
  }

  factory DoctorLocationModel.fromJson(Map<String, dynamic> json) {
    return DoctorLocationModel(
      id: json["id"],
      doctorCode: json["doctorCode"],
      doctorName: json["doctorName"],
      areaId: json["areaId"],
      headquarterId: json["headquarterId"],
      clinicName: json["clinicName"],
      speciality: json["speciality"],
      category: DoctorCategory.values.firstWhere(
            (e) => e.name == json["category"],
      ),
      latitude: (json["latitude"] as num).toDouble(),
      longitude: (json["longitude"] as num).toDouble(),
      visitStatus: VisitStatus.values.firstWhere(
            (e) => e.name == json["visitStatus"],
        orElse: () => VisitStatus.pending,
      ),
      active: json["active"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "doctorCode": doctorCode,
      "doctorName": doctorName,
      "areaId": areaId,
      "headquarterId": headquarterId,
      "clinicName": clinicName,
      "speciality": speciality,
      "category": category.name,
      "latitude": latitude,
      "longitude": longitude,
      "visitStatus": visitStatus.name,
      "active": active,
    };
  }

  @override
  List<Object?> get props => [
    id,
    doctorCode,
    doctorName,
    areaId,
    headquarterId,
    clinicName,
    speciality,
    category,
    latitude,
    longitude,
    visitStatus,
    active,
  ];
}