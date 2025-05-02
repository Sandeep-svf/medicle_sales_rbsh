class TicketModel {
  final String id;
  final String title;
  final String description;
  final String? image;
  final String userId;
  final String userName;
  final String createdAt;


  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  // Factory method to create TicketModel from JSON
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      userId: json['userId'],
      userName: json['userName'],
      createdAt: json['createdAt'],
    );
  }
}
