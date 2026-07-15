import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/collaboration_request_model.dart';



class CollaborationRequestCard
    extends StatelessWidget {
  const CollaborationRequestCard({
    super.key,
    required this.request,
    required this.loading,
    required this.onAccept,
    required this.onReject,
  });

  final CollaborationRequestModel request;

  final bool loading;

  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final user = request.tourPlan.user;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Text(
              user?.name ?? "-",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Employee Code : ${user?.employeeCode ?? '-'}",
            ),

            Text(
              "Date : ${DateFormat('dd MMM yyyy').format(request.date)}",
            ),

            Text(
              "Day Type : ${request.dayType}",
            ),

            Text(
              "Status : ${request.collaborationStatus}",
            ),

            const SizedBox(height: 16),

            Row(
              children: [

                ElevatedButton(
                  onPressed:
                  loading ? null : onAccept,
                  child: const Text("Accept"),
                ),

                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed:
                  loading ? null : onReject,
                  child: const Text("Reject"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}