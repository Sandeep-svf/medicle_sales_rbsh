class VisitScheduleResponse {
  final bool success;
  final String message;


  VisitScheduleResponse({
    required this.success,
    required this.message,

  });

  factory VisitScheduleResponse.fromJson(Map<String, dynamic> json) {
    return VisitScheduleResponse(
      success: json['success'].toString().toLowerCase() == 'true',
      message: json['message'],

    );
  }
}


