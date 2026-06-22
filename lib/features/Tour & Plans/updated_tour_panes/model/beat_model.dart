class BeatModel {
  final String id;
  final String name;

  BeatModel({
    required this.id,
    required this.name,
  });

  factory BeatModel.fromJson(Map<String, dynamic> json) {
    return BeatModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}