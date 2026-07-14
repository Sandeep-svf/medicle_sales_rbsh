import '../DayType.dart';

class TourDay {
  ///--------------------------------------------------------
  /// Date
  ///--------------------------------------------------------

  final DateTime date;

  ///--------------------------------------------------------
  /// UI Type
  ///--------------------------------------------------------

  final DayType type;

  ///--------------------------------------------------------
  /// Backend Fields
  ///--------------------------------------------------------

  final String? id;

  final String? tourPlanId;

  /// Backend value
  /// Example:
  /// Field
  /// Joint work
  /// Meeting
  /// Office
  /// Transit
  /// Leave
  /// Holiday
  /// Weekly off
  final String? apiDayType;

  /// None
  /// Pending
  /// Accepted
  /// Rejected
  final String? collaborationStatus;

  ///--------------------------------------------------------
  /// Beat
  ///--------------------------------------------------------

  final String? beatId;

  final String? beatName;

  final String? beatId2;

  final String? beatName2;

  ///--------------------------------------------------------
  /// Joint Work
  ///--------------------------------------------------------

  final String? jointWorkUserId;

  final String? jointWorkUserName;

  ///--------------------------------------------------------
  /// Others
  ///--------------------------------------------------------

  final String? notes;

  final String? holidayName;

  const TourDay({
    required this.date,
    required this.type,

    this.id,

    this.tourPlanId,

    this.apiDayType,

    this.collaborationStatus,

    this.beatId,

    this.beatName,

    this.beatId2,

    this.beatName2,

    this.jointWorkUserId,

    this.jointWorkUserName,

    this.notes,

    this.holidayName,
  });

  ///--------------------------------------------------------
  /// Copy With
  ///--------------------------------------------------------

  TourDay copyWith({
    DateTime? date,

    DayType? type,

    String? id,

    String? tourPlanId,

    String? apiDayType,

    String? collaborationStatus,

    String? beatId,

    String? beatName,

    String? beatId2,

    String? beatName2,

    String? jointWorkUserId,

    String? jointWorkUserName,

    String? notes,

    String? holidayName,
  }) {
    return TourDay(
      date: date ?? this.date,

      type: type ?? this.type,

      id: id ?? this.id,

      tourPlanId: tourPlanId ?? this.tourPlanId,

      apiDayType: apiDayType ?? this.apiDayType,

      collaborationStatus:
      collaborationStatus ??
          this.collaborationStatus,

      beatId: beatId ?? this.beatId,

      beatName: beatName ?? this.beatName,

      beatId2: beatId2 ?? this.beatId2,

      beatName2: beatName2 ?? this.beatName2,

      jointWorkUserId:
      jointWorkUserId ??
          this.jointWorkUserId,

      jointWorkUserName:
      jointWorkUserName ??
          this.jointWorkUserName,

      notes: notes ?? this.notes,

      holidayName:
      holidayName ?? this.holidayName,
    );
  }

  ///--------------------------------------------------------
  /// Helpers
  ///--------------------------------------------------------

  bool get isWeeklyOff =>
      holidayName == "Weekly Off";

  bool get isHoliday =>
      type == DayType.holiday;

  bool get isJointWork =>
      type == DayType.jointWork;

  bool get isField =>
      type == DayType.field;

  bool get hasBeat =>
      beatId != null &&
          beatId!.isNotEmpty;

  bool get hasJointUser =>
      jointWorkUserId != null &&
          jointWorkUserId!.isNotEmpty;

  bool get isEditable =>
      !isHoliday && !isWeeklyOff;

  @override
  String toString() {
    return "TourDay("
        "date:$date, "
        "type:$type, "
        "beat:$beatName, "
        "joint:$jointWorkUserName"
        ")";
  }
}