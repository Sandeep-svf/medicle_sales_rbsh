class VisitConfirmationResponse {
  final bool status;
  final String? message;

  VisitConfirmationResponse({
    required this.status,
    this.message,
  });

  factory VisitConfirmationResponse.fromJson(Map<String, dynamic> json) {
    return VisitConfirmationResponse(
      status: json['success'],
      message: json['message'],
    );
  }
}
