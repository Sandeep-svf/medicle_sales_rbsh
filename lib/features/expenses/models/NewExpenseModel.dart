import 'TravelDetails.dart';


class ExpenseModel {
  final String id;
  final String userId;
  final String userName;
  final String category;
  final String description;
  final String bill;
  final String status;
  final String date;
  final List<TravelDetail> travelDetails;
  final String ratePerKm;
  final String totalDistanceKm;
  final String? dailyAllowanceType;
  final String amount;
  final int editCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String user;
  final String userName2;  // Duplicate field (userName from original JSON)
  final String totalDistanceKm2; // Duplicate field (totalDistanceKm from original JSON)
  final String ratePerKm2; // Duplicate field (ratePerKm from original JSON)
  final List<TravelDetail> travelDetails2; // Duplicate field (travelDetails from original JSON)
  final String? dailyAllowanceType2; // Duplicate field (dailyAllowanceType from original JSON)

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.description,
    required this.bill,
    required this.status,
    required this.date,
    required this.travelDetails,
    required this.ratePerKm,
    required this.totalDistanceKm,
    this.dailyAllowanceType,
    required this.amount,
    required this.editCount,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.userName2,
    required this.totalDistanceKm2,
    required this.ratePerKm2,
    required this.travelDetails2,
    this.dailyAllowanceType2,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      bill: json['bill'] ?? '',
      status: json['status'] ?? '',
      date: json['date'] ?? '',
      travelDetails: json['travel_details'] != null
          ? List<TravelDetail>.from(
          json['travel_details'].map((x) => TravelDetail.fromJson(x)))
          : [],
      ratePerKm: json['rate_per_km'] ?? '',
      totalDistanceKm: json['total_distance_km'] ?? '',
      dailyAllowanceType: json['daily_allowance_type'],
      amount: json['amount'] ?? '',
      editCount: json['edit_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      user: json['user'] ?? '',
      userName2: json['userName'] ?? '',
      totalDistanceKm2: json['totalDistanceKm'] ?? '',
      ratePerKm2: json['ratePerKm'] ?? '',
      travelDetails2: json['travelDetails'] != null
          ? List<TravelDetail>.from(
          json['travelDetails'].map((x) => TravelDetail.fromJson(x)))
          : [],
      dailyAllowanceType2: json['dailyAllowanceType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'category': category,
      'description': description,
      'bill': bill,
      'status': status,
      'date': date,
      'travel_details': travelDetails.map((x) => x.toJson()).toList(),
      'rate_per_km': ratePerKm,
      'total_distance_km': totalDistanceKm,
      'daily_allowance_type': dailyAllowanceType,
      'amount': amount,
      'edit_count': editCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user,
      'userName': userName2,
      'totalDistanceKm': totalDistanceKm2,
      'ratePerKm': ratePerKm2,
      'travelDetails': travelDetails2.map((x) => x.toJson()).toList(),
      'dailyAllowanceType': dailyAllowanceType2,
    };
  }
}

class TravelDetail {
  final double km;
  final String from;
  final String to;

  TravelDetail({
    required this.km,
    required this.from,
    required this.to,
  });

  factory TravelDetail.fromJson(Map<String, dynamic> json) {
    return TravelDetail(
      km: json['km']?.toDouble() ?? 0.0,
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'km': km,
      'from': from,
      'to': to,
    };
  }
}

