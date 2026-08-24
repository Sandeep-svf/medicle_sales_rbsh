import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../controller/add_investment_controller.dart';

class SubmitButtons extends GetView<AddInvestmentController> {
  const SubmitButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPreparingImage = controller.isPickingPaymentProof.value;
      final isSubmitting = controller.isLoading.value;
      final isBusy = controller.isLoading.value || isPreparingImage;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: isBusy ? null : controller.submitInvestment,
          icon: isPreparingImage || isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
          label: Text(
            isPreparingImage
                ? "Preparing Image..."
                : isSubmitting
                    ? "Submitting..."
                    : controller.submitButtonLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    });
  }
}
