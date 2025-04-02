class Expense {
  final String id;
  final String user;
  final String userName;
  final String category;
  final double amount;
  final String description;
  final String bill;
  final String status;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.user,
    required this.userName,
    required this.category,
    required this.amount,
    required this.description,
    required this.bill,
    required this.status,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["_id"] ?? "",
      user: json["user"] ?? "",
      userName: json["userName"] ?? "",
      category: json["category"] ?? "",
      amount: (json["amount"] ?? 0).toDouble(),
      description: json["description"] ?? "",
      bill: json["bill"] ?? "",
      status: json["status"] ?? "pending",
      date: DateTime.parse(json["date"]),
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}
