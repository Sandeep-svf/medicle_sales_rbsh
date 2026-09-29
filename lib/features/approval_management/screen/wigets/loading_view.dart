import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/loder/fieldomni_loader.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message = "Loading...",
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: TSizes.loadingIndicatorSize,
              width: TSizes.loadingIndicatorSize,
              child: FieldOmniLoader.compact(),
            ),
            const SizedBox(
              height: TSizes.lg,
            ),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
