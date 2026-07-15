import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';



class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.title,
    required this.value,
    this.flex = 1,
  });

  final String title;
  final String value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Expanded(
          flex: flex,
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: TColors.textSecondary,
            ),
          ),
        ),

        Expanded(
          flex: flex,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: TColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}