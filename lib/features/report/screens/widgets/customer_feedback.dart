import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class CustomerFeedback extends StatelessWidget {
  const CustomerFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TSizes.v2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns text to the left
          children: [
            Text(
              TTexts.customerFeedback,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: TSizes.v12),
            const Text(
              TTexts.uiTextPositiveResponseFromDrAaravMaurya,
            ),
          ],
        ),
      ),
    );
  }
}
