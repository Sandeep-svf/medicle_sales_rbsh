import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../model/Stokist.dart';




class StokistDetailScreen extends StatelessWidget {
  final Stokist stokist;
  const StokistDetailScreen({super.key, required this.stokist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(stokist.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text("Address"),
              subtitle: Text(stokist.address),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("City"),
              subtitle: Text(stokist.city),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Email"),
              subtitle: Text(stokist.email),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Phone"),
              subtitle: Text(stokist.phone),
            ),
          ),

          Card(
            child: ListTile(
              title: const Text("Updated At"),
              subtitle: Text(DateFormat('dd MMM yyyy').format(stokist.updatedAt)),
            ),
          ),
          const SizedBox(height: 12),
          const Text("Location on Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(stokist.latitude, stokist.longitude),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("stokist_location"),
                  position: LatLng(stokist.latitude, stokist.longitude),
                  infoWindow: InfoWindow(title: stokist.name),
                ),
              },
    ),

           // Text("Location"),
          ),
        ],
      ),
    );
  }
}