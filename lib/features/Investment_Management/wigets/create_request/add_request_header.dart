import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class AddRequestHeader extends StatelessWidget {
  const AddRequestHeader({
    super.key,
    required this.isEditing,
  });

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColors.primary,
            TColors.primary.withOpacity(.80),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: TColors.white,
              size: TSizes.v30,
            ),
          ),
          const SizedBox(width: TSizes.v18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? "Edit Investment Request"
                      : "Create Investment Request",
                  style: const TextStyle(
                    color: TColors.white,
                    fontSize: TSizes.v22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: TSizes.v6),
                Text(
                  isEditing
                      ? "Update the request details and submit it again."
                      : "Fill the required details and submit the investment request.",
                  style: const TextStyle(
                    color: TColors.white70,
                    height: TSizes.v1_4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
