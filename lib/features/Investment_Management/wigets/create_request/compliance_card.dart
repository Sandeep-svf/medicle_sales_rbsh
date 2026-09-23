import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'section_card.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class ComplianceCard extends StatelessWidget {
  const ComplianceCard({super.key});

  @override
  Widget build(BuildContext context) {
    const used = 19000.0;
    const limit = 50000.0;

    final progress = used / limit;

    return SectionCard(
      title: TTexts.uiTextCompliance,
      icon: Icons.verified_user_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _tile(
                  "Used",
                  "₹19,000",
                  TColors.materialOrange,
                ),
              ),
              const SizedBox(width: TSizes.v12),
              Expanded(
                child: _tile(
                  "Remaining",
                  "₹31,000",
                  TColors.materialGreen,
                ),
              )
            ],
          ),
          const SizedBox(height: TSizes.v18),
          const Text(
            TTexts.uiTextQuarterlyBudget,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: TSizes.v10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: TSizes.v10,
              backgroundColor: TColors.materialGrey200,
              color: TColors.primary,
            ),
          ),
          const SizedBox(height: TSizes.v10),
          Row(
            children: [
              const Text(TTexts.uiText0),
              const Spacer(),
              Text(
                "₹${limit.toStringAsFixed(0)}",
              )
            ],
          ),
          const SizedBox(height: TSizes.v18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.materialGreen.withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: TColors.materialGreen,
                ),
                SizedBox(width: TSizes.v10),
                Expanded(
                  child: Text(
                    TTexts.uiTextWithinComplianceLimit,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _tile(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: TColors.materialGrey600,
            ),
          ),
          const SizedBox(height: TSizes.v6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: TSizes.v18,
            ),
          ),
        ],
      ),
    );
  }
}
