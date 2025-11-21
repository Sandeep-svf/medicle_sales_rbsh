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
  final Visits? visits;
  final Expenses? expenses;
  final Targets? targets;
  final Summary? summary;

  DashboardData({
    this.user,
    this.period,
    this.visits,
    this.expenses,
    this.targets,
    this.summary,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      period: json['period'] != null ? Period.fromJson(json['period']) : null,
      visits: json['visits'] != null ? Visits.fromJson(json['visits']) : null,
      expenses: json['expenses'] != null ? Expenses.fromJson(json['expenses']) : null,
      targets: json['targets'] != null ? Targets.fromJson(json['targets']) : null,
      summary: json['summary'] != null ? Summary.fromJson(json['summary']) : null,
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
  final int targetMonth;
  final int targetYear;
  final bool isCurrentMonth;
  final String? displayMessage;

  Targets({
    this.monthlyTarget = 0,
    this.achieved = 0,
    this.remaining = 0,
    this.achievementPercentage = 0,
    this.status,
    this.targetMonth = 0,
    this.targetYear = 0,
    this.isCurrentMonth = false,
    this.displayMessage,
  });

  factory Targets.fromJson(Map<String, dynamic> json) {
    return Targets(
      monthlyTarget: json['monthlyTarget'] ?? 0,
      achieved: json['achieved'] ?? 0,
      remaining: json['remaining'] ?? 0,
      achievementPercentage: json['achievementPercentage'] ?? 0,
      status: json['status'],
      targetMonth: json['targetMonth'] ?? 0,
      targetYear: json['targetYear'] ?? 0,
      isCurrentMonth: json['isCurrentMonth'] ?? false,
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
