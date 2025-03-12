import 'package:flutter/material.dart';
import '../../../../utils/constants/text_strings.dart';

class CustomerFeedback extends StatelessWidget {
  const CustomerFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
          children: [
            Text(
              TTexts.customerFeedback,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              "Positive response from Dr. Aarav Maurya",
            ),
          ],
        ),
      ),
    );
  }
  }
