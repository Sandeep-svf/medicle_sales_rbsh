import 'package:flutter/material.dart';

import 'LocationSample.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.repo});
  final LocationRepository repo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BG Geolocation Demo')),
      body: StreamBuilder<LocationSample>(
        stream: repo.stream,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: Text('Waiting for location...'));
          }
          final s = snap.data!;
          return Center(
            child: Text(
              'Lat: ${s.latitude}\nLng: ${s.longitude}\nMoving: ${s.isMoving}\nAt: ${s.timestamp}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
