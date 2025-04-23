class Clinic {
  final String name;
  final String address;
  final String phone;
  final String email;
  final DateTime createdAt;

  Clinic({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.createdAt,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    final chemist = json['chemist'] ?? json; // handles both list and single object
    return Clinic(
      name: chemist['firmName'] ?? '',
      address: chemist['address'] ?? '',
      phone: chemist['mobileNo'] ?? '',
      email: chemist['emailId'] ?? '',
      createdAt: DateTime.parse(chemist['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
