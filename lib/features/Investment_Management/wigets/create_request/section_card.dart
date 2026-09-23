import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TSizes.v1_5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, size: TSizes.v20),
                if (icon != null) const SizedBox(width: TSizes.v8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: TSizes.v18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.v18),
            child
          ],
        ),
      ),
    );
  }
}
