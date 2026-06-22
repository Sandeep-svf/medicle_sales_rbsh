class AvailableUserModel {
  final String id;
  final String name;
  final String role;
  final String employeeCode;
  final bool available;

  AvailableUserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.employeeCode,
    required this.available,
  });

  factory AvailableUserModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AvailableUserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      employeeCode:
      json['employeeCode'] ?? '',
      available:
      json['available'] ?? false,
    );
  }
}