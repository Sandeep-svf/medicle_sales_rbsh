import '../DayType.dart';

const Object _tourDayUnset = Object();

class TourDay {
  final DateTime date;
  final DayType type;

  final String? id;
  final String? tourPlanId;
  final String? apiDayType;
  final String? collaborationStatus;

  final String? beatId;
  final String? beatName;
  final String? beatId2;
  final String? beatName2;

  /// IDs are used for API operations.
  final List<String> jointWorkUserIds;

  /// Names are used for UI display.
  final List<String> jointWorkUserNames;

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
    this.jointWorkUserIds = const [],
    this.jointWorkUserNames = const [],
    this.notes,
    this.holidayName,
  });

  /// `Object?` + sentinel is intentional for nullable fields.
  /// It lets callers explicitly clear a value with `null`.
  TourDay copyWith({
    DateTime? date,
    DayType? type,
    Object? id = _tourDayUnset,
    Object? tourPlanId = _tourDayUnset,
    Object? apiDayType = _tourDayUnset,
    Object? collaborationStatus = _tourDayUnset,
    Object? beatId = _tourDayUnset,
    Object? beatName = _tourDayUnset,
    Object? beatId2 = _tourDayUnset,
    Object? beatName2 = _tourDayUnset,
    List<String>? jointWorkUserIds,
    List<String>? jointWorkUserNames,
    Object? notes = _tourDayUnset,
    Object? holidayName = _tourDayUnset,
  }) {
    return TourDay(
      date: date ?? this.date,
      type: type ?? this.type,
      id: identical(id, _tourDayUnset) ? this.id : id as String?,
      tourPlanId: identical(tourPlanId, _tourDayUnset)
          ? this.tourPlanId
          : tourPlanId as String?,
      apiDayType: identical(apiDayType, _tourDayUnset)
          ? this.apiDayType
          : apiDayType as String?,
      collaborationStatus: identical(collaborationStatus, _tourDayUnset)
          ? this.collaborationStatus
          : collaborationStatus as String?,
      beatId: identical(beatId, _tourDayUnset) ? this.beatId : beatId as String?,
      beatName: identical(beatName, _tourDayUnset)
          ? this.beatName
          : beatName as String?,
      beatId2: identical(beatId2, _tourDayUnset)
          ? this.beatId2
          : beatId2 as String?,
      beatName2: identical(beatName2, _tourDayUnset)
          ? this.beatName2
          : beatName2 as String?,
      jointWorkUserIds: jointWorkUserIds ?? this.jointWorkUserIds,
      jointWorkUserNames: jointWorkUserNames ?? this.jointWorkUserNames,
      notes: identical(notes, _tourDayUnset) ? this.notes : notes as String?,
      holidayName: identical(holidayName, _tourDayUnset)
          ? this.holidayName
          : holidayName as String?,
    );
  }

  bool get isWeeklyOff =>
      holidayName?.trim().toLowerCase() == "weekly off" ||
      apiDayType?.trim().toLowerCase() == "weekly off";
  bool get isHoliday => type == DayType.holiday;
  bool get isJointWork => type == DayType.jointWork;
  bool get isField => type == DayType.field;
  bool get hasBeat => beatId?.isNotEmpty ?? false;
  bool get hasJointUser => jointWorkUserIds.isNotEmpty;
  bool get hasJointUserNames => jointWorkUserNames.isNotEmpty;
  bool get isEditable => !isHoliday && !isWeeklyOff;

  String get jointWorkDisplayName {
    if (jointWorkUserNames.isEmpty) {
      return "No joint work user";
    }
    return jointWorkUserNames.join(", ");
  }

  @override
  String toString() {
    return "TourDay("
        "date: $date, "
        "type: $type, "
        "beat: $beatName, "
        "beat2: $beatName2, "
        "joint: ${jointWorkUserNames.join(', ')}"
        ")";
  }
}
