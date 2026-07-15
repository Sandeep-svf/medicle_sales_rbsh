class PunchSessionModel {
  final DateTime? punchIn;
  final DateTime? punchOut;
  final int durationMinutes;

  PunchSessionModel({
    this.punchIn,
    this.punchOut,
    required this.durationMinutes,
  });

  factory PunchSessionModel.fromJson(Map<String, dynamic> json) {
    return PunchSessionModel(
      punchIn: json["punchIn"] != null
          ? DateTime.parse(json["punchIn"])
          : null,
      punchOut: json["punchOut"] != null
          ? DateTime.parse(json["punchOut"])
          : null,
      durationMinutes: json["durationMinutes"] ?? 0,
    );
  }
}