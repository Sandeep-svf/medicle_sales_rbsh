class CollaborationRequestModel {
  final String id;
  final String tourPlanId;

  final DateTime date;

  final String dayType;

  final String? jointWorkWithUserId;

  final String collaborationStatus;

  final String? beatId1;
  final String? beatId2;

  final String changeRequestStatus;

  final String? changeRequestReason;

  final String? changeRequestBeatId1;
  final String? changeRequestBeatId2;

  final String? changeRequestDayType;
  final String? changeRequestComments;

  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  final CollaborationTourPlan tourPlan;

  CollaborationRequestModel({
    required this.id,
    required this.tourPlanId,
    required this.date,
    required this.dayType,
    this.jointWorkWithUserId,
    required this.collaborationStatus,
    this.beatId1,
    this.beatId2,
    required this.changeRequestStatus,
    this.changeRequestReason,
    this.changeRequestBeatId1,
    this.changeRequestBeatId2,
    this.changeRequestDayType,
    this.changeRequestComments,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.tourPlan,
  });

  factory CollaborationRequestModel.fromJson(Map<String, dynamic> json) {
    return CollaborationRequestModel(
      id: json['id'] ?? '',
      tourPlanId: json['tour_plan_id'] ?? '',

      date: DateTime.parse(json['date']),

      dayType: json['day_type'] ?? '',

      jointWorkWithUserId: json['joint_work_with_user_id'],

      collaborationStatus: json['collaboration_status'] ?? '',

      beatId1: json['beat_id_1'],
      beatId2: json['beat_id_2'],

      changeRequestStatus: json['change_request_status'] ?? '',

      changeRequestReason: json['change_request_reason'],

      changeRequestBeatId1: json['change_request_beat_id_1'],
      changeRequestBeatId2: json['change_request_beat_id_2'],

      changeRequestDayType: json['change_request_day_type'],
      changeRequestComments: json['change_request_comments'],

      notes: json['notes'],

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      tourPlan: CollaborationTourPlan.fromJson(json['tourPlan'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tour_plan_id": tourPlanId,
      "date": date.toIso8601String(),
      "day_type": dayType,
      "joint_work_with_user_id": jointWorkWithUserId,
      "collaboration_status": collaborationStatus,
      "beat_id_1": beatId1,
      "beat_id_2": beatId2,
      "change_request_status": changeRequestStatus,
      "change_request_reason": changeRequestReason,
      "change_request_beat_id_1": changeRequestBeatId1,
      "change_request_beat_id_2": changeRequestBeatId2,
      "change_request_day_type": changeRequestDayType,
      "change_request_comments": changeRequestComments,
      "notes": notes,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "tourPlan": tourPlan.toJson(),
    };
  }
}

class CollaborationTourPlan {
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

  final CollaborationUser? user;

  CollaborationTourPlan({
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
    this.user,
  });

  factory CollaborationTourPlan.fromJson(Map<String, dynamic> json) {
    return CollaborationTourPlan(
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
      user: json['user'] != null
          ? CollaborationUser.fromJson(json['user'])
          : null,
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
      "user": user?.toJson(),
    };
  }
}

class CollaborationUser {
  final String id;
  final String name;
  final String role;
  final String? employeeCode;

  CollaborationUser({
    required this.id,
    required this.name,
    required this.role,
    this.employeeCode,
  });

  factory CollaborationUser.fromJson(Map<String, dynamic> json) {
    return CollaborationUser(
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