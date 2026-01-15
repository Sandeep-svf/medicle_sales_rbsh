import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationPickerScreen extends StatefulWidget {
  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _centerLatLng;
  String _selectedAddress = "Fetching address...";
  bool _loading = true;
  bool _mapMoving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationServices();
    });
  }


  Future<void> _initLocationServices() async {
    try {
      final hasPermission = await _handlePermission();
      if (!hasPermission) {
        _showError("Location permission denied.");
        setState(() => _loading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      _centerLatLng = LatLng(position.latitude, position.longitude);
      await _updateAddress(_centerLatLng!);
      setState(() => _loading = false);
    } catch (e) {
      _showError("Failed to fetch location: $e");
      setState(() => _loading = false);
    }
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError("Location services are disabled.");
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _showError("Permission permanently denied. Please enable it in settings.");
      return false;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }



  Future<void> _updateAddress(LatLng latLng) async {
    try {
      final apiKey = 'AIzaSyCnOFM-k3VOeG6v81O_zhVc1bdl0lY5jQ0';
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey');
    print("googel_map : https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey");
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'OK') {
        _selectedAddress = data['results'][0]['formatted_address'];
      } else {
        _selectedAddress = "Unable to get address.";
      }
    } catch (e) {
      _selectedAddress = "Error getting address.";
    }

    setState(() {});
  }


  void _onCameraMove(CameraPosition position) {
    setState(() {
      _mapMoving = true;
      _centerLatLng = position.target;
      _selectedAddress = "Moving...";
    });
  }

  void _onCameraIdle() async {
    setState(() => _mapMoving = false);
    if (_centerLatLng != null) {
      await _updateAddress(_centerLatLng!);
    }
  }

  void _onSelectLocation() {
    if (_centerLatLng != null) {
      Navigator.pop(context, {
        'latitude': _centerLatLng!.latitude,
        'longitude': _centerLatLng!.longitude,
        'address': _selectedAddress,
      });
    } else {
      _showError("No location selected.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: _loading || _centerLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _centerLatLng!,
              zoom: 16,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          // Center marker
          const Center(
            child: Icon(Icons.location_pin, size: 40, color: Colors.red),
          ),
          // Bottom UI
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedAddress,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _onSelectLocation,
                    icon: const Icon(Icons.check),
                    label: const Text("Select Location"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/*
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


*/
