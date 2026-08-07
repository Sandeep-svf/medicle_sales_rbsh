class ChemistModel {
  final String id;
  final String name;
  final String contactPerson;
  final String mobileNumber;

  const ChemistModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.mobileNumber,
  });

  factory ChemistModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ChemistModel(
        id: '',
        name: '',
        contactPerson: '',
        mobileNumber: '',
      );
    }

    return ChemistModel(
      id: json['id'] ?? '',
      name: json['chemist_name'] ?? json['name'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
    );
  }
}