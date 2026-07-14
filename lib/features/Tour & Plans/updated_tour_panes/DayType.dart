enum DayType { field, holiday, leave, unassigned, meeting, jointWork }

DayType mapApiDayType(
    String value,
    ) {

  switch (value) {

    case "Field":
      return DayType.field;

    case "Joint work":
      return DayType.jointWork;

    case "Meeting":
      return DayType.meeting;

    case "Leave":
      return DayType.leave;

    case "Holiday":
      return DayType.holiday;

    case "Weekly off":
      return DayType.holiday;

    default:
      return DayType.unassigned;
  }
}