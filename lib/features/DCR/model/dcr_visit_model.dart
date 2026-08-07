import 'chemist_model.dart';
import 'doctor_model.dart';
import 'stockist_model.dart';
import 'user_model.dart';

class DcrVisitModel {
  final String id;
  final String visitType;
  final String date;
  final String notes;

  final bool confirmed;

  final double? latitude;
  final double? longitude;

  final DoctorModel? doctor;
  final ChemistModel? chemist;
  final StockistModel? stockist;
  final UserModel? user;

  const DcrVisitModel({
    required this.id,
    required this.visitType,
    required this.date,
    required this.notes,
    required this.confirmed,
    this.latitude,
    this.longitude,
    this.doctor,
    this.chemist,
    this.stockist,
    this.user,
  });

  factory DcrVisitModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DcrVisitModel(
        id: '',
        visitType: '',
        date: '',
        notes: '',
        confirmed: false,
      );
    }

    return DcrVisitModel(
      id: json['id'] ?? '',

      visitType: json['visit_type'] ?? '',

      date: json['date'] ?? '',

      notes: json['notes'] ?? '',

      confirmed: json['confirmed'] ?? false,

      latitude: _toDouble(json['latitude']),

      longitude: _toDouble(json['longitude']),

      doctor: json['DoctorInfo'] == null
          ? null
          : DoctorModel.fromJson(json['DoctorInfo']),

      chemist: json['Chemist'] == null
          ? null
          : ChemistModel.fromJson(json['Chemist']),

      stockist: json['Stockist'] == null
          ? null
          : StockistModel.fromJson(json['Stockist']),

      user: json['User'] == null
          ? null
          : UserModel.fromJson(json['User']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    return double.tryParse(value.toString());
  }
}