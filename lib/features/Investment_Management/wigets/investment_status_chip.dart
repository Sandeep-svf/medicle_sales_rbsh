import 'package:flutter/material.dart';

class InvestmentStatusChip extends StatelessWidget {
  final String status;

  const InvestmentStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status.toLowerCase()) {
      case "pending":
        color = Colors.orange;
        text = "Pending";
        icon = Icons.schedule;
        break;

      case "approved":
        color = Colors.blue;
        text = "Approved";
        icon = Icons.thumb_up_alt_outlined;
        break;

      case "paid":
        color = Colors.green;
        text = "Paid";
        icon = Icons.check_circle_outline;
        break;

      case "rejected":
        color = Colors.red;
        text = "Rejected";
        icon = Icons.cancel_outlined;
        break;

      case "draft":
        color = Colors.grey;
        text = "Draft";
        icon = Icons.edit_note;
        break;

      default:
        color = Colors.grey;
        text = status;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: .20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}