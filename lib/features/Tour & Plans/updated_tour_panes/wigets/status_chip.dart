import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(
          TSizes.borderRadiusLg * 2,
        ),
        border: Border.all(
          color: config.color.withOpacity(.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: TSizes.v16,
            color: config.color,
          ),
          const SizedBox(width: TSizes.v6),
          Text(
            status,
            style: TextStyle(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: TSizes.fontSizeSm,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case "Draft":
        return _StatusConfig(
          color: TColors.materialOrange700,
          background: TColors.materialOrange50,
          icon: Icons.edit_document,
        );

      case "Submitted":
        return _StatusConfig(
          color: TColors.materialBlue700,
          background: TColors.materialBlue50,
          icon: Icons.upload_file,
        );

      case "Approved":
        return _StatusConfig(
          color: TColors.materialGreen700,
          background: TColors.materialGreen50,
          icon: Icons.verified,
        );

      case "Returned":
        return _StatusConfig(
          color: TColors.materialRed700,
          background: TColors.materialRed50,
          icon: Icons.assignment_return,
        );

      default:
        return _StatusConfig(
          color: TColors.textSecondary,
          background: TColors.materialGrey100,
          icon: Icons.help_outline,
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final Color background;
  final IconData icon;

  const _StatusConfig({
    required this.color,
    required this.background,
    required this.icon,
  });
}
