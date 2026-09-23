import 'package:flutter/material.dart';
import '../helper/AppColors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class TopNavigationMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const TopNavigationMenu(
      {Key? key, required this.currentIndex, required this.onTabSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: TSizes.v70,
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: TColors.white, shape: BoxShape.circle),
            child: const Icon(Icons.pie_chart, color: AppColors.primaryDark),
          ),
          const SizedBox(width: TSizes.v32),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _navItem("MTP July", Icons.calendar_month, 0),
                  _navItem("STP", Icons.table_chart_outlined, 1),
                  _navItem("Status", Icons.access_time, 2),
                  _navItem("ASM view", Icons.check_circle_outline, 3),
                  _navItem("Deviation", Icons.warning_amber_rounded, 4),
                ],
              ),
            ),
          ),
          CircleAvatar(
              backgroundColor: TColors.materialOrange300,
              child: const Text(TTexts.uiTextAV,
                  style: TextStyle(
                      color: TColors.black87, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  Widget _navItem(String title, IconData icon, int index) {
    bool isActive = currentIndex == index;
    return InkWell(
      onTap: () => onTabSelected(index),
      child: Padding(
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isActive ? TColors.white : TColors.white54,
                size: TSizes.v24),
            const SizedBox(height: TSizes.v4),
            Text(title,
                style: TextStyle(
                    color: isActive ? TColors.white : TColors.white54,
                    fontSize: TSizes.v12,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
