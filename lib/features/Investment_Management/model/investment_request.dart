import '../enum.dart';

class InvestmentRequestModel {
  String? doctorId;
  String? doctorName;

  InvestmentMode mode = InvestmentMode.cash;

  String status = "Pending";

  double? amount;
  String? purpose;

  /// NEFT
  String? accountHolder;
  String? accountNumber;
  String? ifsc;
  String? bankName;

  /// UPI
  String? upiId;

  /// Gift
  String? justification;
  List<GiftItem> items = [];

  InvestmentRequestModel();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    json["doctorId"] = doctorId;
    json["status"] = status;

    switch (mode) {
      case InvestmentMode.cash:
        json["paymentMode"] = "Cash";
        json["amount"] = amount;
        json["purpose"] = purpose;
        break;

      case InvestmentMode.neft:
        json["paymentMode"] = "NEFT";
        json["amount"] = amount;
        json["purpose"] = purpose;

        final account = accountNumber?.trim() ?? "";
        final ifscCode = ifsc?.trim() ?? "";
        final bank = bankName?.trim() ?? "";
        final beneficiary = accountHolder?.trim() ?? "";

        if ([account, ifscCode, bank, beneficiary]
            .any((value) => value.isNotEmpty)) {
          json["bankDetails"] = "A/C: $account, "
              "IFSC: $ifscCode, "
              "Bank: $bank, "
              "Beneficiary: $beneficiary";
        }

        break;

      case InvestmentMode.upi:
        json["paymentMode"] = "UPI";
        json["amount"] = amount;
        json["purpose"] = purpose;
        json["upiId"] = upiId;

        break;

      case InvestmentMode.emi:
        json["paymentMode"] = "EMI";

        json["amount"] = amount;

        json["purpose"] = purpose;

        json["bankDetails"] = "$accountHolder | "
            "A/C: $accountNumber | "
            "IFSC: $ifsc";

        break;

      case InvestmentMode.gift:
        json["paymentMode"] = "Items/Gift";
        json["justification"] = justification;

        json["items"] = items.map((e) => e.toJson()).toList();

        break;
    }

    json.removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );

    return json;
  }
}

class GiftItem {
  String itemName;
  int quantity;
  double value;

  GiftItem({
    required this.itemName,
    required this.quantity,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      "itemName": itemName,
      "quantity": quantity,
      "value": value,
    };
  }
}
