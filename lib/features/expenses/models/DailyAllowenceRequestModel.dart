class DailyAllowanceRequest {
  final String userId;
  final String category;
  final String description;
  final String bill;
  final String dailyAllowanceType;
  final double? amount;
  final String date;

  DailyAllowanceRequest({
    required this.userId,
    required this.description,
    required this.dailyAllowanceType,
    this.category = "daily",
    this.bill = "",
    this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "category": category,
    "description": description,
    "bill": bill,
    "dailyAllowanceType": dailyAllowanceType,
    if (amount != null) "amount": amount,
    "date": date,
  };
}
