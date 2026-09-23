import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../controller/investment_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class InvestmentSearchBar extends GetView<InvestmentController> {
  const InvestmentSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: TTexts.uiTextSearchDoctor_7c8fc5ad,
        prefixIcon: const Icon(
          Icons.search,
          color: TColors.primary,
        ),
        suffixIcon: Obx(() {
          if (controller.search.value.isEmpty) {
            return const SizedBox.shrink();
          }

          return IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.clearSearch();
            },
          );
        }),
        filled: true,
        fillColor: TColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        controller.search.value = value;
      },
    );
  }
}
