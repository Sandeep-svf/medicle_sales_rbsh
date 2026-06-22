import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RouteMapScreen(),
    );
  }
}

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}


class _RouteMapScreenState extends State<RouteMapScreen> {
  final MapController _mapController = MapController();

  List<LatLng> routePoints = [];
  List<GpsPoint> gpsPoints = [];
  List<StopPoint> stopPoints = [];

  @override
  void initState() {
    super.initState();
    loadCsvAndDraw();
  }

  Future<void> loadCsvAndDraw() async {
    final rawData =
    await rootBundle.loadString('assets/upload_queue.csv');

    final lines = LineSplitter.split(rawData).toList();

    for (int i = 1; i < lines.length; i++) {
      final columns = lines[i].split(';');
      if (columns.length < 3) continue;

      final entityId = columns[2];
      final parts = entityId.split('_');

      if (parts.length < 4) continue;

      try {
        final timestampMillis =
        int.parse(parts[parts.length - 3]);

        final lat =
        double.parse(parts[parts.length - 2]);

        final lon =
        double.parse(parts[parts.length - 1]);

        final timestamp =
        DateTime.fromMillisecondsSinceEpoch(
            timestampMillis);

        gpsPoints.add(
          GpsPoint(
            lat: lat,
            lng: lon,
            timestamp: timestamp,
          ),
        );

        routePoints.add(LatLng(lat, lon));
      } catch (_) {}
    }

    _detectStops();

    setState(() {});

    if (routePoints.isNotEmpty) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(routePoints),
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  // ---------------------------------------------------
  // STOP DETECTION
  // ---------------------------------------------------

  void _detectStops() {
    const double radiusThreshold = 30; // meters
    const Duration minStopDuration =
    Duration(minutes: 2);

    stopPoints.clear();

    if (gpsPoints.length < 2) return;

    int startIndex = 0;

    for (int i = 1; i < gpsPoints.length; i++) {
      final distance = _calculateDistance(
        gpsPoints[startIndex],
        gpsPoints[i],
      );

      if (distance > radiusThreshold) {
        final duration = gpsPoints[i - 1]
            .timestamp
            .difference(
            gpsPoints[startIndex].timestamp);

        if (duration >= minStopDuration) {
          stopPoints.add(
            StopPoint(
              lat: gpsPoints[startIndex].lat,
              lng: gpsPoints[startIndex].lng,
              duration: duration,
            ),
          );
        }

        startIndex = i;
      }
    }
  }

  double _calculateDistance(
      GpsPoint p1, GpsPoint p2) {
    const R = 6371000;

    final dLat = _degToRad(p2.lat - p1.lat);
    final dLon = _degToRad(p2.lng - p1.lng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(p1.lat)) *
            cos(_degToRad(p2.lat)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double _degToRad(double deg) =>
      deg * (pi / 180);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Offline Route Viewer (OSM)")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: routePoints.isNotEmpty
              ? routePoints.first
              : const LatLng(28.6139, 77.2090),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
            'com.rbsh.medicle_sales_rbsh',
          ),

          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4,
                color: Colors.blue,
              ),
            ],
          ),

          MarkerLayer(
            markers: [
              if (routePoints.isNotEmpty)
                Marker(
                  point: routePoints.first,
                  width: 40,
                  height: 40,
                  child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40),
                ),

              if (routePoints.isNotEmpty)
                Marker(
                  point: routePoints.last,
                  width: 40,
                  height: 40,
                  child: const Icon(
                      Icons.flag,
                      color: Colors.red,
                      size: 40),
                ),

              ...stopPoints.map(
                    (stop) => Marker(
                  point:
                  LatLng(stop.lat, stop.lng),
                  width: 120,
                  height: 60,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.pause_circle_filled,
                        color: Colors.orange,
                        size: 30,
                      ),
                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                            horizontal: 6,
                            vertical: 2),
                        color: Colors.white,
                        child: Text(
                          "${stop.duration.inMinutes} min",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GpsPoint {
  final double lat;
  final double lng;
  final DateTime timestamp;

  GpsPoint({
    required this.lat,
    required this.lng,
    required this.timestamp,
  });
}

class StopPoint {
  final double lat;
  final double lng;
  final Duration duration;

  StopPoint({
    required this.lat,
    required this.lng,
    required this.duration,
  });
}