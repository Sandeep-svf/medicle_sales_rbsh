import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:flutter/material.dart';

import 'investment_toggle.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class InvestmentHeader extends StatelessWidget {
  final bool table;

  final ValueChanged<bool> onToggle;

  const InvestmentHeader({
    super.key,
    required this.table,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TTexts.uiTextMyInvestmentRequests,
                style: TextStyle(
                  fontSize: TSizes.v28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: TSizes.v6),
              Text(
                TTexts.uiTextTrackEveryRequestThroughApprovalPayout,
                style: TextStyle(
                  color: TColors.materialGrey,
                  fontSize: TSizes.v15,
                ),
              )
            ],
          ),
        ),
        InvestmentToggle(
          table: table,
          onChanged: onToggle,
        )
      ],
    );
  }
}
