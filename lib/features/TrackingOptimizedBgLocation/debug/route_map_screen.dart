import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RouteMapScreen(),
    );
  }
}

class RouteMapScreen extends StatelessWidget {
  RouteMapScreen({super.key});

  final List<LatLng> points = [
    LatLng(28.5900437,77.4350765),
    LatLng(28.5898557,77.4350086),
    LatLng(28.5899054,77.4348534),
    LatLng(28.5899191,77.4348528),
    LatLng(28.5898707,77.4349515),
    LatLng(28.5899005,77.4348608),
    LatLng(28.5899008,77.4348596),
    LatLng(28.5898994,77.4348612),
    LatLng(28.5899009,77.4348591),
    LatLng(28.5899016,77.4348579),
    LatLng(28.5899008,77.4348595),
    LatLng(28.5899007,77.4348610),
    LatLng(28.5899006,77.4348603),
    LatLng(28.5899008,77.4348601),
    LatLng(28.5899009,77.4348597),
    LatLng(28.5899012,77.4348605),
    LatLng(28.5899009,77.4348605),
    LatLng(28.5898734,77.4349321),
    LatLng(28.5899008,77.4348594),
    LatLng(28.5898733,77.4349285),
    LatLng(28.5899012,77.4348597),
    LatLng(28.5898994,77.4348703),
    LatLng(28.5899008,77.4348594),
    LatLng(28.5899003,77.4348602),
    LatLng(28.5899007,77.4348600),
    LatLng(28.5899009,77.4348613),
    LatLng(28.5899007,77.4348598),
    LatLng(28.5899009,77.4348588),
    LatLng(28.5899006,77.4348598),
    LatLng(28.5899002,77.4348613),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GPS Route"),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: points.first,
          initialZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.route",
          ),

          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 5,
                color: Colors.blue,
              ),
            ],
          ),

          MarkerLayer(
            markers: [
              Marker(
                point: points.first,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.green,
                  size: 38,
                ),
              ),
              Marker(
                point: points.last,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.flag,
                  color: Colors.red,
                  size: 38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}