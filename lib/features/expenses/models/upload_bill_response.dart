class UploadBillResponse {
  final bool success;
  final String imageUrl;
  final String message;

  UploadBillResponse({
    required this.success,
    required this.imageUrl,
    required this.message,
  });

  factory UploadBillResponse.fromJson(Map<String, dynamic> json) {
    return UploadBillResponse(
      success: json['success'] ?? false,
      imageUrl: json['imageUrl'] ?? '',
      message: json['message'] ?? '',
    );
  }
}