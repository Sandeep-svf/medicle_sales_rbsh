import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class MetricCell extends StatelessWidget {
  final int scheduled;
  final int confirmed;
  final Color color;

  const MetricCell({
    super.key,
    required this.scheduled,
    required this.confirmed,
    required this.color,
  });

  double get coverage {
    if (scheduled == 0) return 0;
    return confirmed / scheduled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(
            "Scheduled",
            scheduled.toString(),
            TColors.textPrimary,
          ),
          _divider(),
          _item(
            "Confirmed",
            confirmed.toString(),
            color,
          ),
          _divider(),
          _item(
            "Coverage",
            "${(coverage * 100).toStringAsFixed(0)}%",
            coverageColor,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: TSizes.v1,
      height: TSizes.v42,
      color: TColors.borderSecondary,
    );
  }

  Widget _item(
    String title,
    String value,
    Color valueColor,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: TSizes.v11,
              color: TColors.textSecondary,
            ),
          ),
          const SizedBox(height: TSizes.v6),
          Text(
            value,
            style: TextStyle(
              fontSize: TSizes.v18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color get coverageColor {
    if (coverage >= .90) {
      return TColors.success;
    }

    if (coverage >= .75) {
      return TColors.materialBlue;
    }

    if (coverage >= .50) {
      return TColors.warning;
    }

    return TColors.error;
  }
}
