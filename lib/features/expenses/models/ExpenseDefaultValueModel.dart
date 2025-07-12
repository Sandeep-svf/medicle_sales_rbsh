class ExpenseDefaultValueModel {
  final String? id;
  final double? ratePerKm;
  final int? headOfficeAmount;
  final int? outsideHeadOfficeAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpenseDefaultValueModel({
    this.id,
    this.ratePerKm,
    this.headOfficeAmount,
    this.outsideHeadOfficeAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseDefaultValueModel.fromJson(Map<String, dynamic> json) {
    return ExpenseDefaultValueModel(
      id: json['_id'] as String?,
      ratePerKm: (json['ratePerKm'] as num?)?.toDouble(),
      headOfficeAmount: json['headOfficeAmount'] as int?,
      outsideHeadOfficeAmount: json['outsideHeadOfficeAmount'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ratePerKm': ratePerKm,
      'headOfficeAmount': headOfficeAmount,
      'outsideHeadOfficeAmount': outsideHeadOfficeAmount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
