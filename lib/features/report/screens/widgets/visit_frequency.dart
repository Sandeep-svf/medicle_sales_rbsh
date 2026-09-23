import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class VisitFrequency extends StatelessWidget {
  const VisitFrequency({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: TSizes.v2,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns text to the left
          children: [
            Text(
              TTexts.visitFrequency,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: TSizes.v12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Space between columns
              children: [
                /// Left Column: Labels
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TTexts.totalCompletedVisit),
                    const SizedBox(height: TSizes.spaceBtwText),
                    Text(TTexts.frequency),
                  ],
                ),

                /// Right Column: Values
                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // Align numbers to the right
                  children: [
                    Text(TTexts.uiText514),
                    SizedBox(height: TSizes.spaceBtwText),
                    Text(TTexts.uiText4Week),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
