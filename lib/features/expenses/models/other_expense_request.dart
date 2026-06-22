class OtherExpenseRequest {
  final String userId;
  final String description;
  final double amount;
  final String bill;
  final String date;

  OtherExpenseRequest({
    required this.userId,
    required this.description,
    required this.amount,
    required this.bill,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "category": "extra",
      "description": description,
      "amount": amount,
      "bill": bill,
      "date": date,
    };
  }
}