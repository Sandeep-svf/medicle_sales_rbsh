import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';



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
          color: selected
              ? TColors.primary.withOpacity(.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? TColors.primary
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
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
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: selected
                    ? TColors.primary
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected
                    ? Colors.white
                    : TColors.primary,
                size: 20,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: selected
                    ? TColors.primary
                    : Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 14),

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              width: selected ? 70 : 30,
              decoration: BoxDecoration(
                color: selected
                    ? TColors.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            )

          ],
        ),
      ),
    );
  }
}