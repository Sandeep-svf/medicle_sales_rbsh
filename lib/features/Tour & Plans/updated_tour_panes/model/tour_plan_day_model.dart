class TourPlanDayModel {
  final String id;
  final String tourPlanId;

  final DateTime date;

  final String dayType;

  final String collaborationStatus;

  final String? jointWorkWithUserId;

  final String? beatId1;
  final String? beatId2;

  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  final Map<String, dynamic>? beat1;
  final Map<String, dynamic>? beat2;
  final Map<String, dynamic>? jointWorkWith;

  const TourPlanDayModel({
    required this.id,
    required this.tourPlanId,
    required this.date,
    required this.dayType,
    required this.collaborationStatus,
    required this.createdAt,
    required this.updatedAt,
    this.jointWorkWithUserId,
    this.beatId1,
    this.beatId2,
    this.notes,
    this.beat1,
    this.beat2,
    this.jointWorkWith,
  });

  factory TourPlanDayModel.fromJson(Map<String, dynamic> json) {
    return TourPlanDayModel(
      id: json["id"]?.toString() ?? "",

      tourPlanId: json["tour_plan_id"]?.toString() ?? "",

      date: json["date"] != null
          ? DateTime.parse(json["date"])
          : DateTime.now(),

      dayType: json["day_type"]?.toString() ?? "",

      collaborationStatus:
      json["collaboration_status"]?.toString() ?? "None",

      jointWorkWithUserId:
      json["joint_work_with_user_id"]?.toString(),

      beatId1:
      json["beat_id_1"]?.toString(),

      beatId2:
      json["beat_id_2"]?.toString(),

      notes:
      json["notes"]?.toString(),

      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),

      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : DateTime.now(),

      beat1: json["beat1"] is Map<String, dynamic>
          ? json["beat1"] as Map<String, dynamic>
          : null,

      beat2: json["beat2"] is Map<String, dynamic>
          ? json["beat2"] as Map<String, dynamic>
          : null,

      jointWorkWith: json["jointWorkWith"] is Map<String, dynamic>
          ? json["jointWorkWith"] as Map<String, dynamic>
          : null,
    );
  }

  TourPlanDayModel copyWith({
    String? dayType,
    String? collaborationStatus,
    String? beatId1,
    String? beatId2,
    String? jointWorkWithUserId,
    String? notes,
  }) {
    return TourPlanDayModel(
      id: id,
      tourPlanId: tourPlanId,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
      dayType: dayType ?? this.dayType,
      collaborationStatus:
      collaborationStatus ?? this.collaborationStatus,
      beatId1: beatId1 ?? this.beatId1,
      beatId2: beatId2 ?? this.beatId2,
      jointWorkWithUserId:
      jointWorkWithUserId ?? this.jointWorkWithUserId,
      notes: notes ?? this.notes,
      beat1: beat1,
      beat2: beat2,
      jointWorkWith: jointWorkWith,
    );
  }
}