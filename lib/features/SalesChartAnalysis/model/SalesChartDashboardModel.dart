import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/enum/day_type.dart';

class DashboardResponse {
  final bool success;
  final DashboardData? data;
  final String? message;

  DashboardResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class DashboardData {
  final User? user;
  final Period? period;
  final TodayBeatAssigned? todayBeatAssigned;
  final TodayCollaboration? todayCollaboration;
  final Visits? visits;
  final Expenses? expenses;
  final Targets? targets;
  final Summary? summary;

  DashboardData({
    this.user,
    this.period,
    this.todayBeatAssigned,
    this.todayCollaboration,
    this.visits,
    this.expenses,
    this.targets,
    this.summary,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      period: json['period'] != null ? Period.fromJson(json['period']) : null,
      todayBeatAssigned: json['todayBeatAssigned'] != null
          ? TodayBeatAssigned.fromJson(json['todayBeatAssigned'])
          : null,

      todayCollaboration: json['todayCollaboration'] != null
          ? TodayCollaboration.fromJson(json['todayCollaboration'])
          : null,
      visits: json['visits'] != null ? Visits.fromJson(json['visits']) : null,
      expenses: json['expenses'] != null ? Expenses.fromJson(json['expenses']) : null,
      targets: json['targets'] != null ? Targets.fromJson(json['targets']) : null,
      summary: json['summary'] != null ? Summary.fromJson(json['summary']) : null,
    );
  }
}

class TodayCollaboration {
  final bool hasCollaboration;

  final String? dayId;
  final String? date;
  final DayType dayType;

  final String? collaborationStatus;
  final String? handshakeStatus;
  final String? handshakeTime;
  final double? handshakeDistanceMeters;

  final String? beatName;
  final String? notes;

  final int totalCollaborators;

  final List<CollaboratingUser> collaboratingUsers;

  TodayCollaboration({
    this.hasCollaboration = false,
    this.dayId,
    this.date,
    this.dayType = DayType.unknown,
    this.collaborationStatus,
    this.handshakeStatus,
    this.handshakeTime,
    this.handshakeDistanceMeters,
    this.beatName,
    this.notes,
    this.totalCollaborators = 0,
    this.collaboratingUsers = const [],
  });

  factory TodayCollaboration.fromJson(Map<String, dynamic> json) {
    return TodayCollaboration(
      hasCollaboration: json['hasCollaboration'] ?? false,
      dayId: json['day_id'],
      date: json['date'],
      dayType: DayTypeExtension.fromString(json['day_type']),
      collaborationStatus: json['collaboration_status'],
      handshakeStatus: json['handshake_status'],
      handshakeTime: json['handshake_time'],
      handshakeDistanceMeters:
      (json['handshake_distance_meters'] as num?)?.toDouble(),
      beatName: json['beat_name'],
      notes: json['notes'],
      totalCollaborators: json['total_collaborators'] ?? 0,
      collaboratingUsers:
      (json['collaborating_users'] as List?)
          ?.map((e) => CollaboratingUser.fromJson(e))
          .toList() ??
          const [],
    );
  }
}

class CollaboratingUser {
  final String? dayId;
  final bool isCreator;

  final String? date;
  final DayType dayType;

  final String? collaborationStatus;
  final String? handshakeStatus;
  final String? handshakeTime;
  final double? handshakeDistanceMeters;

  final String? beatName;
  final String? notes;

  final CollaborationUser? user;

  CollaboratingUser({
    this.dayId,
    this.isCreator = false,
    this.date,
    this.dayType = DayType.unknown,
    this.collaborationStatus,
    this.handshakeStatus,
    this.handshakeTime,
    this.handshakeDistanceMeters,
    this.beatName,
    this.notes,
    this.user,
  });

  factory CollaboratingUser.fromJson(Map<String, dynamic> json) {
    return CollaboratingUser(
      dayId: json['day_id'],
      isCreator: json['is_creator'] ?? false,
      date: json['date'],
      dayType: DayTypeExtension.fromString(json['day_type']),
      collaborationStatus: json['collaboration_status'],
      handshakeStatus: json['handshake_status'],
      handshakeTime: json['handshake_time'],
      handshakeDistanceMeters:
      (json['handshake_distance_meters'] as num?)?.toDouble(),
      beatName: json['beat_name'],
      notes: json['notes'],
      user: json['user'] != null
          ? CollaborationUser.fromJson(json['user'])
          : null,
    );
  }
}

class CollaborationUser {
  final String? id;
  final String? name;
  final String? employeeCode;
  final String? email;
  final String? mobileNumber;
  final String? role;
  final String? department;

  CollaborationUser({
    this.id,
    this.name,
    this.employeeCode,
    this.email,
    this.mobileNumber,
    this.role,
    this.department,
  });

  factory CollaborationUser.fromJson(Map<String, dynamic> json) {
    return CollaborationUser(
      id: json['id'],
      name: json['name'],
      employeeCode: json['employee_code'],
      email: json['email'],
      mobileNumber: json['mobile_number'],
      role: json['role'],
      department: json['department'],
    );
  }
}





class User {
  final String? id;
  final String? name;
  final String? role;
  final String? department;

  User({this.id, this.name, this.role, this.department});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      department: json['department'],
    );
  }
}

class Period {
  final int? month;
  final int? year;
  final String? monthName;

  Period({this.month, this.year, this.monthName});

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      month: json['month'],
      year: json['year'],
      monthName: json['monthName'],
    );
  }
}

class Visits {
  final VisitDetails? doctor;
  final VisitDetails? chemist;
  final VisitDetails? stockist;
  final int total;
  final int scheduled;
  final int confirmed;
  final int submitted;
  final int approved;
  final int rejected;
  final int draft;

  Visits({
    this.doctor,
    this.chemist,
    this.stockist,
    this.total = 0,
    this.scheduled = 0,
    this.confirmed = 0,
    this.submitted = 0,
    this.approved = 0,
    this.rejected = 0,
    this.draft = 0,
  });

  factory Visits.fromJson(Map<String, dynamic> json) {
    return Visits(
      doctor: json['doctor'] != null ? VisitDetails.fromJson(json['doctor']) : null,
      chemist: json['chemist'] != null ? VisitDetails.fromJson(json['chemist']) : null,
      stockist: json['stockist'] != null ? VisitDetails.fromJson(json['stockist']) : null,
      total: json['total'] ?? 0,
      scheduled: json['scheduled'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
      submitted: json['submitted'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
      draft: json['draft'] ?? 0,
    );
  }
}

class VisitDetails {
  final int scheduled;
  final int confirmed;
  final int total;

  VisitDetails({this.scheduled = 0, this.confirmed = 0, this.total = 0});

  factory VisitDetails.fromJson(Map<String, dynamic> json) {
    return VisitDetails(
      scheduled: json['scheduled'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class TodayBeatAssigned {
  final String? dayId;
  final String? tourPlanId;

  final String? date;
  final DayType dayType;
  final String? beatId;
  final String? beatName;
  final String? status;

  final int doctorsCount;
  final int chemistsCount;
  final int stockistsCount;
  final int totalTargets;

  TodayBeatAssigned({
    this.dayId,
    this.tourPlanId,
    this.date,
    this.dayType = DayType.unknown,
    this.beatId,
    this.beatName,
    this.status,
    this.doctorsCount = 0,
    this.chemistsCount = 0,
    this.stockistsCount = 0,
    this.totalTargets = 0,
  });

  factory TodayBeatAssigned.fromJson(Map<String, dynamic> json) {
    return TodayBeatAssigned(
      dayId: json['day_id'],
      tourPlanId: json['tour_plan_id'],
      date: json['date'],
      dayType: DayTypeExtension.fromString(
        json['day_type'],
      ),
      beatId: json['beat_id'],
      beatName: json['beat_name'],
      status: json['status'],
      doctorsCount: json['doctors_count'] ?? 0,
      chemistsCount: json['chemists_count'] ?? 0,
      stockistsCount: json['stockists_count'] ?? 0,
      totalTargets: json['total_targets'] ?? 0,
    );
  }
}

class Expenses {
  final int total;
  final int approved;
  final int pending;
  final int rejected;
  final int totalAmount;
  final int approvedAmount;
  final int pendingAmount;
  final int rejectedAmount;

  Expenses({
    this.total = 0,
    this.approved = 0,
    this.pending = 0,
    this.rejected = 0,
    this.totalAmount = 0,
    this.approvedAmount = 0,
    this.pendingAmount = 0,
    this.rejectedAmount = 0,
  });

  factory Expenses.fromJson(Map<String, dynamic> json) {
    return Expenses(
      total: json['total'] ?? 0,
      approved: json['approved'] ?? 0,
      pending: json['pending'] ?? 0,
      rejected: json['rejected'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
      approvedAmount: json['approvedAmount'] ?? 0,
      pendingAmount: json['pendingAmount'] ?? 0,
      rejectedAmount: json['rejectedAmount'] ?? 0,
    );
  }
}

class Targets {
  final int monthlyTarget;
  final int achieved;
  final int remaining;
  final int achievementPercentage;

  final String? status;
  final String? deadline;

  final int targetMonth;
  final int targetYear;

  final bool isCurrentMonth;

  final String? targetPeriod;
  final String? displayMessage;

  Targets({
    this.monthlyTarget = 0,
    this.achieved = 0,
    this.remaining = 0,
    this.achievementPercentage = 0,
    this.status,
    this.deadline,
    this.targetMonth = 0,
    this.targetYear = 0,
    this.isCurrentMonth = false,
    this.targetPeriod,
    this.displayMessage,
  });

  factory Targets.fromJson(Map<String, dynamic> json) {
    return Targets(
      monthlyTarget: (json['monthlyTarget'] ?? 0) as int,
      achieved: (json['achieved'] ?? 0) as int,
      remaining: (json['remaining'] ?? 0) as int,
      achievementPercentage:
      (json['achievementPercentage'] ?? 0) as int,
      status: json['status'],
      deadline: json['deadline'],
      targetMonth: (json['targetMonth'] ?? 0) as int,
      targetYear: (json['targetYear'] ?? 0) as int,
      isCurrentMonth: json['isCurrentMonth'] ?? false,
      targetPeriod: json['targetPeriod'],
      displayMessage: json['displayMessage'],
    );
  }
}

class Summary {
  final String totalActivities;
  final String visitCompletionRate;
  final String targetAchievement;
  final String pendingExpenses;
  final String totalExpenseAmount;

  Summary({
    this.totalActivities = "0",
    this.visitCompletionRate = "0",
    this.targetAchievement = "0",
    this.pendingExpenses = "0",
    this.totalExpenseAmount = "0",
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalActivities: json['totalActivities'] ?? "0",
      visitCompletionRate: json['visitCompletionRate'] ?? "0",
      targetAchievement: json['targetAchievement'] ?? "0",
      pendingExpenses: json['pendingExpenses'] ?? "0",
      totalExpenseAmount: json['totalExpenseAmount'] ?? "0",
    );
  }
}
