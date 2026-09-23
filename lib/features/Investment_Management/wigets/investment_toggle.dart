import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class InvestmentToggle extends StatelessWidget {
  final bool table;

  final ValueChanged<bool> onChanged;

  const InvestmentToggle({
    super.key,
    required this.table,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TColors.materialGrey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(
            title: TTexts.uiTextTable,
            icon: Icons.table_rows,
            selected: table,
            onTap: () => onChanged(true),
          ),
          _button(
            title: TTexts.uiTextCards,
            icon: Icons.grid_view,
            selected: !table,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _button({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? TColors.primary : TColors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: TSizes.v18,
              color: selected ? TColors.white : TColors.black87,
            ),
            const SizedBox(width: TSizes.v8),
            Text(
              title,
              style: TextStyle(
                color: selected ? TColors.white : TColors.black87,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
