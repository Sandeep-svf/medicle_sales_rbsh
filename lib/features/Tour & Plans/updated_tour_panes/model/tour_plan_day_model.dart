class TourPlanDayModel {
  final String id;
  final String tourPlanId;

  final DateTime date;
  final String dayType;
  final String collaborationStatus;

  /// Primary joint work user
  final String? jointWorkWithUserId;

  /// Multiple joint work users
  final List<String> jointWorkUserIds;

  /// Handshake
  final String handshakeStatus;
  final DateTime? handshakeTime;
  final double? handshakeDistanceMeters;

  final double? handshakeUserLat;
  final double? handshakeUserLng;

  final double? handshakePartnerLat;
  final double? handshakePartnerLng;

  final String? handshakeVerifiedByUserId;

  /// Beats
  final String? beatId1;
  final String? beatId2;

  /// Change request
  final String changeRequestStatus;
  final String? changeRequestReason;

  final String? changeRequestBeatId1;
  final String? changeRequestBeatId2;

  final String? changeRequestDayType;
  final String? changeRequestComments;

  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Beat details
  final Map<String, dynamic>? beat1;
  final Map<String, dynamic>? beat2;

  /// Primary joint work user details
  final Map<String, dynamic>? jointWorkWith;

  /// Multiple joint work users
  final List<Map<String, dynamic>> jointWorkUsers;

  const TourPlanDayModel({
    required this.id,
    required this.tourPlanId,
    required this.date,
    required this.dayType,
    required this.collaborationStatus,
    required this.handshakeStatus,
    required this.createdAt,
    required this.updatedAt,

    this.jointWorkWithUserId,
    this.jointWorkUserIds = const [],

    this.handshakeTime,
    this.handshakeDistanceMeters,

    this.handshakeUserLat,
    this.handshakeUserLng,

    this.handshakePartnerLat,
    this.handshakePartnerLng,

    this.handshakeVerifiedByUserId,

    this.beatId1,
    this.beatId2,

    this.changeRequestStatus = "None",
    this.changeRequestReason,

    this.changeRequestBeatId1,
    this.changeRequestBeatId2,

    this.changeRequestDayType,
    this.changeRequestComments,

    this.notes,

    this.beat1,
    this.beat2,
    this.jointWorkWith,

    this.jointWorkUsers = const [],
  });

  factory TourPlanDayModel.fromJson(
      Map<String, dynamic>? json,
      ) {
    final data = json ?? <String, dynamic>{};

    return TourPlanDayModel(
      id: data["id"]?.toString() ?? "",

      tourPlanId:
      data["tour_plan_id"]?.toString() ?? "",

      date: _parseDate(
        data["date"],
      ) ?? DateTime.now(),

      dayType:
      data["day_type"]?.toString() ?? "",

      collaborationStatus:
      data["collaboration_status"]?.toString() ?? "None",

      // ------------------------------------------------
      // JOINT WORK
      // ------------------------------------------------

      jointWorkWithUserId:
      _nullableString(
        data["joint_work_with_user_id"],
      ),

      jointWorkUserIds:
      _parseStringList(
        data["joint_work_user_ids"],
      ),

      // ------------------------------------------------
      // HANDSHAKE
      // ------------------------------------------------

      handshakeStatus:
      data["handshake_status"]?.toString() ?? "None",

      handshakeTime:
      _parseDate(
        data["handshake_time"],
      ),

      handshakeDistanceMeters:
      _parseDouble(
        data["handshake_distance_meters"],
      ),

      handshakeUserLat:
      _parseDouble(
        data["handshake_user_lat"],
      ),

      handshakeUserLng:
      _parseDouble(
        data["handshake_user_lng"],
      ),

      handshakePartnerLat:
      _parseDouble(
        data["handshake_partner_lat"],
      ),

      handshakePartnerLng:
      _parseDouble(
        data["handshake_partner_lng"],
      ),

      handshakeVerifiedByUserId:
      _nullableString(
        data["handshake_verified_by_user_id"],
      ),

      // ------------------------------------------------
      // BEATS
      // ------------------------------------------------

      beatId1:
      _nullableString(
        data["beat_id_1"],
      ),

      beatId2:
      _nullableString(
        data["beat_id_2"],
      ),

      // ------------------------------------------------
      // CHANGE REQUEST
      // ------------------------------------------------

      changeRequestStatus:
      data["change_request_status"]?.toString() ?? "None",

      changeRequestReason:
      _nullableString(
        data["change_request_reason"],
      ),

      changeRequestBeatId1:
      _nullableString(
        data["change_request_beat_id_1"],
      ),

      changeRequestBeatId2:
      _nullableString(
        data["change_request_beat_id_2"],
      ),

      changeRequestDayType:
      _nullableString(
        data["change_request_day_type"],
      ),

      changeRequestComments:
      _nullableString(
        data["change_request_comments"],
      ),

      // ------------------------------------------------
      // NOTES
      // ------------------------------------------------

      notes:
      _nullableString(
        data["notes"],
      ),

      // ------------------------------------------------
      // TIMESTAMPS
      // ------------------------------------------------

      createdAt:
      _parseDate(
        data["created_at"],
      ) ?? DateTime.now(),

      updatedAt:
      _parseDate(
        data["updated_at"],
      ) ?? DateTime.now(),

      // ------------------------------------------------
      // BEAT DETAILS
      // ------------------------------------------------

      beat1:
      _parseMap(
        data["beat1"],
      ),

      beat2:
      _parseMap(
        data["beat2"],
      ),

      // ------------------------------------------------
      // JOINT WORK DETAILS
      // ------------------------------------------------

      jointWorkWith:
      _parseMap(
        data["jointWorkWith"],
      ),

      jointWorkUsers:
      _parseMapList(
        data["joint_work_users"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,

      "tour_plan_id": tourPlanId,

      "date": date.toIso8601String(),

      "day_type": dayType,

      "collaboration_status":
      collaborationStatus,

      // Joint work
      "joint_work_with_user_id":
      jointWorkWithUserId,

      "joint_work_user_ids":
      jointWorkUserIds,

      // Handshake
      "handshake_status":
      handshakeStatus,

      "handshake_time":
      handshakeTime?.toIso8601String(),

      "handshake_distance_meters":
      handshakeDistanceMeters,

      "handshake_user_lat":
      handshakeUserLat,

      "handshake_user_lng":
      handshakeUserLng,

      "handshake_partner_lat":
      handshakePartnerLat,

      "handshake_partner_lng":
      handshakePartnerLng,

      "handshake_verified_by_user_id":
      handshakeVerifiedByUserId,

      // Beats
      "beat_id_1":
      beatId1,

      "beat_id_2":
      beatId2,

      // Change request
      "change_request_status":
      changeRequestStatus,

      "change_request_reason":
      changeRequestReason,

      "change_request_beat_id_1":
      changeRequestBeatId1,

      "change_request_beat_id_2":
      changeRequestBeatId2,

      "change_request_day_type":
      changeRequestDayType,

      "change_request_comments":
      changeRequestComments,

      // Other
      "notes":
      notes,

      "created_at":
      createdAt.toIso8601String(),

      "updated_at":
      updatedAt.toIso8601String(),

      // Details
      "beat1":
      beat1,

      "beat2":
      beat2,

      "jointWorkWith":
      jointWorkWith,

      "joint_work_users":
      jointWorkUsers,
    };
  }

  TourPlanDayModel copyWith({
    String? dayType,
    String? collaborationStatus,

    String? jointWorkWithUserId,
    List<String>? jointWorkUserIds,

    String? handshakeStatus,
    DateTime? handshakeTime,
    double? handshakeDistanceMeters,

    double? handshakeUserLat,
    double? handshakeUserLng,

    double? handshakePartnerLat,
    double? handshakePartnerLng,

    String? handshakeVerifiedByUserId,

    String? beatId1,
    String? beatId2,

    String? changeRequestStatus,
    String? changeRequestReason,

    String? changeRequestBeatId1,
    String? changeRequestBeatId2,

    String? changeRequestDayType,
    String? changeRequestComments,

    String? notes,
  }) {
    return TourPlanDayModel(
      id: id,
      tourPlanId: tourPlanId,

      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,

      dayType:
      dayType ?? this.dayType,

      collaborationStatus:
      collaborationStatus ??
          this.collaborationStatus,

      jointWorkWithUserId:
      jointWorkWithUserId ??
          this.jointWorkWithUserId,

      jointWorkUserIds:
      jointWorkUserIds ??
          this.jointWorkUserIds,

      handshakeStatus:
      handshakeStatus ??
          this.handshakeStatus,

      handshakeTime:
      handshakeTime ??
          this.handshakeTime,

      handshakeDistanceMeters:
      handshakeDistanceMeters ??
          this.handshakeDistanceMeters,

      handshakeUserLat:
      handshakeUserLat ??
          this.handshakeUserLat,

      handshakeUserLng:
      handshakeUserLng ??
          this.handshakeUserLng,

      handshakePartnerLat:
      handshakePartnerLat ??
          this.handshakePartnerLat,

      handshakePartnerLng:
      handshakePartnerLng ??
          this.handshakePartnerLng,

      handshakeVerifiedByUserId:
      handshakeVerifiedByUserId ??
          this.handshakeVerifiedByUserId,

      beatId1:
      beatId1 ?? this.beatId1,

      beatId2:
      beatId2 ?? this.beatId2,

      changeRequestStatus:
      changeRequestStatus ??
          this.changeRequestStatus,

      changeRequestReason:
      changeRequestReason ??
          this.changeRequestReason,

      changeRequestBeatId1:
      changeRequestBeatId1 ??
          this.changeRequestBeatId1,

      changeRequestBeatId2:
      changeRequestBeatId2 ??
          this.changeRequestBeatId2,

      changeRequestDayType:
      changeRequestDayType ??
          this.changeRequestDayType,

      changeRequestComments:
      changeRequestComments ??
          this.changeRequestComments,

      notes:
      notes ?? this.notes,

      beat1: beat1,
      beat2: beat2,

      jointWorkWith:
      jointWorkWith,

      jointWorkUsers:
      jointWorkUsers,
    );
  }

  // ============================================================
  // SAFE PARSING HELPERS
  // ============================================================

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final stringValue = value.toString().trim();

    if (stringValue.isEmpty ||
        stringValue.toLowerCase() == "null") {
      return null;
    }

    return stringValue;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static List<String> _parseStringList(
      dynamic value,
      ) {
    if (value == null || value is! List) {
      return const [];
    }

    return value
        .where((e) => e != null)
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static Map<String, dynamic>? _parseMap(
      dynamic value,
      ) {
    if (value == null || value is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(
      value,
    );
  }

  static List<Map<String, dynamic>> _parseMapList(
      dynamic value,
      ) {
    if (value == null || value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }
}