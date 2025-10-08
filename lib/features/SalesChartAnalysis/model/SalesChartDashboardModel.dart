

import 'dart:convert';

class SalesChartDashboardModel {
  final bool success;
  final Data? data;
  final String? message;

  SalesChartDashboardModel({required this.success, this.data, this.message});

  factory SalesChartDashboardModel.fromJson(Map<String, dynamic> json) {
    return SalesChartDashboardModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class Data {
  final User? user;
  final Period? period;
  final Visits? visits;
  final Expenses? expenses;
  final Targets? targets;
  final Summary? summary;

  Data({this.user, this.period, this.visits, this.expenses, this.targets, this.summary});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      period: json['period'] != null ? Period.fromJson(json['period']) : null,
      visits: json['visits'] != null ? Visits.fromJson(json['visits']) : null,
      expenses: json['expenses'] != null ? Expenses.fromJson(json['expenses']) : null,
      targets: json['targets'] != null ? Targets.fromJson(json['targets']) : null,
      summary: json['summary'] != null ? Summary.fromJson(json['summary']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'period': period?.toJson(),
      'visits': visits?.toJson(),
      'expenses': expenses?.toJson(),
      'targets': targets?.toJson(),
      'summary': summary?.toJson(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'department': department,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'monthName': monthName,
    };
  }
}

class Visits {
  final VisitDetail? doctor;
  final VisitDetail? chemist;
  final VisitDetail? stockist;
  final int? total;
  final int? scheduled;
  final int? confirmed;
  final int? submitted;
  final int? approved;
  final int? rejected;
  final int? draft;

  Visits({
    this.doctor,
    this.chemist,
    this.stockist,
    this.total,
    this.scheduled,
    this.confirmed,
    this.submitted,
    this.approved,
    this.rejected,
    this.draft,
  });

  factory Visits.fromJson(Map<String, dynamic> json) {
    return Visits(
      doctor: json['doctor'] != null ? VisitDetail.fromJson(json['doctor']) : null,
      chemist: json['chemist'] != null ? VisitDetail.fromJson(json['chemist']) : null,
      stockist: json['stockist'] != null ? VisitDetail.fromJson(json['stockist']) : null,
      total: json['total'],
      scheduled: json['scheduled'],
      confirmed: json['confirmed'],
      submitted: json['submitted'],
      approved: json['approved'],
      rejected: json['rejected'],
      draft: json['draft'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor': doctor?.toJson(),
      'chemist': chemist?.toJson(),
      'stockist': stockist?.toJson(),
      'total': total,
      'scheduled': scheduled,
      'confirmed': confirmed,
      'submitted': submitted,
      'approved': approved,
      'rejected': rejected,
      'draft': draft,
    };
  }
}

class VisitDetail {
  final int? scheduled;
  final int? confirmed;
  final int? total;

  VisitDetail({this.scheduled, this.confirmed, this.total});

  factory VisitDetail.fromJson(Map<String, dynamic> json) {
    return VisitDetail(
      scheduled: json['scheduled'],
      confirmed: json['confirmed'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduled': scheduled,
      'confirmed': confirmed,
      'total': total,
    };
  }
}

class Expenses {
  final int? total;
  final int? approved;
  final int? pending;
  final int? rejected;
  final double? totalAmount;
  final double? approvedAmount;
  final double? pendingAmount;
  final double? rejectedAmount;

  Expenses({
    this.total,
    this.approved,
    this.pending,
    this.rejected,
    this.totalAmount,
    this.approvedAmount,
    this.pendingAmount,
    this.rejectedAmount,
  });

  factory Expenses.fromJson(Map<String, dynamic> json) {
    return Expenses(
      total: json['total'],
      approved: json['approved'],
      pending: json['pending'],
      rejected: json['rejected'],
      totalAmount: json['totalAmount']?.toDouble(),
      approvedAmount: json['approvedAmount']?.toDouble(),
      pendingAmount: json['pendingAmount']?.toDouble(),
      rejectedAmount: json['rejectedAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
      'totalAmount': totalAmount,
      'approvedAmount': approvedAmount,
      'pendingAmount': pendingAmount,
      'rejectedAmount': rejectedAmount,
    };
  }
}

class Targets {
  final int? monthlyTarget;
  final int? achieved;
  final int? remaining;
  final int? achievementPercentage;
  final String? status;
  final String? deadline;
  final String? targetMonth;
  final String? targetYear;
  final bool? isCurrentMonth;
  final String? targetPeriod;
  final String? displayMessage;

  Targets({
    this.monthlyTarget,
    this.achieved,
    this.remaining,
    this.achievementPercentage,
    this.status,
    this.deadline,
    this.targetMonth,
    this.targetYear,
    this.isCurrentMonth,
    this.targetPeriod,
    this.displayMessage,
  });

  factory Targets.fromJson(Map<String, dynamic> json) {
    return Targets(
      monthlyTarget: json['monthlyTarget'],
      achieved: json['achieved'],
      remaining: json['remaining'],
      achievementPercentage: json['achievementPercentage'],
      status: json['status'],
      deadline: json['deadline'],
      targetMonth: json['targetMonth'],
      targetYear: json['targetYear'],
      isCurrentMonth: json['isCurrentMonth'],
      targetPeriod: json['targetPeriod'],
      displayMessage: json['displayMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyTarget': monthlyTarget,
      'achieved': achieved,
      'remaining': remaining,
      'achievementPercentage': achievementPercentage,
      'status': status,
      'deadline': deadline,
      'targetMonth': targetMonth,
      'targetYear': targetYear,
      'isCurrentMonth': isCurrentMonth,
      'targetPeriod': targetPeriod,
      'displayMessage': displayMessage,
    };
  }
}

class Summary {
  final String? totalActivities;
  final String? visitCompletionRate;
  final String? targetAchievement;
  final String? pendingExpenses;
  final String? totalExpenseAmount;

  Summary({
    this.totalActivities,
    this.visitCompletionRate,
    this.targetAchievement,
    this.pendingExpenses,
    this.totalExpenseAmount,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalActivities: json['totalActivities'],
      visitCompletionRate: json['visitCompletionRate'],
      targetAchievement: json['targetAchievement'],
      pendingExpenses: json['pendingExpenses'],
      totalExpenseAmount: json['totalExpenseAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalActivities': totalActivities,
      'visitCompletionRate': visitCompletionRate,
      'targetAchievement': targetAchievement,
      'pendingExpenses': pendingExpenses,
      'totalExpenseAmount': totalExpenseAmount,
    };
  }
}

