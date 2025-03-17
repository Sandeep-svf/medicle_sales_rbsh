class SalesLogModel {
  final String name;
  final String salesRepresentative;
  final String time;
  final String callNotes;

  SalesLogModel({
    required this.name,
    required this.salesRepresentative,
    required this.time,
    required this.callNotes,
  });

  // Factory method to create an instance from JSON
  factory SalesLogModel.fromJson(Map<String, dynamic> json) {
    return SalesLogModel(
      name: json["doctor_name"] ?? "",
      salesRepresentative: json["sales_rep"] ?? "",
      time: json["call_time"] ?? "",
      callNotes: json["call_notes"] ?? "",
    );
  }

  // Convert model to JSON (optional, for POST requests)
  Map<String, dynamic> toJson() {
    return {
      "doctor_name": name,
      "sales_rep": salesRepresentative,
      "call_time": time,
      "call_notes": callNotes,
    };
  }
}
