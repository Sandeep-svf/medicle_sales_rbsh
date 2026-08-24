import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import 'package:medicle_sales_rbsh/features/Investment_Management/wigets/create_request/section_card.dart';

import '../../controller/add_investment_controller.dart';
import 'investment_textfield.dart';

class UpiForm extends GetView<AddInvestmentController> {
  const UpiForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "UPI Payment",
      icon: Icons.qr_code_scanner,
      child: Column(
        children: [
          InvestmentTextField(
            controller: controller.amountController,
            label: "Amount",
            icon: Icons.currency_rupee,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: controller.validateAmount,
          ),
          const SizedBox(height: 16),
          InvestmentTextField(
            controller: controller.upiController,
            label: "UPI ID",
            icon: Icons.qr_code,
            validator: (value) => controller.validateRequired(value, "UPI ID"),
          ),
          const SizedBox(height: 16),
          InvestmentTextField(
            controller: controller.purposeController,
            label: "Purpose",
            icon: Icons.description,
            maxLines: 3,
            validator: (value) => controller.validateRequired(value, "Purpose"),
          ),
        ],
      ),
    );
  }
}
