import 'punch_session_model.dart';

class AttendanceStatusModel {
  final String date;

  final String status;

  final List<PunchSessionModel> punchSessions;

  final int currentSession;

  final DateTime? firstPunchIn;

  final DateTime? lastPunchOut;

  final int totalWorkingMinutes;

  final int totalBreakMinutes;

  final DateTime? punchIn;

  final DateTime? punchOut;

  AttendanceStatusModel({
    required this.date,
    required this.status,
    required this.punchSessions,
    required this.currentSession,
    this.firstPunchIn,
    this.lastPunchOut,
    required this.totalWorkingMinutes,
    required this.totalBreakMinutes,
    this.punchIn,
    this.punchOut,
  });

  factory AttendanceStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"];

    return AttendanceStatusModel(
      date: data["date"] ?? "",
      status: data["status"] ?? "",

      punchSessions: (data["punchSessions"] as List? ?? [])
          .map((e) => PunchSessionModel.fromJson(e))
          .toList(),

      currentSession: data["currentSession"] ?? -1,

      firstPunchIn: data["firstPunchIn"] != null
          ? DateTime.parse(data["firstPunchIn"])
          : null,

      lastPunchOut: data["lastPunchOut"] != null
          ? DateTime.parse(data["lastPunchOut"])
          : null,

      totalWorkingMinutes: data["totalWorkingMinutes"] ?? 0,

      totalBreakMinutes: data["totalBreakMinutes"] ?? 0,

      punchIn: data["punchIn"] != null
          ? DateTime.parse(data["punchIn"])
          : null,

      punchOut: data["punchOut"] != null
          ? DateTime.parse(data["punchOut"])
          : null,
    );
  }

  bool get needsPunchIn => status == "not_started";

  bool get isPunchedIn => status == "punched_in";
}