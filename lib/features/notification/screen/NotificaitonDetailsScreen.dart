import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../model/NotificationModel.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailsScreen({Key? key, required this.notification})
      : super(key: key);

  // Convert time to a more readable format (Date + Time)
  String formatDate(String createdAt) {
    final DateTime notificationTime = DateTime.parse(createdAt);
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(notificationTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(notification.title),
        backgroundColor:
            TColors.primary, // Choose any color that suits your app
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              notification.title,
              style: TextStyle(
                fontSize: TSizes.v24,
                fontWeight: FontWeight.bold,
                color: TColors.pureBlack,
              ),
            ),
            SizedBox(height: TSizes.v8),

            // Body Section
            Text(
              notification.body,
              style: TextStyle(
                fontSize: TSizes.v16,
                color: TColors.materialGrey700,
              ),
            ),
            SizedBox(height: TSizes.v20),

            // Date-time Section
            Text(
              "Sent on: ${formatDate(notification.createdAt)}",
              style: TextStyle(
                fontSize: TSizes.v14,
                color: TColors.materialGrey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
