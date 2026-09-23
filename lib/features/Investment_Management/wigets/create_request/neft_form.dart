import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/Investment_Management/wigets/create_request/section_card.dart';

import '../../controller/add_investment_controller.dart';

import 'investment_textfield.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class NeftForm extends GetView<AddInvestmentController> {
  const NeftForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: TTexts.uiTextBankTransfer,
      icon: Icons.account_balance,
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
            controller: controller.accountHolderController,
            label: TTexts.uiTextAccountHolder,
            icon: Icons.person,
            validator: (value) =>
                controller.validateRequired(value, "Account holder"),
          ),
          const SizedBox(height: TSizes.v16),
          InvestmentTextField(
            controller: controller.accountNumberController,
            label: TTexts.uiTextAccountNumber,
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            validator: (value) =>
                controller.validateRequired(value, "Account number"),
          ),
          const SizedBox(height: TSizes.v16),
          InvestmentTextField(
            controller: controller.ifscController,
            label: TTexts.uiTextIFSCCode,
            icon: Icons.qr_code,
            validator: (value) =>
                controller.validateRequired(value, "IFSC code"),
          ),
          const SizedBox(height: TSizes.v16),
          InvestmentTextField(
            controller: controller.bankController,
            label: TTexts.uiTextBankName,
            icon: Icons.account_balance,
            validator: (value) =>
                controller.validateRequired(value, "Bank name"),
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
