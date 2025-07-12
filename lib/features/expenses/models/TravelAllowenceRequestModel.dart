import 'TravelDetails.dart';

class TravelAllowanceRequest {
  final String userId;
  final String category;
  final String description;
  final String bill;
  final List<TravelDetail> travelDetails;

  TravelAllowanceRequest({
    required this.userId,
    required this.description,
    required this.travelDetails,
    this.category = "travel",
    this.bill = "",
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "category": category,
    "description": description,
    "bill": bill,
    "travelDetails": travelDetails.map((e) => e.toJson()).toList(),
  };
}