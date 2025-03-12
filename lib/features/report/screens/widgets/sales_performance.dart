import 'package:flutter/material.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';


class SalesPerformances extends StatelessWidget {
  const SalesPerformances({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
          children: [
            Text(
              TTexts.salesPerformance,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between columns
              children: [
                /// Left Column: Labels
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TTexts.totoalSales),
                    const SizedBox(height: TSizes.spaceBtwText),
                    Text(TTexts.saleCalls),
                    const SizedBox(height: TSizes.spaceBtwText),
                    Text(TTexts.order),
                  ],
                ),

                /// Right Column: Values
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // Align numbers to the right
                  children: [
                    Text("935400"),
                    SizedBox(height: TSizes.spaceBtwText),
                    Text("7645"),
                    SizedBox(height: TSizes.spaceBtwText),
                    Text("23"),
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