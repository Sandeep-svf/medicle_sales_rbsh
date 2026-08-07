class PerformanceModel {
  final String id;
  final String employeeCode;
  final String name;

  final int doctorScheduled;
  final int doctorConfirmed;

  final int chemistScheduled;
  final int chemistConfirmed;

  final int stockistScheduled;
  final int stockistConfirmed;

  const PerformanceModel({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.doctorScheduled,
    required this.doctorConfirmed,
    required this.chemistScheduled,
    required this.chemistConfirmed,
    required this.stockistScheduled,
    required this.stockistConfirmed,
  });

  double get doctorCoverage =>
      doctorScheduled == 0 ? 0 : doctorConfirmed / doctorScheduled;

  double get chemistCoverage =>
      chemistScheduled == 0 ? 0 : chemistConfirmed / chemistScheduled;

  double get stockistCoverage =>
      stockistScheduled == 0 ? 0 : stockistConfirmed / stockistScheduled;

  double get overallCoverage {
    final scheduled =
        doctorScheduled + chemistScheduled + stockistScheduled;

    final confirmed =
        doctorConfirmed + chemistConfirmed + stockistConfirmed;

    if (scheduled == 0) return 0;

    return confirmed / scheduled;
  }
}