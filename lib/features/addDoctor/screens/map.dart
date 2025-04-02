import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double dummyLat = 28.6139;
    final double dummyLong = 77.2090;

    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: Column(
        children: [
          Expanded(
            child: Image.network(
              'https://sm.mashable.com/t/mashable_in/photo/default/maps_dmpu.2496.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('Failed to load map.'));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'lat': dummyLat,
                    'long': dummyLong,
                  });
                },
                child: const Text("Select This Location"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
