import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:quickalert/quickalert.dart';

void main() {
  runApp(MaterialApp(home: NotificationScreen()));
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, String>> notifications = [
    {
      'title': 'New Message Received',
      'description': 'You have a new message from John Doe.',
      'time': '2 mins ago',
    },
    {
      'title': 'Order Shipped',
      'description': 'Your order #34567 has been shipped.',
      'time': '1 hour ago',
    },
    {
      'title': 'Reminder: Meeting at 3 PM',
      'description': 'Don\'t forget your meeting with the team.',
      'time': '2 hours ago',
    },
    {
      'title': 'App Update Available',
      'description': 'An update is available for the app.',
      'time': '5 hours ago',
    },
  ];

  // Delete specific notification
  void deleteNotification(int index) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'Are you sure you want to delete this notification?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'Cancel',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () {
        setState(() {
          notifications.removeAt(index);
        });
        Navigator.of(context).pop();  // Close the dialog
      },
      width: 300, // Set a fixed width to make the dialog compact

      title: 'Confirm',
    );
  }

  // Clear all notifications
  void clearAllNotifications() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'Are you sure you want to delete all notifications?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'Cancel',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () {
        setState(() {
          notifications.clear();
        });
        Navigator.of(context).pop();  // Close the dialog
      },
      width: 300, // Set a fixed width to make the dialog compact

      title: 'Confirm',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: TColors.primary,
        actions: [
          // Clear All Button
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: clearAllNotifications,
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
            return NotificationCard(
              title: notifications[index]['title']!,
              description: notifications[index]['description']!,
              time: notifications[index]['time']!,
              onDelete: () => deleteNotification(index),
            );
          },
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final VoidCallback onDelete;

  const NotificationCard({
    required this.title,
    required this.description,
    required this.time,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
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
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: TColors.primary),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
