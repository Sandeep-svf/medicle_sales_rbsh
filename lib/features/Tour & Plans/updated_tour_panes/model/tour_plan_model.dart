import 'tour_plan_day_model.dart';

class TourPlanModel {
  final String id;
  final String userId;
  final int month;
  final int year;
  final String status;
  final String? approvedById;
  final String? approvedByName;
  final String? approvedByRole;
  final String? comments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TourPlanDayModel> days;

  const TourPlanModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.year,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.days,
    this.approvedById,
    this.approvedByName,
    this.approvedByRole,
    this.comments,
  });

  factory TourPlanModel.fromJson(Map<String, dynamic> json) {
    final createdAt = _parseDate(json["created_at"]);
    final updatedAt = _parseDate(json["updated_at"]);

    return TourPlanModel(
      id: json["id"]?.toString() ?? "",
      userId: json["user_id"]?.toString() ?? "",
      month: _parseInt(json["month"]),
      year: _parseInt(json["year"]),
      status: json["status"]?.toString() ?? "",
      approvedById: _nullableString(json["approved_by_id"]),
      approvedByName: _nullableString(json["approved_by_name"]),
      approvedByRole: _nullableString(json["approved_by_role"]),
      comments: _nullableString(json["comments"]),
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: updatedAt ?? createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      days: (json["days"] as List? ?? const [])
          .whereType<Map>()
          .map((e) => TourPlanDayModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  TourPlanModel copyWith({
    String? id,
    String? userId,
    int? month,
    int? year,
    String? status,
    String? approvedById,
    String? approvedByName,
    String? approvedByRole,
    String? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TourPlanDayModel>? days,
  }) {
    return TourPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      year: year ?? this.year,
      status: status ?? this.status,
      approvedById: approvedById ?? this.approvedById,
      approvedByName: approvedByName ?? this.approvedByName,
      approvedByRole: approvedByRole ?? this.approvedByRole,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      days: days ?? this.days,
    );
  }

  bool get isDraft => status == "Draft";
  bool get isSubmitted => status == "Submitted";
  bool get isApproved => status == "Approved";
  bool get isReturned => status == "Returned";
  bool get canEdit => isDraft || isReturned;
  bool get isReadOnly => isSubmitted || isApproved;

  String get monthName {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12 || year <= 0) {
      return "Unknown Month";
    }

    return "${months[month]} $year";
  }

  String get title => "$monthName Tour Plan";

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '');
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  @override
  String toString() {
    return "TourPlanModel("
        "id: $id, "
        "month: $month, "
        "year: $year, "
        "status: $status, "
        "days: ${days.length}"
        ")";
  }
}
