class SalesLogModel {
  final String id;
  final String doctorName;
  final String salesRep;
  final String callNotes;
  final String userName;
  final String dateTime;

  SalesLogModel({
    required this.id,
    required this.doctorName,
    required this.salesRep,
    required this.callNotes,
    required this.userName,
    required this.dateTime,
  });

  factory SalesLogModel.fromJson(Map<String, dynamic> json) {
    return SalesLogModel(
      id: json["_id"] ?? "",
      doctorName: json["doctorName"] ?? "Unknown Doctor",
      salesRep: json["salesRep"] ?? "Unknown Sales Rep",
      callNotes: json["callNotes"] ?? "No Notes",
      userName: json["userName"] ?? "Unknown User",
      dateTime: json["dateTime"] ?? "",
    );
  }
}
