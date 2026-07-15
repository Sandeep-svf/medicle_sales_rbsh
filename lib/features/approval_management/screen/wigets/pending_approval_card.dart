import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/pending_approval_model.dart';



class PendingApprovalCard extends StatelessWidget {
  const PendingApprovalCard({
    super.key,
    required this.plan,
    required this.onView,
    required this.onApprove,
    required this.onReturn,
    required this.loading,
  });

  final PendingApprovalModel plan;

  final VoidCallback onView;
  final VoidCallback onApprove;
  final VoidCallback onReturn;

  final bool loading;

  @override
  Widget build(BuildContext context) {
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
              plan.user.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Employee Code : ${plan.user.employeeCode ?? '-'}",
            ),

            Text(
              "Month : ${DateFormat.MMMM().format(DateTime(plan.year, plan.month))} ${plan.year}",
            ),

            Text("Status : ${plan.status}"),

            Text(
              "Submitted : ${DateFormat('dd MMM yyyy').format(plan.createdAt)}",
            ),

            const SizedBox(height: 16),

            Row(
              children: [

                OutlinedButton(
                  onPressed: onView,
                  child: const Text("View"),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed:
                  loading ? null : onApprove,
                  child: const Text("Approve"),
                ),

                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed:
                  loading ? null : onReturn,
                  child: const Text("Return"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}