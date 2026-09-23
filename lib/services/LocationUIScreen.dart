import 'package:flutter/material.dart';

import 'LocationSample.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.repo});
  final LocationRepository repo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(TTexts.uiTextBGGeolocationDemo)),
      body: StreamBuilder<LocationSample>(
        stream: repo.stream,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: Text(TTexts.uiTextWaitingForLocation));
          }
          final s = snap.data!;
          return Center(
            child: Text(
              'Lat: ${s.latitude}\nLng: ${s.longitude}\nMoving: ${s.isMoving}\nAt: ${s.timestamp}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: TSizes.v16),
            ),
          );
        },
      ),
    );
  }
}
