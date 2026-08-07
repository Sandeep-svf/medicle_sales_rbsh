import 'package:flutter/material.dart';

class PerformanceProgress extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  final Duration duration;
  final bool showPercentage;

  const PerformanceProgress({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
    this.duration = const Duration(milliseconds: 900),
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (_, animatedValue, __) {
            return Stack(
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: animatedValue,
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(.75),
                          color,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        if (showPercentage) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: duration,
              builder: (_, v, __) {
                return Text(
                  "${(v * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ]
      ],
    );
  }
}