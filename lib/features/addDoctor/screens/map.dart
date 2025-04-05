import 'package:flutter/material.dart';
/*
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  LatLng _currentLatLng = LatLng(28.6139, 77.2090); // Default location (New Delhi)
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get the user's current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, so we cannot continue
      return;
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // Handle permission denial permanently
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Get the current position
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentLatLng = LatLng(_currentPosition.latitude, _currentPosition.longitude);

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLatLng,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _currentLatLng = newPosition;
            });
          },
        ),
      );
    });
  }

  // This will be called when the map is created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLatLng,
          zoom: 15,
        ),
        markers: _markers,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true, // To enable the user's current location
        myLocationButtonEnabled: true, // Enable the location button
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Send the updated location (latitude and longitude) back
          Navigator.pop(context, {
            'lat': _currentLatLng.latitude,
            'long': _currentLatLng.longitude,
          });
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
*/


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




/*
*
*
* import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late Position _currentPosition;
  LatLng _currentLatLng = LatLng(28.6139, 77.2090); // Default to New Delhi
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get the user's current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, so we cannot continue
      return;
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // Handle permission denial permanently
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Get the current position
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentLatLng = LatLng(_currentPosition.latitude, _currentPosition.longitude);

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: _currentLatLng,
          draggable: true,
          onDragEnd: (newPosition) {
            _getAddressFromLatLng(newPosition.latitude, newPosition.longitude);
          },
        ),
      );
    });
  }

  // Fetch address from latitude and longitude
  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    final apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyCLRC2KUtUshQ7B1YX_gFaKYadrpThcM3g';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['results'].isNotEmpty) {
        String address = responseData['results'][0]['formatted_address'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected Address: $address')),
        );
        // You can pass the selected location back
        Navigator.pop(context, {
          'lat': latitude,
          'long': longitude,
          'address': address,
        });
      }
    } else {
      print("Error fetching address");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLatLng,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: _markers,
              onCameraMove: (position) {
                setState(() {
                  _currentLatLng = position.target;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Send back the selected lat, long, and address
                  Navigator.pop(context, {
                    'lat': _currentLatLng.latitude,
                    'long': _currentLatLng.longitude,
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

*
* */