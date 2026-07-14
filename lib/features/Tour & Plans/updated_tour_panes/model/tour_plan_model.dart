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

  factory TourPlanModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return TourPlanModel(
      id: json["id"] ?? "",

      userId: json["user_id"] ?? "",

      month: json["month"] ?? 0,

      year: json["year"] ?? 0,

      status: json["status"] ?? "",

      approvedById: json["approved_by_id"],

      approvedByName: json["approved_by_name"],

      approvedByRole: json["approved_by_role"],

      comments: json["comments"],

      createdAt: DateTime.parse(
        json["created_at"],
      ),

      updatedAt: DateTime.parse(
        json["updated_at"],
      ),

      days: (json["days"] as List? ?? [])
          .map(
            (e) => TourPlanDayModel.fromJson(e),
      )
          .toList(),
    );
  }

  ///-------------------------------------------------------
  /// Copy With
  ///-------------------------------------------------------

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

      approvedById:
      approvedById ?? this.approvedById,

      approvedByName:
      approvedByName ?? this.approvedByName,

      approvedByRole:
      approvedByRole ?? this.approvedByRole,

      comments: comments ?? this.comments,

      createdAt:
      createdAt ?? this.createdAt,

      updatedAt:
      updatedAt ?? this.updatedAt,

      days: days ?? this.days,
    );
  }

  ///-------------------------------------------------------
  /// Status Helpers
  ///-------------------------------------------------------

  bool get isDraft =>
      status == "Draft";

  bool get isSubmitted =>
      status == "Submitted";

  bool get isApproved =>
      status == "Approved";

  bool get isReturned =>
      status == "Returned";

  bool get canEdit =>
      isDraft || isReturned;

  bool get isReadOnly =>
      isSubmitted || isApproved;

  ///-------------------------------------------------------
  /// UI Helpers
  ///-------------------------------------------------------

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
      'December'
    ];

    return "${months[month]} $year";
  }

  String get title =>
      "$monthName Tour Plan";

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