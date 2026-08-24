import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:medicle_sales_rbsh/features/Investment_Management/wigets/create_request/section_card.dart';

import '../../controller/add_investment_controller.dart';
import 'investment_textfield.dart';

class GiftForm extends GetView<AddInvestmentController> {
  const GiftForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Item / Gift",
      icon: Icons.card_giftcard,
      child: Column(
        children: [
          InvestmentTextField(
            controller: controller.itemNameController,
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
                  controller: controller.valueController,
                  label: "Item Value",
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InvestmentTextField(
            controller: controller.justificationController,
            label: "Justification",
            icon: Icons.description,
            maxLines: 3,
            validator: (value) =>
                controller.validateRequired(value, "Justification"),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.addGiftItem,
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.giftItems.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.giftItems.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
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
                      color: Colors.red,
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
