import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/NotificationModel.dart';


class NotificationController {
  final String userId;
  final String token;

  NotificationController({
    required this.userId,
    required this.token,
  });

  // Fetch notifications from API
  Future<List<NotificationModel>> fetchNotifications() async {
    final url = Uri.parse('https://medi-glucks-erp.onrender.com/api/notifications?userId=$userId');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // Delete a notification by ID
  Future<void> deleteNotification(String notificationId) async {
    final url = Uri.parse('https://medi-glucks-erp.onrender.com/api/notifications/$notificationId');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }, body: json.encode({
      'userId': userId,
    }));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete the notification');
    }
  }
}
