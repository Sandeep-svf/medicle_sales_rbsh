class BeatModel {
  final String id;
  final String name;
  final String userId;
  final String color;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<BeatAreaModel> areas;

  BeatModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.color,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.areas,
  });

  factory BeatModel.fromJson(Map<String, dynamic> json) {
    return BeatModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      isActive: json['is_active'] == true,

      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),

      areas: (json['areas'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map((e) => BeatAreaModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}


class BeatAreaModel {
  final String id;
  final String name;
  final String pincode;
  final String postOffice;

  BeatAreaModel({
    required this.id,
    required this.name,
    required this.pincode,
    required this.postOffice,
  });

  factory BeatAreaModel.fromJson(Map<String, dynamic> json) {
    return BeatAreaModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      postOffice: json['post_office']?.toString() ?? '',
    );
  }
}