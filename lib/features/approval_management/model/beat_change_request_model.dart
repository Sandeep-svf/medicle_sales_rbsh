class BeatChangeRequestModel {
  final String id;

  final String date;

  final String dayType;

  final String status;

  final String reason;

  final String? comments;

  final String currentBeatId;
  final String currentBeatName;

  final String requestedBeatId;
  final String requestedBeatName;

  final String employeeId;
  final String employeeName;
  final String employeeCode;

  const BeatChangeRequestModel({
    required this.id,
    required this.date,
    required this.dayType,
    required this.status,
    required this.reason,
    required this.comments,
    required this.currentBeatId,
    required this.currentBeatName,
    required this.requestedBeatId,
    required this.requestedBeatName,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
  });

  factory BeatChangeRequestModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final tourPlan = json["tourPlan"] ?? {};

    final user = tourPlan["user"] ?? {};

    final currentBeat = json["beat1"] ?? {};

    final requestedBeat =
        json["changeRequestBeat1"] ?? {};

    return BeatChangeRequestModel(
      id: json["id"] ?? "",

      date: json["date"] ?? "",

      dayType: json["day_type"] ?? "",

      status: json["change_request_status"] ?? "",

      reason: json["change_request_reason"] ?? "",

      comments: json["change_request_comments"],

      currentBeatId: currentBeat["id"] ?? "",

      currentBeatName: currentBeat["name"] ?? "",

      requestedBeatId:
      requestedBeat["id"] ?? "",

      requestedBeatName:
      requestedBeat["name"] ?? "",

      employeeId: user["id"] ?? "",

      employeeName: user["name"] ?? "",

      employeeCode:
      user["employee_code"] ?? "",
    );
  }
}