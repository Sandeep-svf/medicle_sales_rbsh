import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import 'package:medicle_sales_rbsh/features/Investment_Management/wigets/create_request/section_card.dart';

import '../../controller/add_investment_controller.dart';
import 'investment_textfield.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class UpiForm extends GetView<AddInvestmentController> {
  const UpiForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: TTexts.uiTextUPIPayment,
      icon: Icons.qr_code_scanner,
      child: Column(
        children: [
          InvestmentTextField(
            controller: controller.amountController,
            label: TTexts.amount,
            icon: Icons.currency_rupee,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: controller.validateAmount,
          ),
          const SizedBox(height: TSizes.v16),
          InvestmentTextField(
            controller: controller.upiController,
            label: TTexts.uiTextUPIID,
            icon: Icons.qr_code,
            validator: (value) => controller.validateRequired(value, "UPI ID"),
          ),
          const SizedBox(height: TSizes.v16),
          InvestmentTextField(
            controller: controller.purposeController,
            label: TTexts.uiTextPurpose,
            icon: Icons.description,
            maxLines: 3,
            validator: (value) => controller.validateRequired(value, "Purpose"),
          ),
        ],
      ),
    );
  }
}
