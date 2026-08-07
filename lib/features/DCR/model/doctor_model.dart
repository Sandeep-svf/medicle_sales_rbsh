class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String mobileNumber;
  final String address;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.address,
  });

  factory DoctorModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DoctorModel(
        id: '',
        name: '',
        email: '',
        mobileNumber: '',
        address: '',
      );
    }

    return DoctorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobile_number'] ?? json['phone'] ?? '',
      address: json['address'] ??
          json['clinic_address'] ??
          json['location'] ??
          '',
    );
  }
}