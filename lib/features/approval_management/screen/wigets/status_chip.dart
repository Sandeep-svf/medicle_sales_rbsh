import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';



class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {

    Color bg = TColors.primary_shade50;
    Color fg = TColors.primary;

    switch (status.toLowerCase()) {

      case "approved":
      case "accepted":
        bg = TColors.successBg;
        fg = TColors.success;
        break;

      case "returned":
      case "pending":
        bg = TColors.warningBg;
        fg = TColors.warning;
        break;

      case "rejected":
        bg = TColors.errorBg;
        fg = TColors.error;
        break;

      case "submitted":
        bg = TColors.primary_shade50;
        fg = TColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.md,
        vertical: TSizes.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          TSizes.cardRadiusLg,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: TSizes.fontSizeSm,
        ),
      ),
    );
  }
}