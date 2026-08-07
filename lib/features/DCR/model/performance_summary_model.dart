class PerformanceSummaryModel {
  final int totalVisits;
  final int doctorVisits;
  final int chemistVisits;
  final int stockistVisits;
  final int activeUsers;
  final int jurisdictionUsers;

  const PerformanceSummaryModel({
    required this.totalVisits,
    required this.doctorVisits,
    required this.chemistVisits,
    required this.stockistVisits,
    required this.activeUsers,
    required this.jurisdictionUsers,
  });

  factory PerformanceSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PerformanceSummaryModel(
        totalVisits: 0,
        doctorVisits: 0,
        chemistVisits: 0,
        stockistVisits: 0,
        activeUsers: 0,
        jurisdictionUsers: 0,
      );
    }

    return PerformanceSummaryModel(
      totalVisits: json['total_visits'] ?? 0,
      doctorVisits: json['doctor_visits_count'] ?? 0,
      chemistVisits: json['chemist_visits_count'] ?? 0,
      stockistVisits: json['stockist_visits_count'] ?? 0,
      activeUsers: json['total_active_users'] ?? 0,
      jurisdictionUsers: json['total_jurisdiction_users'] ?? 0,
    );
  }
}