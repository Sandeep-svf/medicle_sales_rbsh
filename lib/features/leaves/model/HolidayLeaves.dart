// LeaveModels.dart

class HolidayLeaves {
  final String id;
  final String title;
  final DateTime date;
  final String type;
  final bool isOptional;

  HolidayLeaves({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.isOptional,
  });

  factory HolidayLeaves.fromJson(Map<String, dynamic> json) {
    return HolidayLeaves(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      // Parse "2026-01-14" to DateTime
      date: DateTime.parse(json['date']),
      type: json['type'] ?? 'General',
      isOptional: json['isOptional'] ?? false,
    );
  }
}

// ... Keep your existing LeaveType, LeaveBalance, LeaveHistory classes here