class PerformancePaginationModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PerformancePaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PerformancePaginationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PerformancePaginationModel(
        total: 0,
        page: 1,
        limit: 100,
        totalPages: 0,
      );
    }

    return PerformancePaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 100,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}