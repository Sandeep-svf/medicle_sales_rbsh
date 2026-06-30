import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colors.dart';
import '../controller/investment_controller.dart';
import '../enum.dart';


class InvestmentSummary extends GetView<InvestmentController> {
  const InvestmentSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.investments;

      int pending = list
          .where((e) => e.status == InvestmentStatus.pending)
          .length;

      int approved = list
          .where((e) => e.status == InvestmentStatus.approved)
          .length;

      int paid = list
          .where((e) => e.status == InvestmentStatus.paid)
          .length;

      int rejected = list
          .where((e) => e.status == InvestmentStatus.rejected)
          .length;

      return Row(
        children: [
          Expanded(
            child: _item(
              "Pending",
              pending.toString(),
              Colors.orange,
              Icons.schedule,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _item(
              "Approved",
              approved.toString(),
              Colors.blue,
              Icons.thumb_up_alt_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _item(
              "Paid",
              paid.toString(),
              Colors.green,
              Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _item(
              "Rejected",
              rejected.toString(),
              Colors.red,
              Icons.cancel_outlined,
            ),
          ),
        ],
      );
    });
  }

  Widget _item(
      String title,
      String value,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: TColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }
}