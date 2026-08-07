import 'dcr_visit_model.dart';
import 'performance_filter_model.dart';
import 'performance_pagination_model.dart';
import 'performance_summary_model.dart';

class PerformanceDashboardModel {
  final bool success;

  final String message;

  final PerformanceFilterModel? filter;

  final PerformanceSummaryModel? summary;

  final PerformancePaginationModel? pagination;

  final List<DcrVisitModel> visits;

  const PerformanceDashboardModel({
    required this.success,
    required this.message,
    this.filter,
    this.summary,
    this.pagination,
    required this.visits,
  });

  factory PerformanceDashboardModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PerformanceDashboardModel(
      success: json["success"] ?? false,

      message: json["message"] ?? "",

      filter: json["filter"] == null
          ? null
          : PerformanceFilterModel.fromJson(
        json["filter"],
      ),

      summary: json["summary"] == null
          ? null
          : PerformanceSummaryModel.fromJson(
        json["summary"],
      ),

      pagination: json["pagination"] == null
          ? null
          : PerformancePaginationModel.fromJson(
        json["pagination"],
      ),

      visits: (json["data"] as List? ?? [])
          .map(
            (e) => DcrVisitModel.fromJson(e),
      )
          .toList(),
    );
  }
}