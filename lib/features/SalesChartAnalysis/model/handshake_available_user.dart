class HandshakeAvailableUser {
  const HandshakeAvailableUser({
    required this.id,
    required this.name,
    required this.role,
    required this.employeeCode,
    required this.available,
  });

  final String id;
  final String name;
  final String role;
  final String employeeCode;
  final bool available;

  factory HandshakeAvailableUser.fromJson(Map<String, dynamic> json) {
    return HandshakeAvailableUser(
      id: (json['id'] ?? json['_id'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      role: (json['role'] ?? '').toString().trim(),
      employeeCode: (json['employeeCode'] ?? json['employee_code'] ?? '')
          .toString()
          .trim(),
      available: json['available'] == true,
    );
  }

  String get displayName => name.isEmpty ? 'Unnamed User' : name;

  String get displayRole => role.isEmpty ? 'User' : role;

  String get displayEmployeeCode =>
      employeeCode.isEmpty ? 'Not available' : employeeCode;

  String get initials {
    final nameParts = displayName
        .split(' ')
        .where((namePart) => namePart.trim().isNotEmpty)
        .toList(growable: false);

    if (nameParts.isEmpty) return '?';
    if (nameParts.length == 1) {
      return nameParts.first.substring(0, 1).toUpperCase();
    }

    return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
  }
}

class HandshakeSubmissionResult {
  const HandshakeSubmissionResult({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final Map<String, dynamic> data;
}
