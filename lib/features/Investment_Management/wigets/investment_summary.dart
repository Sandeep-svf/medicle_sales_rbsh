import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../controller/investment_controller.dart';
import '../enum.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class InvestmentSummary extends GetView<InvestmentController> {
  const InvestmentSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.investments;

      int pending =
          list.where((e) => e.status == InvestmentStatus.pending).length;

      int approved =
          list.where((e) => e.status == InvestmentStatus.approved).length;

      int paid = list.where((e) => e.status == InvestmentStatus.paid).length;

      int rejected =
          list.where((e) => e.status == InvestmentStatus.rejected).length;

      return Row(
        children: [
          Expanded(
            child: _item(
              "Pending",
              pending.toString(),
              TColors.materialOrange,
              Icons.schedule,
            ),
          ),
          const SizedBox(width: TSizes.v12),
          Expanded(
            child: _item(
              "Approved",
              approved.toString(),
              TColors.materialBlue,
              Icons.thumb_up_alt_outlined,
            ),
          ),
          const SizedBox(width: TSizes.v12),
          Expanded(
            child: _item(
              "Paid",
              paid.toString(),
              TColors.materialGreen,
              Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: TSizes.v12),
          Expanded(
            child: _item(
              "Rejected",
              rejected.toString(),
              TColors.materialRed,
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
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(.25),
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.pureBlack.withOpacity(.04),
            blurRadius: TSizes.v10,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(height: TSizes.v10),
          Text(
            value,
            style: const TextStyle(
              fontSize: TSizes.v28,
              fontWeight: FontWeight.bold,
              color: TColors.primary,
            ),
          ),
          const SizedBox(height: TSizes.v4),
          Text(title),
        ],
      ),
    );
  }
}
