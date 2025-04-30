import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants/colors.dart';
import '../models/DoctorModelList.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;

  DoctorDetailsScreen({required this.doctor});



  @override
  Widget build(BuildContext context) {
    // Create the initial position for the map based on doctor's coordinates




    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name),
        backgroundColor: TColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Card with name and specialization
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: TColors.primary,
                          child: Icon(Icons.person, color: TColors.white, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor.specialization,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 1: Contact Info
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Contact Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Divider(color: Colors.grey.shade400),
                    ListTile(
                      leading: Icon(Icons.email, color: TColors.primary),
                      title: Text(doctor.email),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone, color: TColors.primary),
                      title: Text(doctor.phone),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 2: Basic Information
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Basic Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Divider(color: Colors.grey.shade400),
                    ListTile(
                      leading: Icon(Icons.business, color: TColors.primary),
                      title: Text("Registration Number: ${doctor.registrationNumber}"),
                    ),
                    ListTile(
                      leading: Icon(Icons.date_range, color: TColors.primary),
                      title: Text("Date of Birth: ${DateFormat('dd/MM/yyyy').format(doctor.dateOfBirth)}"),
                    ),
                    ListTile(
                      leading: Icon(Icons.cake, color: TColors.primary),
                      title: Text("Anniversary: ${doctor.anniversary != null ? DateFormat('dd/MM/yyyy').format(doctor.anniversary!) : 'N/A'}"),
                    ),
                    ListTile(
                      leading: Icon(Icons.work_history, color: TColors.primary),
                      title: Text("Years of Experience: ${doctor.yearsOfExperience}"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 3: Head Office Info
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Head Office", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Divider(color: Colors.grey.shade400),
                    ListTile(
                      leading: Icon(Icons.location_on, color: TColors.primary),
                      title: Text(doctor.headOffice.name),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 4: Visit History
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Visit History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Divider(color: Colors.grey.shade400),
                    const Text("No info available yet."),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 5: Created and Updated At
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Account Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Divider(color: Colors.grey.shade400),
                    ListTile(
                      leading: Icon(Icons.access_time, color: TColors.primary),
                      title: Text("Created At: ${DateFormat('dd/MM/yyyy').format(doctor.createdAt)}"),
                    ),
                    ListTile(
                      leading: Icon(Icons.update, color: TColors.primary),
                      title: Text("Updated At: ${DateFormat('dd/MM/yyyy').format(doctor.updatedAt)}"),
                    ),
                  ],
                ),
              ),
            ),

            // Google Map Section at the Bottom
            const SizedBox(height: 16),
            _buildSectionHeader("Location on Map"),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 220,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(doctor.latitude, doctor.longitude), // fallback
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("doctor_location"),
                      position: LatLng(doctor.latitude, doctor.longitude),
                      infoWindow: InfoWindow(title: doctor.name),
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
