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
            size: 16,
            color: config.color,
          ),

          const SizedBox(width: 6),

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
          color: Colors.orange.shade700,
          background: Colors.orange.shade50,
          icon: Icons.edit_document,
        );

      case "Submitted":
        return _StatusConfig(
          color: Colors.blue.shade700,
          background: Colors.blue.shade50,
          icon: Icons.upload_file,
        );

      case "Approved":
        return _StatusConfig(
          color: Colors.green.shade700,
          background: Colors.green.shade50,
          icon: Icons.verified,
        );

      case "Returned":
        return _StatusConfig(
          color: Colors.red.shade700,
          background: Colors.red.shade50,
          icon: Icons.assignment_return,
        );

      default:
        return _StatusConfig(
          color: TColors.textSecondary,
          background: Colors.grey.shade100,
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