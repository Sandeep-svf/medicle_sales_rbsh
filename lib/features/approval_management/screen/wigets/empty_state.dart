import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';



class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              padding: const EdgeInsets.all(
                TSizes.lg,
              ),
              decoration: const BoxDecoration(
                color: TColors.primary_shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: TColors.primary,
              ),
            ),

            const SizedBox(
              height: TSizes.lg,
            ),

            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: TSizes.sm,
            ),

            SizedBox(
              width: 350,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color:
                  TColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}