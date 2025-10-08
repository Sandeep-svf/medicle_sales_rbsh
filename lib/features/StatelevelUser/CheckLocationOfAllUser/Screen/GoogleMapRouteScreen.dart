import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/features/StatelevelUser/CheckLocationOfAllUser/Controller/LocationController.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';

import '../../../../services/LocationController.dart';
import '../Model/UserLocationListModel.dart';





import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/features/StatelevelUser/CheckLocationOfAllUser/Controller/LocationController.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';

import '../../../../services/LocationController.dart';
import '../Model/UserLocationListModel.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  String userData = Get.arguments ?? 'No data';
  DateTime selectedDate = DateTime.now(); // Default to today's date
  List<LatLng> _route = []; // Empty list initially, will be updated with fetched data
  bool _isLoading = true; // For loading state

  // Initialize the controller
  final LocationControllerList locationController = LocationControllerList(baseUrl: THttpHelper.baseUrl);

  bool _trafficEnabled = false;
  MapType _mapType = MapType.normal;

  Set<Polyline> get _polylines => {
    Polyline(
      polylineId: const PolylineId('route'),
      points: _route,
      color: Colors.blueAccent,
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      geodesic: true,
      patterns: <PatternItem>[
        PatternItem.dash(25),
        PatternItem.gap(10),
      ],
    ),
  };

  Set<Marker> get _markers {
    final markers = <Marker>{};

    // Start
    markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: _route.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start'),
      ),
    );

    // End
    markers.add(
      Marker(
        markerId: const MarkerId('end'),
        position: _route.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
      ),
    );

    return markers;
  }

  Future<void> _fitToRoute() async {
    final controller = await _controller.future;
    final bounds = _computeBounds(_route);
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70),
    );
  }

  LatLngBounds _computeBounds(List<LatLng> pts) {
    assert(pts.isNotEmpty);
    double? minLat, maxLat, minLng, maxLng;
    for (final p in pts) {
      if (minLat == null) {
        minLat = maxLat = p.latitude;
        minLng = maxLng = p.longitude;
      } else {
        if (p.latitude < minLat!) minLat = p.latitude;
        if (p.latitude > maxLat!) maxLat = p.latitude;
        if (p.longitude < minLng!) minLng = p.longitude;
        if (p.longitude > maxLng!) maxLng = p.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  Future<void> _flyThrough() async {
    final controller = await _controller.future;
    for (final p in _route) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: p, zoom: 12.5, tilt: 40, bearing: 20),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
  }

  // Fetch route data from controller
  Future<void> fetchRouteData() async {
    try {
      // Format the date to 'MM/dd/yyyy'
      String formattedDate = '${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}';

      // Fetch the filtered location data
      List<UserLocationListModel> filteredLocations = await locationController.fetchUserLocationData('68aa1486771e77bad145c17a', formattedDate);

      // Create route list from filtered locations
      setState(() {
        _route = filteredLocations.map((location) => LatLng(location.latitude!, location.longitude!)).toList();
        _isLoading = false; // Set loading state to false after data is fetched
      });
    } catch (error) {
      setState(() {
        _isLoading = false; // Set loading state to false even in case of error
      });
      print('Error fetching route data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch route data on screen load
    fetchRouteData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Map'),
        actions: [
          // Date picker button
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                });
                // Fetch the route data for the selected date
                fetchRouteData();
              }
            },
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Display loading indicator while route is being fetched
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _route.isNotEmpty ? _route.first : LatLng(28.594701, 77.450877),
                zoom: 10.5,
              ),
              polylines: _polylines,
              markers: _markers,
              mapType: _mapType,
              trafficEnabled: _trafficEnabled,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              onMapCreated: (c) async {
                _controller.complete(c);
                await Future<void>.delayed(const Duration(milliseconds: 300));
                _fitToRoute();
              },
            ),

          // Top info card
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Card(
                elevation: 6,
                color: theme.colorScheme.surface.withOpacity(0.92),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Route preview',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Stops: ${_route.length} • Distance (rough): ${( _roughDistanceKm(_route) ).toStringAsFixed(1)} km',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating controls
          Positioned(
            right: 12,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _roundButton(
                  icon: Icons.route,
                  label: 'Fit route',
                  onTap: _fitToRoute,
                ),
                const SizedBox(height: 10),
                _roundButton(
                  icon: Icons.movie_filter_outlined,
                  label: 'Fly',
                  onTap: _flyThrough,
                ),
                const SizedBox(height: 10),
                _roundButton(
                  icon: _trafficEnabled
                      ? Icons.traffic
                      : Icons.traffic_outlined,
                  label: 'Traffic',
                  onTap: () =>
                      setState(() => _trafficEnabled = !_trafficEnabled),
                ),
                const SizedBox(height: 10),
                _roundButton(
                  icon: Icons.layers,
                  label: 'Map',
                  onTap: () => setState(() {
                    _mapType = _mapType == MapType.normal
                        ? MapType.terrain
                        : _mapType == MapType.terrain
                        ? MapType.hybrid
                        : MapType.normal;
                  }),
                ),
              ],
            ),
          ),

          // Bottom sheet showing coordinates
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomSheet(
              startCoords: _route.isNotEmpty ? _route[0] : LatLng(0, 0),
              endCoords: _route.isNotEmpty ? _route[_route.length - 1] : LatLng(0, 0),
            ),
          ),
        ],
      ),
    );
  }

  double _roughDistanceKm(List<LatLng> pts) {
    if (pts.length < 2) return 0;
    const R = 6371.0;
    double d = 0;
    for (int i = 1; i < pts.length; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final dLat = _deg2rad(b.latitude - a.latitude);
      final dLon = _deg2rad(b.longitude - a.longitude);
      final lat1 = _deg2rad(a.latitude);
      final lat2 = _deg2rad(b.latitude);
      final h = (sin(dLat / 2) * sin(dLat / 2)) +
          (cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2));
      d += 2 * R * asin(sqrt(h));
    }
    return d;
  }

  double _deg2rad(double deg) => deg * 3.141592653589793 / 180.0;
}

// Nice rounded action button
Widget _roundButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.black.withOpacity(0.65),
    borderRadius: BorderRadius.circular(28),
    child: InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

class _BottomSheet extends StatelessWidget {
  final LatLng startCoords;
  final LatLng endCoords;
  const _BottomSheet({
    required this.startCoords,
    required this.endCoords,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: const [
          BoxShadow(blurRadius: 14, color: Colors.black26, offset: Offset(0, -4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start: ${startCoords.latitude.toStringAsFixed(5)}, ${startCoords.longitude.toStringAsFixed(5)}\n\n'
                  'End: ${endCoords.latitude.toStringAsFixed(5)}, ${endCoords.longitude.toStringAsFixed(5)}',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}



/*class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  String userData = Get.arguments ?? 'No data';



  // Static demo route: Saviour Greenarch -> Noida Sector 63 (Electronic City)
  final List<LatLng> _route = [
    // Starting point: Saviour Greenarch, Greater Noida
    const LatLng(28.594701, 77.450877), // Saviour Greenarch, Greater Noida
    const LatLng(28.595100, 77.448500),
    const LatLng(28.596000, 77.447000),
    const LatLng(28.598000, 77.444800),
    const LatLng(28.600500, 77.441600),
    const LatLng(28.602000, 77.438000),
    const LatLng(28.604000, 77.435000),
    const LatLng(28.606000, 77.432500),
    const LatLng(28.608500, 77.429000),
    const LatLng(28.610000, 77.425500),
    const LatLng(28.611000, 77.423000),
    const LatLng(28.612500, 77.420000),

    // Mid-point (Near Noida Sector 62)
    const LatLng(28.617000, 77.413000),
    const LatLng(28.620000, 77.409500),
    const LatLng(28.622500, 77.406000),
    const LatLng(28.625000, 77.403000),

    // Ending point: Noida Sector 62 (Electronic City Metro Station)
    const LatLng(28.628260, 77.375000), // Noida Sector 62
  ];


  bool _trafficEnabled = false;
  MapType _mapType = MapType.normal;

  Set<Polyline> get _polylines => {
    Polyline(
      polylineId: const PolylineId('route'),
      points: _route,
      color: Colors.blueAccent,
      width: 6,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      geodesic: true,
      patterns: <PatternItem>[
        PatternItem.dash(25),
        PatternItem.gap(10),
      ],
    ),
  };

  Set<Marker> get _markers {
    final markers = <Marker>{};

    // Start
    markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: _route.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start'),
      ),
    );

    // End
    markers.add(
      Marker(
        markerId: const MarkerId('end'),
        position: _route.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
      ),
    );

    return markers;
  }

  Future<void> _fitToRoute() async {
    final controller = await _controller.future;
    final bounds = _computeBounds(_route);
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70),
    );
  }

  // Simple bounds calculator
  LatLngBounds _computeBounds(List<LatLng> pts) {
    assert(pts.isNotEmpty);
    double? minLat, maxLat, minLng, maxLng;
    for (final p in pts) {
      if (minLat == null) {
        minLat = maxLat = p.latitude;
        minLng = maxLng = p.longitude;
      } else {
        if (p.latitude < minLat!) minLat = p.latitude;
        if (p.latitude > maxLat!) maxLat = p.latitude;
        if (p.longitude < minLng!) minLng = p.longitude;
        if (p.longitude > maxLng!) maxLng = p.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  // Simple camera animation along the route
  Future<void> _flyThrough() async {
    final controller = await _controller.future;
    for (final p in _route) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: p, zoom: 12.5, tilt: 40, bearing: 20),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  Widget build(BuildContext context) {
    print("RouteMapScreen: ${userData}");
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Map'),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _route.first,
              zoom: 10.5,
            ),
            polylines: _polylines,
            markers: _markers,
            mapType: _mapType,
            trafficEnabled: _trafficEnabled,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            onMapCreated: (c) async {
              _controller.complete(c);
              await Future<void>.delayed(const Duration(milliseconds: 300));
              _fitToRoute();
            },
          ),

          // Top info card
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Card(
                elevation: 6,
                color: theme.colorScheme.surface.withOpacity(0.92),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Route preview',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Stops: 2 • Distance (rough): ${( _roughDistanceKm(_route) ).toStringAsFixed(1)} km',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating controls
          Positioned(
            right: 12,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _roundButton(
                  icon: Icons.route,
                  label: 'Fit route',
                  onTap: _fitToRoute,
                ),
                const SizedBox(height: 10),
                _roundButton(
                  icon: Icons.movie_filter_outlined,
                  label: 'Fly',
                  onTap: _flyThrough,
                ),
                const SizedBox(height: 10),
                _roundButton(
                  icon: _trafficEnabled
                      ? Icons.traffic
                      : Icons.traffic_outlined,
                  label: 'Traffic',
                  onTap: () =>
                      setState(() => _trafficEnabled = !_trafficEnabled),
                ),
                const SizedBox(height: 10),
                _roundButton(
                  icon: Icons.layers,
                  label: 'Map',
                  onTap: () => setState(() {
                    _mapType = _mapType == MapType.normal
                        ? MapType.terrain
                        : _mapType == MapType.terrain
                        ? MapType.hybrid
                        : MapType.normal;
                  }),
                ),
              ],
            ),
          ),

          // Bottom sheet showing coordinates
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomSheet(
              startCoords: _route[0],
              endCoords: _route[1],
            ),
          ),
        ],
      ),
    );
  }

  // Rough haversine to show distance in the info card
  double _roughDistanceKm(List<LatLng> pts) {
    if (pts.length < 2) return 0;
    const R = 6371.0;
    double d = 0;
    for (int i = 1; i < pts.length; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final dLat = _deg2rad(b.latitude - a.latitude);
      final dLon = _deg2rad(b.longitude - a.longitude);
      final lat1 = _deg2rad(a.latitude);
      final lat2 = _deg2rad(b.latitude);
      final h = (sin(dLat / 2) * sin(dLat / 2)) +
          (cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2));
      d += 2 * R * asin(sqrt(h));
    }
    return d;
  }

  double _deg2rad(double deg) => deg * 3.141592653589793 / 180.0;
}

// Nice rounded action button
Widget _roundButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.black.withOpacity(0.65),
    borderRadius: BorderRadius.circular(28),
    child: InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

class _BottomSheet extends StatelessWidget {
  final LatLng startCoords;
  final LatLng endCoords;
  const _BottomSheet({
    required this.startCoords,
    required this.endCoords,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: const [
          BoxShadow(blurRadius: 14, color: Colors.black26, offset: Offset(0, -4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start: ${startCoords.latitude.toStringAsFixed(5)}, ${startCoords.longitude.toStringAsFixed(5)}\n\n'
                  'End: ${endCoords.latitude.toStringAsFixed(5)}, ${endCoords.longitude.toStringAsFixed(5)}',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}*/
