import '../enum.dart';

class InvestmentModel {
  final String id;
  final String doctorName;
  final String type;
  final double amount;
  final DateTime submittedDate;
  final String purpose;
  final InvestmentStatus status;
  final String? remark;

  InvestmentModel({
    required this.id,
    required this.doctorName,
    required this.type,
    required this.amount,
    required this.submittedDate,
    required this.purpose,
    required this.status,
    this.remark,
  });
}