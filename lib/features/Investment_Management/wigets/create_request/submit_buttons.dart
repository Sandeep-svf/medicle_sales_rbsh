import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../controller/add_investment_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

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
                  width: TSizes.v18,
                  height: TSizes.v18,
                  child: CircularProgressIndicator(
                    strokeWidth: TSizes.v2,
                    color: TColors.white,
                  ),
                )
              : const Icon(
                  Icons.send,
                  color: TColors.white,
                ),
          label: Text(
            isPreparingImage
                ? "Preparing Image..."
                : isSubmitting
                    ? "Submitting..."
                    : controller.submitButtonLabel,
            style: const TextStyle(
              color: TColors.white,
              fontWeight: FontWeight.bold,
              fontSize: TSizes.v16,
            ),
          ),
        ),
      );
    });
  }
}
