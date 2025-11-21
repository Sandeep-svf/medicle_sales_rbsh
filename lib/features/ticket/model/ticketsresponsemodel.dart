import 'package:medicle_sales_rbsh/features/ticket/model/ticketmodal.dart';

class TicketsResponseModel {
  final bool success;
  final int count;
  final List<TicketModel>? data;

  TicketsResponseModel({
    required this.success,
    required this.count,
    this.data,
  });

  factory TicketsResponseModel.fromJson(Map<String, dynamic> json) {
    return TicketsResponseModel(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: json['data'] != null
          ? (json['data'] as List)
          .map((item) => TicketModel.fromJson(item))
          .toList()
          : [],
    );
  }
}
