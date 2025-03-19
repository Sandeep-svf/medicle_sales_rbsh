class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String location;
  final String email;
  final String phone;
  final String registrationNumber;
  final int yearsOfExperience;
  final DateTime dateOfBirth;
  final String gender;
  final DateTime? anniversary; // Handle null values properly
  final HeadOffice headOffice;
  final List<dynamic> visitHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.location,
    required this.email,
    required this.phone,
    required this.registrationNumber,
    required this.yearsOfExperience,
    required this.dateOfBirth,
    required this.gender,
    this.anniversary,
    required this.headOffice,
    required this.visitHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'],
      name: json['name'],
      specialization: json['specialization'],
      location: json['location'],
      email: json['email'],
      phone: json['phone'],
      registrationNumber: json['registration_number'],
      yearsOfExperience: json['years_of_experience'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      gender: json['gender'],
      anniversary: json['anniversary'] != null ? DateTime.parse(json['anniversary']) : null, // Fixed null handling
      headOffice: HeadOffice.fromJson(json['headOffice']),
      visitHistory: List<dynamic>.from(json['visit_history'] ?? []), // Ensure it handles null or empty list properly
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class HeadOffice {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  HeadOffice({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HeadOffice.fromJson(Map<String, dynamic> json) {
    return HeadOffice(
      id: json['_id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
