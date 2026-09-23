import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class InvestmentModeCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const InvestmentModeCard({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? TColors.primary.withOpacity(.08) : TColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? TColors.primary : TColors.materialGrey300,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.pureBlack.withOpacity(.05),
              blurRadius: selected ? 14 : 8,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: TSizes.v40,
              width: TSizes.v40,
              decoration: BoxDecoration(
                color: selected ? TColors.primary : TColors.materialGrey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? TColors.white : TColors.primary,
                size: TSizes.v20,
              ),
            ),
            const SizedBox(height: TSizes.v14),
            Text(
              title,
              style: TextStyle(
                fontSize: TSizes.v14,
                fontWeight: FontWeight.bold,
                color: selected ? TColors.primary : TColors.black87,
              ),
            ),
            const SizedBox(height: TSizes.v4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColors.materialGrey600,
                fontSize: TSizes.v12,
              ),
            ),
            const SizedBox(height: TSizes.v14),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: TSizes.v4,
              width: selected ? 70 : 30,
              decoration: BoxDecoration(
                color: selected ? TColors.primary : TColors.materialGrey300,
                borderRadius: BorderRadius.circular(20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
