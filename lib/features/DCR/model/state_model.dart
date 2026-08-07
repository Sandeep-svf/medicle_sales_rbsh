class StateModel {
  final String id;
  final String name;
  final String code;

  const StateModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory StateModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const StateModel(
        id: '',
        name: '',
        code: '',
      );
    }

    return StateModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}