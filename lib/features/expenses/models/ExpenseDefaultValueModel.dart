class ExpenseDefaultValueModel {
  final double? ratePerKm;
  final double? headOfficeAmount;
  final double? exHeadquartersAmount;
  final double? outsideHeadOfficeAmount;
  final DateTime? effectiveDate;

  ExpenseDefaultValueModel({
    this.ratePerKm,
    this.headOfficeAmount,
    this.exHeadquartersAmount,
    this.outsideHeadOfficeAmount,
    this.effectiveDate,
  });

  factory ExpenseDefaultValueModel.fromJson(Map<String, dynamic> json) {
    return ExpenseDefaultValueModel(
      ratePerKm: double.tryParse(json['ratePerKm']?.toString() ?? ''),
      headOfficeAmount: double.tryParse(json['headOfficeAmount']?.toString() ?? ''),
      exHeadquartersAmount: double.tryParse(json['exHeadquartersAmount']?.toString() ?? ''),
      outsideHeadOfficeAmount: double.tryParse(
        json['outsideHeadOfficeAmount']?.toString() ?? '',
      ),
      effectiveDate: json['effectiveDate'] != null
          ? DateTime.tryParse(json['effectiveDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ratePerKm': ratePerKm,
      'headOfficeAmount': headOfficeAmount,
      'exHeadquartersAmount': exHeadquartersAmount,
      'outsideHeadOfficeAmount': outsideHeadOfficeAmount,
      'effectiveDate': effectiveDate?.toIso8601String(),
    };
  }
}