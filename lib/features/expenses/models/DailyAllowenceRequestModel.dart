class DailyAllowanceRequest {
  final String userId;
  final String category;
  final String description;
  final String bill;
  final String dailyAllowanceType;
  final String date;

  DailyAllowanceRequest({
    required this.userId,
    required this.description,
    required this.dailyAllowanceType,
    this.category = "daily",
    this.bill = "",
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "category": category,
    "description": description,
    "bill": bill,
    "dailyAllowanceType": dailyAllowanceType,
    "date": date,
  };
}