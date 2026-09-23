import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class TerritoryTopBar extends StatelessWidget {
  const TerritoryTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: TSizes.v6,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: TSizes.v62,
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Icon(
                Icons.map_rounded,
                color: TColors.primary,
              ),
              SizedBox(width: TSizes.v12),
              Expanded(
                child: Text(
                  TTexts.uiTextTerritoryManagement,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: TSizes.v18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
