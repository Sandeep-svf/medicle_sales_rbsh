class TicketModel {
  final String? id;
  final String? title;
  final String? description;
  final String? image;
  final String? userId;
  final String? userName;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final UserModel? user;

  TicketModel({
    this.id,
    this.title,
    this.description,
    this.image,
    this.userId,
    this.userName,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id']?.toString(), // Ensure ID is string
      title: json['title'],
      description: json['description'],
      image: json['image'],
      userId: json['user_id']?.toString(),
      userName: json['user_name'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['User'] != null ? UserModel.fromJson(json['User']) : null,
    );
  }
}

class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? employeeCode;

  UserModel({this.id, this.name, this.email, this.employeeCode});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      name: json['name'],
      email: json['email'],
      employeeCode: json['employee_code'],
    );
  }
}

class TicketsResponseModel {
  final bool success;
  final int count;
  final List<TicketModel>? data;

  TicketsResponseModel({
    required this.success,
    required this.count,
    this.data,
  });

  factory TicketsResponseModel.fromJson(Map<String, dynamic> json) {
    return TicketsResponseModel(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: json['data'] != null
          ? (json['data'] as List)
          .map((item) => TicketModel.fromJson(item))
          .toList()
          : [],
    );
  }
}