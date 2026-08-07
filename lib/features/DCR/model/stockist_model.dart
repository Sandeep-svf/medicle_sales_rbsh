class StockistModel {
  final String id;
  final String name;
  final String contactPerson;
  final String mobileNumber;

  const StockistModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.mobileNumber,
  });

  factory StockistModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const StockistModel(
        id: '',
        name: '',
        contactPerson: '',
        mobileNumber: '',
      );
    }

    return StockistModel(
      id: json['id'] ?? '',
      name: json['stockist_name'] ?? json['name'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
    );
  }
}