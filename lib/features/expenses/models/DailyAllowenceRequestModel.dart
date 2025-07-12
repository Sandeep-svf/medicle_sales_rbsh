class DailyAllowanceRequest {
  final String userId;
  final String category;
  final String description;
  final String bill;
  final String dailyAllowanceType;

  DailyAllowanceRequest({
    required this.userId,
    required this.description,
    required this.dailyAllowanceType,
    this.category = "daily",
    this.bill = "",
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "category": category,
    "description": description,
    "bill": bill,
    "dailyAllowanceType": dailyAllowanceType,
  };
}