enum DayType {
  field,
  jointWork,
  meeting,
  office,
  transit,
  weeklyOff,
  holiday,
  leave,
  unknown,
}

extension DayTypeExtension on DayType {
  static DayType fromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case "field":
        return DayType.field;

      case "joint work":
        return DayType.jointWork;

      case "meeting":
        return DayType.meeting;

      case "office":
        return DayType.office;

      case "transit":
        return DayType.transit;

      case "weekly off":
        return DayType.weeklyOff;

      case "holiday":
        return DayType.holiday;

      case "leave":
        return DayType.leave;

      default:
        return DayType.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case DayType.field:
        return "Field";

      case DayType.jointWork:
        return "Joint Work";

      case DayType.meeting:
        return "Meeting";

      case DayType.office:
        return "Office";

      case DayType.transit:
        return "Transit";

      case DayType.weeklyOff:
        return "Weekly Off";

      case DayType.holiday:
        return "Holiday";

      case DayType.leave:
        return "Leave";

      default:
        return "Unknown";
    }
  }

  bool get showBeat {
    return this == DayType.field ||
        this == DayType.jointWork;
  }
}