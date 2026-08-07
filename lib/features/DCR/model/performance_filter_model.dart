import 'state_model.dart';

class PerformanceFilterModel {
  final String applied;
  final String startDate;
  final String endDate;
  final String visitType;
  final StateModel? state;

  const PerformanceFilterModel({
    required this.applied,
    required this.startDate,
    required this.endDate,
    required this.visitType,
    this.state,
  });

  factory PerformanceFilterModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PerformanceFilterModel(
        applied: '',
        startDate: '',
        endDate: '',
        visitType: '',
      );
    }

    return PerformanceFilterModel(
      applied: json['applied'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      visitType: json['visit_type'] ?? '',
      state: json['state'] == null
          ? null
          : StateModel.fromJson(json['state']),
    );
  }
}