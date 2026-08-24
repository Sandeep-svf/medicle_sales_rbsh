import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/Investment_Management/wigets/create_request/section_card.dart';

import '../../controller/add_investment_controller.dart';

import 'investment_textfield.dart';

class NeftForm extends GetView<AddInvestmentController> {
  const NeftForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Bank Transfer",
      icon: Icons.account_balance,
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
            controller: controller.accountHolderController,
            label: "Account Holder",
            icon: Icons.person,
            validator: (value) =>
                controller.validateRequired(value, "Account holder"),
          ),
          const SizedBox(height: 16),
          InvestmentTextField(
            controller: controller.accountNumberController,
            label: "Account Number",
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            validator: (value) =>
                controller.validateRequired(value, "Account number"),
          ),
          const SizedBox(height: 16),
          InvestmentTextField(
            controller: controller.ifscController,
            label: "IFSC Code",
            icon: Icons.qr_code,
            validator: (value) =>
                controller.validateRequired(value, "IFSC code"),
          ),
          const SizedBox(height: 16),
          InvestmentTextField(
            controller: controller.bankController,
            label: "Bank Name",
            icon: Icons.account_balance,
            validator: (value) =>
                controller.validateRequired(value, "Bank name"),
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
