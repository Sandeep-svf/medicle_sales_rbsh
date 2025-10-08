import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../model/clinic.dart';

class ClinicDetailScreen extends StatelessWidget {
  final Clinic clinic;
  const ClinicDetailScreen({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clinic.firmName),
        backgroundColor: const Color(0xFFC71D52),
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Chemist Details"),
          _buildInfoTile(Icons.location_on, "Address", clinic.address),
          _buildInfoTile(Icons.email, "Email", clinic.emailId),
          _buildInfoTile(Icons.phone, "Phone", clinic.mobileNo),
          _buildInfoTile(Icons.update, "Updated At", "No info available yet"),

          const SizedBox(height: 24),
          _buildSectionHeader("Location on Map"),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(28.500719, 77.532639), // fallback
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("clinic_location"),
                    position: LatLng(28.500719, 77.532639),
                    infoWindow: InfoWindow(title: clinic.firmName),
                  ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFC71D52),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
