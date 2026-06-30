import 'package:get/get_state_manager/src/simple/get_view.dart';

import 'package:medicle_sales_rbsh/features/Investment_Management/wigets/create_request/section_card.dart';

import '../../controller/add_investment_controller.dart';
import 'package:flutter/material.dart';

import 'investment_textfield.dart';
class GiftForm extends GetView<AddInvestmentController> {
  const GiftForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Item Gift",
      icon: Icons.card_giftcard,
      child: Column(
        children: [

          InvestmentTextField(
            controller: controller.itemController,
            label: "Item Name",
            icon: Icons.inventory_2_outlined,
          ),

          const SizedBox(height: 16),

          Row(
            children: [

              Expanded(
                child: InvestmentTextField(
                  controller: controller.quantityController,
                  label: "Quantity",
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: InvestmentTextField(
                  controller: controller.itemValueController,
                  label: "Value",
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),
              ),

            ],
          ),

          const SizedBox(height: 16),

          InvestmentTextField(
            controller: controller.purposeController,
            label: "Purpose",
            icon: Icons.description,
            maxLines: 3,
          ),

        ],
      ),
    );
  }
}