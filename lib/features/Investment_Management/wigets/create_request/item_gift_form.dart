import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicle_sales_rbsh/features/Investment_Management/wigets/create_request/section_card.dart';

import '../../controller/add_investment_controller.dart';
import 'investment_textfield.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class GiftForm extends GetView<AddInvestmentController> {
  const GiftForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: TTexts.uiTextItemGift,
      icon: Icons.card_giftcard,
      child: Column(
        children: [
          InvestmentTextField(
            controller: controller.itemNameController,
            label: TTexts.uiTextItemName,
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: TSizes.v16),
          Row(
            children: [
              Expanded(
                child: InvestmentTextField(
                  controller: controller.quantityController,
                  label: TTexts.quantity,
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: TSizes.v16),
              Expanded(
                child: InvestmentTextField(
                  controller: controller.valueController,
                  label: TTexts.uiTextItemValue,
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.v16),
          InvestmentTextField(
            controller: controller.justificationController,
            label: TTexts.uiTextJustification,
            icon: Icons.description,
            maxLines: 3,
            validator: (value) =>
                controller.validateRequired(value, "Justification"),
          ),
          const SizedBox(height: TSizes.v20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.addGiftItem,
              icon: const Icon(Icons.add),
              label: const Text(TTexts.uiTextAddItem),
            ),
          ),
          const SizedBox(height: TSizes.v20),
          Obx(() {
            if (controller.giftItems.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.giftItems.length,
              separatorBuilder: (_, __) => const Divider(height: TSizes.v16),
              itemBuilder: (_, index) {
                final item = controller.giftItems[index];

                return ListTile(
                  leading: const Icon(Icons.card_giftcard),
                  title: Text(item.itemName),
                  subtitle: Text(
                    "Qty: ${item.quantity}   |   ₹${item.value}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: TColors.materialRed,
                    ),
                    onPressed: () => controller.removeGiftItem(index),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
