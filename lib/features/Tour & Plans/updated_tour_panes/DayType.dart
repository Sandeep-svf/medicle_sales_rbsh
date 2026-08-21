enum DayType {
  field,
  jointWork,
  meeting,
  office,
  transit,
  leave,
  holiday,
  unassigned,
}

DayType mapApiDayType(String value) {
  switch (value.trim().toLowerCase()) {
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
    case "leave":
      return DayType.leave;
    case "holiday":
    case "weekly off":
      return DayType.holiday;
    default:
      return DayType.unassigned;
  }
}
