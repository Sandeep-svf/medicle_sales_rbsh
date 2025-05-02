class SMResponse {
  final bool status;
  final String message;

  SMResponse({
    required this.status,
    required this.message,
  });

  // Factory method to parse the JSON response
  factory SMResponse.fromJson(Map<String, dynamic> json) {
    return SMResponse(
      status: json['status'],
      message: json['message'],
    );
  }
}
