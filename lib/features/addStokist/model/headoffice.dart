// lib/screens/pharma_distributor_form/models/head_office.dart
class HeadOffice1 {
  final String id;
  final String name;

  HeadOffice1({required this.id, required this.name});

  factory HeadOffice1.fromJson(Map<String, dynamic> json) {
    return HeadOffice1(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
