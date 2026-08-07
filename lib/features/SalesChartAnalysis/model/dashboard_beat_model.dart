class DashboardBeatResponse {
  final bool success;
  final int count;
  final List<DashboardBeatModel> data;

  DashboardBeatResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory DashboardBeatResponse.fromJson(Map<String, dynamic> json) {
    return DashboardBeatResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => DashboardBeatModel.fromJson(e))
          .toList(),
    );
  }
}

class DashboardBeatModel {
  final String id;
  final String name;
  final String color;
  final bool isActive;
  final List<DashboardBeatArea> areas;

  const DashboardBeatModel({
    required this.id,
    required this.name,
    required this.color,
    required this.isActive,
    required this.areas,
  });

  factory DashboardBeatModel.fromJson(Map<String, dynamic> json) {
    return DashboardBeatModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#2196F3',
      isActive: json['is_active'] ?? false,
      areas: (json['areas'] as List? ?? [])
          .map((e) => DashboardBeatArea.fromJson(e))
          .toList(),
    );
  }
}

class DashboardBeatArea {
  final String id;
  final String name;
  final String pincode;
  final String postOffice;

  const DashboardBeatArea({
    required this.id,
    required this.name,
    required this.pincode,
    required this.postOffice,
  });

  factory DashboardBeatArea.fromJson(Map<String, dynamic> json) {
    return DashboardBeatArea(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      pincode: json['pincode'] ?? '',
      postOffice: json['post_office'] ?? '',
    );
  }
}