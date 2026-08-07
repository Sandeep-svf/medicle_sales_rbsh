class UserModel {
  final String id;
  final String name;
  final String employeeCode;
  final String role;
  final String hq;

  const UserModel({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.role,
    required this.hq,
  });

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const UserModel(
        id: '',
        name: '',
        employeeCode: '',
        role: '',
        hq: '',
      );
    }

    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      role: json['role'] ?? '',
      hq: json['hq'] ?? '',
    );
  }
}