// leave_models.dart
class LeaveType {
  final String id;
  final String name;
  final String code;
  final String color;
  final int? maxDaysPerYear;
  final bool requiresDocuments;

  LeaveType({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
    this.maxDaysPerYear,
    this.requiresDocuments = false,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    // Handles cases where leaveType is nested or direct
    return LeaveType(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      code: json['code'] ?? '',
      color: json['color'] ?? '#3B82F6', // Default blue
      maxDaysPerYear: json['maxDaysPerYear'],
      requiresDocuments: json['requiresDocuments'] ?? false,
    );
  }
}

class LeaveBalance {
  final LeaveType leaveType;
  final num allocated;
  final num used;
  final num balance;

  LeaveBalance({
    required this.leaveType,
    required this.allocated,
    required this.used,
    required this.balance,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      leaveType: LeaveType.fromJson(json['leaveType'] ?? {}),
      allocated: json['allocated'] ?? 0,
      used: json['used'] ?? 0,
      balance: json['balance'] ?? 0,
    );
  }
}

class LeaveHistory {
  final String id;
  final String status;
  final String startDate;
  final String endDate;
  final String totalDays;
  final String reason;
  final LeaveType leaveType;

  LeaveHistory({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.leaveType,
  });

  factory LeaveHistory.fromJson(Map<String, dynamic> json) {
    return LeaveHistory(
      id: json['_id'] ?? '',
      status: json['status'] ?? 'Pending',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      totalDays: json['totalDays']?.toString() ?? '0',
      reason: json['reason'] ?? '',
      // Map nested leaveTypeId object to LeaveType model
      leaveType: LeaveType.fromJson(json['leaveTypeId'] ?? {}),
    );
  }
}