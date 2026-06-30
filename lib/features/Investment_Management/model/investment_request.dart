

import '../enum.dart';

class InvestmentRequestModel {
  String? doctorId;
  String? doctorName;

  InvestmentMode mode;

  double amount;

  String purpose;

  /// NEFT
  String accountHolder;
  String accountNumber;
  String ifsc;
  String bankName;

  /// UPI
  String upiId;

  /// Gift
  String itemName;
  int quantity;
  double itemValue;

  InvestmentRequestModel({
    this.doctorId,
    this.doctorName,
    this.mode = InvestmentMode.cash,
    this.amount = 0,
    this.purpose = "",
    this.accountHolder = "",
    this.accountNumber = "",
    this.ifsc = "",
    this.bankName = "",
    this.upiId = "",
    this.itemName = "",
    this.quantity = 1,
    this.itemValue = 0,
  });
}