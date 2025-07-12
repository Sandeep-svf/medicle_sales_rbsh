class ProductModel {
  final String id;
  final String name;
  final String salt;
  final String description;
  final String dosage;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.salt,
    required this.description,
    required this.dosage,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ProductModel(
        id: '',
        name: '',
        salt: '',
        description: '',
        dosage: '',
        image: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return ProductModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      salt: json['salt']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'salt': salt,
      'description': description,
      'dosage': dosage,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    try {
      if (value == null) return DateTime.now();
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}
