class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String location;
  final String latitude;
  final String longitude;
  final String email;
  final String phone;
  final String registrationNumber;
  final int yearsOfExperience;
  final DateTime dateOfBirth;
  final String gender;
  final DateTime? anniversary;
  final HeadOffice headOffice;
  final List<dynamic> visitHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.location,
    required this.latitude,
    required this.longitude,
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
      id: json['_id'] ?? '',  // Default empty string if null
      name: json['name'] ?? '',  // Default empty string if null
      specialization: json['specialization'] ?? '',  // Default empty string if null
      location: json['location'] ?? '',  // Default empty string if null
      latitude: json['latitude'] ?? 28.704060,  // Default empty string if null
      longitude: json['longitude'] ?? 77.102493,  // Default empty string if null
      email: json['email'] ?? '',  // Default empty string if null
      phone: json['phone'] ?? '',  // Default empty string if null
      registrationNumber: json['registration_number'] ?? '',  // Default empty string if null
      yearsOfExperience: json['years_of_experience'] is double
          ? (json['years_of_experience'] as double).toInt() // If it's a double, cast to int
          : (json['years_of_experience'] is int ? json['years_of_experience'] : 0), // Handle both cases (int or null)
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : DateTime.now(),  // Use current date if null
      gender: json['gender'] ?? '',  // Default empty string if null
      anniversary: json['anniversary'] != null
          ? DateTime.parse(json['anniversary'])
          : null,  // Handle null anniversary
      headOffice: json['headOffice'] != null
          ? HeadOffice.fromJson(json['headOffice'])
          : HeadOffice.empty(),  // Handle null head office
      visitHistory: List<dynamic>.from(json['visit_history'] ?? []),  // Default empty list if null
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),  // Default current date if null
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),  // Default current date if null
    );
  }


/*factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '',  // Default empty string if null
      name: json['name'] ?? '',  // Default empty string if null
      specialization: json['specialization'] ?? '',  // Default empty string if null
      location: json['location'] ?? '',  // Default empty string if null
      email: json['email'] ?? '',  // Default empty string if null
      phone: json['phone'] ?? '',  // Default empty string if null
      registrationNumber: json['registration_number'] ?? '',  // Default empty string if null
      //yearsOfExperience: json['years_of_experience'] ?? '0',  // Default to 0 if null
      yearsOfExperience: (json['years_of_experience'] is double)
          ? (json['years_of_experience'] as double).toInt() // If it's a double, convert to int
          : json['years_of_experience'] ?? 0,  // Default to 0 if null or not a double
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : DateTime.now(),  // Use current date if null
      gender: json['gender'] ?? '',  // Default empty string if null
      anniversary: json['anniversary'] != null ? DateTime.parse(json['anniversary']) : null,  // Handle null anniversary
      headOffice: json['headOffice'] != null ? HeadOffice.fromJson(json['headOffice']) : HeadOffice.empty(),  // Handle null head office
      visitHistory: List<dynamic>.from(json['visit_history'] ?? []),  // Default empty list if null
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),  // Default current date if null
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),  // Default current date if null
    );
  }*/
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
      id: json['_id'] ?? '',  // Default empty string if null
      name: json['name'] ?? 'Unknown',  // Default to 'Unknown' if null
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),  // Default to current date if null
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),  // Default to current date if null
    );
  }

  // Create an empty HeadOffice object if the data is missing
  factory HeadOffice.empty() {
    return HeadOffice(
      id: '',
      name: 'Unknown',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
