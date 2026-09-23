import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'performance_progress.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int scheduled;
  final int confirmed;
  final Color color;
  final int index;

  const KpiCard({
    super.key,
    required this.title,
    required this.icon,
    required this.scheduled,
    required this.confirmed,
    required this.color,
    this.index = 0,
  });

  double get progress {
    if (scheduled == 0) return 0;
    return confirmed / scheduled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(.15),
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.pureBlack.withOpacity(.04),
            blurRadius: TSizes.v8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top
          Row(
            children: [
              Container(
                height: TSizes.v32,
                width: TSizes.v32,
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: TSizes.v18,
                  color: color,
                ),
              ),
              const SizedBox(width: TSizes.v8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: TSizes.v15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "${(progress * 100).round()}%",
                style: TextStyle(
                  color: color,
                  fontSize: TSizes.v14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Spacer(),

          /// Number
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$confirmed",
                  style: const TextStyle(
                    color: TColors.textPrimary,
                    fontSize: TSizes.v28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: " / $scheduled",
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: TSizes.v17,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: TSizes.v8),

          PerformanceProgress(
            value: progress,
            color: color,
            height: TSizes.v5,
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fade(duration: 350.ms)
        .slideY(begin: .15);
  }
}
