import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class OfflineDoctorLocationPicker extends StatefulWidget {
  const OfflineDoctorLocationPicker({super.key});
  @override
  State<OfflineDoctorLocationPicker> createState() =>
      _OfflineDoctorLocationPickerState();
}

class _OfflineDoctorLocationPickerState
    extends State<OfflineDoctorLocationPicker> {
  GoogleMapController? _mapController;
  LatLng? _centerLatLng;
  String _selectedAddress = "Fetching address...";
  bool _loading = true;

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
        if (mounted) setState(() => _loading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 25),
      );

      _centerLatLng = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      if (mounted) setState(() => _loading = false);
      await _updateAddress(_centerLatLng!);
    } catch (e) {
      _showError("Failed to fetch location: $e");
      if (mounted) setState(() => _loading = false);
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
      _showError(
          "Permission permanently denied. Please enable it in settings.");
      return false;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<void> _updateAddress(LatLng latLng) async {
    var address =
        '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
    try {
      final places =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude)
              .timeout(const Duration(seconds: 5));
      if (places.isNotEmpty) {
        final p = places.first;
        final parts = [p.street, p.locality, p.administrativeArea, p.postalCode]
            .whereType<String>()
            .where((v) => v.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) address = parts.join(', ');
      }
    } catch (_) {/* Coordinates remain selectable without reverse geocoding. */}
    if (mounted && _centerLatLng == latLng) {
      setState(() => _selectedAddress = address);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _centerLatLng = position.target;
      _selectedAddress = "Moving...";
    });
  }

  void _onCameraIdle() async {
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _centerLatLng == null
              ? Center(
                  child: ElevatedButton(
                      onPressed: _initLocationServices,
                      child: const Text('Retry current location')))
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
                      child:
                          Icon(Icons.location_pin, size: 40, color: Colors.red),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
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
