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
  switch (value) {
    case "Field":
      return DayType.field;

    case "Joint work":
      return DayType.jointWork;

    case "Meeting":
      return DayType.meeting;

    case "Office":
      return DayType.office;

    case "Transit":
      return DayType.transit;

    case "Leave":
      return DayType.leave;

    case "Holiday":
    case "Weekly off":
      return DayType.holiday;

    default:
      return DayType.unassigned;
  }

}