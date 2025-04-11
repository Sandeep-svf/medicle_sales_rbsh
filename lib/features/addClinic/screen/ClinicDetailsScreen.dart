import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:intl/intl.dart';

import '../model/Clinic.dart';

class ClinicDetailScreen extends StatelessWidget {
  final Clinic clinic;
  const ClinicDetailScreen({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(clinic.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text("Address"),
              subtitle: Text(clinic.address),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("City"),
              subtitle: Text(clinic.city),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Email"),
              subtitle: Text(clinic.email),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Phone"),
              subtitle: Text(clinic.phone),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Created At"),
              subtitle: Text(DateFormat('dd MMM yyyy').format(clinic.createdAt)),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("Updated At"),
              subtitle: Text(DateFormat('dd MMM yyyy').format(clinic.updatedAt)),
            ),
          ),
          const SizedBox(height: 12),
          const Text("Location on Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child:/* GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(clinic.latitude, clinic.longitude),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("clinic_location"),
                  position: LatLng(clinic.latitude, clinic.longitude),
                  infoWindow: InfoWindow(title: clinic.name),
                ),
              },
            ),*/
            Text("Location"),
          )
        ],
      ),
    );
  }
}