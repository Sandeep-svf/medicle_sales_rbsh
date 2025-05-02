class Sender {
  final String id;
  final String name;
  final String email;

  Sender({
    required this.id,
    required this.name,
    required this.email,
  });

  // Factory constructor to parse JSON into a Sender object
  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class Recipient {
  final String user;
  final bool isRead;
  final String readAt;
  final String id;

  Recipient({
    required this.user,
    required this.isRead,
    required this.readAt,
    required this.id,
  });

  // Factory constructor to parse JSON into a Recipient object
  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      user: json['user'],
      isRead: json['isRead'],
      readAt: json['readAt'],
      id: json['_id'],
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final Sender sender;
  final List<Recipient> recipients;
  final bool isBroadcast;
  final String createdAt;
  final String updatedAt;
  final int version;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.sender,
    required this.recipients,
    required this.isBroadcast,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  // Factory constructor to parse JSON into a NotificationModel object
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    var recipientList = json['recipients'] as List? ?? [];
    return NotificationModel(
      id: json['_id'],
      title: json['title'],
      body: json['body'],
      sender: Sender.fromJson(json['sender']),
      recipients: recipientList.map((e) => Recipient.fromJson(e)).toList(),
      isBroadcast: json['isBroadcast'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      version: json['__v'],
    );
  }
}
