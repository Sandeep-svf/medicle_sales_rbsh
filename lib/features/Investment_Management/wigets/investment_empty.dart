import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class InvestmentEmpty extends StatelessWidget {
  final VoidCallback? onAdd;

  const InvestmentEmpty({
    super.key,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: TSizes.v90,
            color: TColors.materialGrey400,
          ),
          const SizedBox(height: TSizes.v20),
          const Text(
            TTexts.uiTextNoInvestmentRequests,
            style: TextStyle(
              fontSize: TSizes.v22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: TSizes.v8),
          Text(
            TTexts.uiTextCreateYourFirstInvestmentRequest,
            style: TextStyle(
              color: TColors.materialGrey600,
            ),
          ),
          const SizedBox(height: TSizes.v24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
            ),
            onPressed: onAdd,
            icon: const Icon(
              Icons.add,
              color: TColors.white,
            ),
            label: const Text(
              TTexts.uiTextNewRequest,
              style: TextStyle(
                color: TColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
