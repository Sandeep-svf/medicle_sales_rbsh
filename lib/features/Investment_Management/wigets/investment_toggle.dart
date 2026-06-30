import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';

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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          _button(
            title: "Table",
            icon: Icons.table_rows,
            selected: table,
            onTap: ()=>onChanged(true),
          ),

          _button(
            title: "Cards",
            icon: Icons.grid_view,
            selected: !table,
            onTap: ()=>onChanged(false),
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
  }){

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

          color: selected
              ? TColors.primary
              : Colors.transparent,

          borderRadius: BorderRadius.circular(12),

        ),

        child: Row(

          children: [

            Icon(
              icon,
              size: 18,
              color: selected
                  ? Colors.white
                  : Colors.black87,
            ),

            const SizedBox(width:8),

            Text(
              title,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            )

          ],
        ),
      ),
    );

  }

}