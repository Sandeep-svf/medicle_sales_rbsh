class SMResponse {
  final bool status;
  final String message;

  SMResponse({required this.status, required this.message});

  factory SMResponse.fromJson(Map<String, dynamic> json) {
    return SMResponse(
      status: json['status'] ?? false,  // Ensure status is fetched from the correct key
      message: json['message'] ?? 'No message',  // Ensure message is fetched from the correct key
    );
  }
}
