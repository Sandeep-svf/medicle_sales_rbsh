import 'TravelDetails.dart';

class TravelAllowanceRequest {
  final String userId;
  final String category;
  final String description;
  final String bill;
  final String date; // <-- Add this
  final List<TravelDetail> travelDetails;

  TravelAllowanceRequest({
    required this.userId,
    required this.description,
    required this.date, // <-- Add this
    required this.travelDetails,
    this.category = "travel",
    this.bill = "",
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "category": category,
    "description": description,
    "bill": bill,
    "date": date, // <-- Add this
    "travelDetails": travelDetails.map((e) => e.toJson()).toList(),
  };
}