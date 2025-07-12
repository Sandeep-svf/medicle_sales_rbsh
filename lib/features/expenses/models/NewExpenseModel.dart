import 'TravelDetails.dart';

class ExpenseModel {
  final String id;
  final String user;
  final String userName;
  final String category;
  final String description;
  final String bill;
  final String status;
  final DateTime date;
  final List<TravelDetail> travelDetails;
  final double ratePerKm;
  final double totalDistanceKm;
  final double amount;
  final int editCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final String? dailyAllowanceType;

  ExpenseModel({
    required this.id,
    required this.user,
    required this.userName,
    required this.category,
    required this.description,
    required this.bill,
    required this.status,
    required this.date,
    required this.travelDetails,
    required this.ratePerKm,
    required this.totalDistanceKm,
    required this.amount,
    required this.editCount,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.dailyAllowanceType,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['_id'],
      user: json['user'],
      userName: json['userName'],
      category: json['category'],
      description: json['description'],
      bill: json['bill'],
      status: json['status'],
      date: DateTime.parse(json['date']),
      travelDetails: (json['travelDetails'] as List)
          .map((e) => TravelDetail.fromJson(e))
          .toList(),
      ratePerKm: (json['ratePerKm'] as num).toDouble(),
      totalDistanceKm: (json['totalDistanceKm'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      editCount: json['editCount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
      dailyAllowanceType: json['dailyAllowanceType'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'user': user,
    'userName': userName,
    'category': category,
    'description': description,
    'bill': bill,
    'status': status,
    'date': date.toIso8601String(),
    'travelDetails': travelDetails.map((e) => e.toJson()).toList(),
    'ratePerKm': ratePerKm,
    'totalDistanceKm': totalDistanceKm,
    'amount': amount,
    'editCount': editCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': v,
    if (dailyAllowanceType != null)
      'dailyAllowanceType': dailyAllowanceType,
  };
}
