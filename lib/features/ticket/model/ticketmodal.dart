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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      userId: json['user_id'],
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
      id: json['id'],
      name: json['name'],
      email: json['email'],
      employeeCode: json['employee_code'],
    );
  }
}
