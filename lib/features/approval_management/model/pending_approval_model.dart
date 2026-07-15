import '../../Tour & Plans/updated_tour_panes/model/tour_plan_day_model.dart';


class PendingApprovalModel {
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

  final PendingApprovalUser user;

  final List<TourPlanDayModel> days;

  PendingApprovalModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.year,
    required this.status,
    this.approvedById,
    this.approvedByName,
    this.approvedByRole,
    this.comments,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.days,
  });

  factory PendingApprovalModel.fromJson(Map<String, dynamic> json) {
    return PendingApprovalModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      status: json['status'] ?? '',

      approvedById: json['approved_by_id'],
      approvedByName: json['approved_by_name'],
      approvedByRole: json['approved_by_role'],

      comments: json['comments'],

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      user: PendingApprovalUser.fromJson(json['user'] ?? {}),

      days: (json['days'] as List? ?? [])
          .map((e) => TourPlanDayModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "month": month,
      "year": year,
      "status": status,
      "approved_by_id": approvedById,
      "approved_by_name": approvedByName,
      "approved_by_role": approvedByRole,
      "comments": comments,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "user": user.toJson(),
      "days": days.map((e) => e.toJson()).toList(),
    };
  }
}

class PendingApprovalUser {
  final String id;
  final String name;
  final String role;
  final String? employeeCode;

  PendingApprovalUser({
    required this.id,
    required this.name,
    required this.role,
    this.employeeCode,
  });

  factory PendingApprovalUser.fromJson(Map<String, dynamic> json) {
    return PendingApprovalUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      employeeCode: json['employee_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "role": role,
      "employee_code": employeeCode,
    };
  }
}