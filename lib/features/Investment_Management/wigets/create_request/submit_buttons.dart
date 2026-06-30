import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../utils/constants/colors.dart';
import '../../controller/add_investment_controller.dart';


class SubmitButtons extends GetView<AddInvestmentController> {
  const SubmitButtons({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        SizedBox(

          width: double.infinity,

          child: ElevatedButton.icon(

            style: ElevatedButton.styleFrom(

              backgroundColor: TColors.primary,

              padding: const EdgeInsets.symmetric(
                vertical: 18,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),

            ),

            onPressed: controller.submit,

            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),

            label: const Text(

              "Submit For Approval",

              style: TextStyle(

                color: Colors.white,

                fontWeight: FontWeight.bold,

                fontSize: 16,

              ),

            ),

          ),

        ),

        const SizedBox(height: 14),

        SizedBox(

          width: double.infinity,

          child: OutlinedButton.icon(

            style: OutlinedButton.styleFrom(

              padding: const EdgeInsets.symmetric(
                vertical: 18,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),

            ),

            onPressed: controller.saveDraft,

            icon: const Icon(Icons.save),

            label: const Text(
              "Save Draft",
            ),

          ),

        )

      ],

    );

  }

}