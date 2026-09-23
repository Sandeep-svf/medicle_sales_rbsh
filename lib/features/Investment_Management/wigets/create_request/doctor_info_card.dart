import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../controller/add_investment_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class DoctorInfoCard extends GetView<AddInvestmentController> {
  const DoctorInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doctorName = controller.selectedDoctorName.value;

      if (doctorName.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TColors.primary.withOpacity(.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TColors.primary.withOpacity(.15),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: TSizes.v30,
              backgroundColor: TColors.primary.withOpacity(.12),
              child: Text(
                doctorName[0].toUpperCase(),
                style: const TextStyle(
                  color: TColors.primary,
                  fontSize: TSizes.v22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: TSizes.v16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: const TextStyle(
                      fontSize: TSizes.v18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: TSizes.v6),
                  Text(
                    TTexts.uiTextDoctorSelected,
                    style: TextStyle(
                      color: TColors.materialGrey700,
                    ),
                  ),
                  const SizedBox(height: TSizes.v10),
                  Wrap(
                    spacing: TSizes.v8,
                    children: [
                      _chip(
                        "Selected",
                        TColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
