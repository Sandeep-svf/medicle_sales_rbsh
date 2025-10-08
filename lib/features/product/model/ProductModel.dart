import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String? salt;
  final String? description;
  final String? dosage;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.salt,
    this.description,
    this.dosage,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory: JSON -> Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? "",                        // fallback empty string
      name: json['name'] ?? "Unnamed Product",     // fallback default name
      salt: json['salt'] == "" ? null : json['salt'],
      description: json['description'] == "" ? null : json['description'],
      dosage: json['dosage'] == "" ? null : json['dosage'],
      image: json['image'],                        // already nullable
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Method: Product -> JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "salt": salt,
      "description": description,
      "dosage": dosage,
      "image": image,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }

  /// Helper: Convert list of JSON objects -> List<Product>
  static List<Product> listFromJson(String str) {
    final data = json.decode(str);
    return List<Product>.from(data.map((x) => Product.fromJson(x)));
  }
}
