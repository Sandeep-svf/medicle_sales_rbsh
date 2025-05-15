import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../controller/NotificationController.dart';
import '../model/NotificationModel.dart';
import 'NotificaitonDetailsScreen.dart';  // Import NotificationDetailsScreen

void main() {
  runApp(MaterialApp(home: NotificationScreen()));
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationController _notificationController;
  List<NotificationModel> notifications = [];
  bool isLoading = false; // Flag to track loading state

  final String userId = "67d56a35a2227082ae9282b2";  // Replace with actual user ID
  final String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZDU2YTM1YTIyMjcwODJhZTkyODJiMiIsInJvbGUiOiJVc2VyIiwiaWF0IjoxNzQ2MTY2ODM1LCJleHAiOjE3NDY3NzE2MzV9.RHujLS1ivUOQQskwQuWzqkyIuT5lti8gRBZeaNsnZCc ";  // Replace with actual token


  //

  @override
  void initState() {
    super.initState();
    _notificationController = NotificationController(userId: userId, token: token);
    fetchNotifications();
  }

  // Fetch notifications
  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true; // Show loader when the API request is in progress
    });
    try {
      final fetchedNotifications = await _notificationController.fetchNotifications();
      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loader on error
      });
      print("Error fetching notifications: $e");
    }
  }

  // Delete a notification
  void deleteNotification(String notificationId) async {
    setState(() {
      isLoading = true; // Show loader when the delete API request is in progress
    });
    try {
      await _notificationController.deleteNotification(notificationId);
      setState(() {
        notifications.removeWhere((notification) => notification.id == notificationId);
        isLoading = false;
      });
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Notification deleted successfully',
        confirmBtnText: 'OK',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();  // Close the dialog
        },
        width: 300,
        title: 'Success',
      );
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Failed to delete the notification',
        confirmBtnText: 'Retry',
        onConfirmBtnTap: () {
          Navigator.of(context).pop();  // Close the dialog
        },
        width: 300,
        title: 'Error',
      );
    }
  }

  // Convert time string to "2 hours ago", "20 days ago", etc.
  String getTimeAgo(String createdAt) {
    final DateTime notificationTime = DateTime.parse(createdAt);
    final Duration difference = DateTime.now().difference(notificationTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                notifications.clear();
              });
            },
            color: Colors.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: notifications.isEmpty
            ? Center(child: Text('No Notifications'))
            : ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationCard(
              notification: notification, // Pass notification object
              onDelete: () => deleteNotification(notification.id),
            );
          },
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDelete;

  const NotificationCard({
    required this.notification,
    required this.onDelete,
  });

  // Convert time string to "2 hours ago", "20 days ago", etc.
  String getTimeAgo(String createdAt) {
    final DateTime notificationTime = DateTime.parse(createdAt);
    final Duration difference = DateTime.now().difference(notificationTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      color: notification.recipients.isEmpty || notification.recipients[0].isRead
          ? Colors.grey[300]
          : Colors.white, // Adjust card color based on isRead status
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          notification.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTimeAgo(notification.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailsScreen(notification: notification),
            ),
          );
        },
      ),
    );
  }
}
