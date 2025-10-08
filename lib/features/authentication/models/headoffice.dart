class HeadOfficeCustom {
  final String? id;
  final String? name;

  HeadOfficeCustom({this.id, this.name});

  // Factory method to create an instance from JSON
  factory HeadOfficeCustom.fromJson(Map<String, dynamic> json) {
    return HeadOfficeCustom(
      id: json['_id'],
      name: json['name'],
    );
  }

  // Method to convert this instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}
