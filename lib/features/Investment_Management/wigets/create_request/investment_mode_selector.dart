import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/add_investment_controller.dart';
import '../../enum.dart';

import 'investment_mode_card.dart';
import 'section_card.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class InvestmentModeSelector extends GetView<AddInvestmentController> {
  const InvestmentModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: TTexts.uiTextInvestmentMode,
      icon: Icons.account_balance_wallet_outlined,
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: InvestmentModeCard(
                selected: controller.selectedMode.value == InvestmentMode.cash,
                title: TTexts.uiTextCash,
                subtitle: "",
                icon: Icons.payments_outlined,
                onTap: () => controller.changeMode(InvestmentMode.cash),
              ),
            ),
            const SizedBox(width: TSizes.v10),
            Expanded(
              child: InvestmentModeCard(
                selected: controller.selectedMode.value == InvestmentMode.neft,
                title: TTexts.uiTextNEFT,
                subtitle: "",
                icon: Icons.account_balance,
                onTap: () => controller.changeMode(InvestmentMode.neft),
              ),
            ),
            const SizedBox(width: TSizes.v10),
            Expanded(
              child: InvestmentModeCard(
                selected: controller.selectedMode.value == InvestmentMode.upi,
                title: TTexts.uiTextUPI,
                subtitle: "",
                icon: Icons.qr_code_scanner,
                onTap: () => controller.changeMode(InvestmentMode.upi),
              ),
            ),
            const SizedBox(width: TSizes.v10),
            Expanded(
              child: InvestmentModeCard(
                selected: controller.selectedMode.value == InvestmentMode.gift,
                title: TTexts.uiTextGift,
                subtitle: "",
                icon: Icons.card_giftcard,
                onTap: () => controller.changeMode(InvestmentMode.gift),
              ),
            ),
          ],
        );
      }),
    );
  }
}
