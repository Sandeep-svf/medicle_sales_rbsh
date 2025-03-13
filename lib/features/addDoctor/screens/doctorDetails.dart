import 'package:flutter/material.dart';

class DoctordetailsScreen extends StatelessWidget {
  final Map<String, String> doctor;
  const DoctordetailsScreen({super.key, required this.doctor});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(doctor["name"]!)),
    body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    _buildDetailRow("Specialization", doctor["specialization"] ?? ""),
    _buildDetailRow("Location", doctor["location"] ?? ""),
    _buildDetailRow("Email", doctor["email"] ?? ""),
    _buildDetailRow("Registration No.", doctor["registrationNumber"] ?? ""),
    _buildDetailRow("Experience", doctor["yearOfExperience"] ?? ""),
    _buildDetailRow("DOB", doctor["dob"] ?? ""),
    _buildDetailRow("Gender", doctor["gender"] ?? ""),
    _buildDetailRow("Anniversary", doctor["anniversary"] ?? ""),
    ],
    ),
    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
