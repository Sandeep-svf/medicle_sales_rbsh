import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicle_sales_rbsh/features/Investment_Management/wigets/create_request/section_card.dart';

import '../../controller/add_investment_controller.dart';
import 'investment_textfield.dart';

class CashForm extends GetView<AddInvestmentController> {
  const CashForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Cash Investment",
      icon: Icons.payments_outlined,
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
            controller: controller.purposeController,
            label: "Purpose",
            icon: Icons.description_outlined,
            maxLines: 3,
            validator: (value) => controller.validateRequired(value, "Purpose"),
          ),
        ],
      ),
    );
  }
}
