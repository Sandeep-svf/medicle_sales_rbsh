import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants/colors.dart';
import '../models/DoctorModelList.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(doctor.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: TColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          if (isTablet) {
            return _buildTabletLayout(context, constraints);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 16),
          _buildContactInfo(),
          const SizedBox(height: 16),
          _buildMapSection(),
          const SizedBox(height: 16),
          // --- GEO IMAGE SECTION ---
          _buildGeoImageSection(context),
          const SizedBox(height: 16),
          _buildBasicInfo(),
          const SizedBox(height: 16),
          _buildHeadOfficeInfo(),
          const SizedBox(height: 16),
          _buildVisitHistory(),
          const SizedBox(height: 16),
          _buildAccountInfo(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Tablet Layout ---
  Widget _buildTabletLayout(BuildContext context, BoxConstraints constraints) {
    bool isWideLandscape = constraints.maxWidth > 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),

          if (isWideLandscape)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildContactInfo(),
                      const SizedBox(height: 24),
                      _buildBasicInfo(),
                      const SizedBox(height: 24),
                      _buildAccountInfo(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      _buildMapSection(height: 300),
                      const SizedBox(height: 24),
                      _buildGeoImageSection(context),
                      const SizedBox(height: 24),
                      _buildHeadOfficeInfo(),
                      const SizedBox(height: 24),
                      _buildVisitHistory(),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildMapSection(height: 300),
                const SizedBox(height: 24),
                _buildGeoImageSection(context),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildContactInfo(),
                          const SizedBox(height: 24),
                          _buildBasicInfo(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildHeadOfficeInfo(),
                          const SizedBox(height: 24),
                          _buildVisitHistory(),
                          const SizedBox(height: 24),
                          _buildAccountInfo(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // --- 1. FIXED GEO IMAGE SECTION ---
  Widget _buildGeoImageSection(BuildContext context) {
    // Determine if we have a valid image URL
    final String? imageUrl = doctor.geoImageUrl;
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Geo Location Image", Icons.image_outlined),
          const Divider(),
          const SizedBox(height: 8),
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            // Use 'hasImage' check. If true, use imageUrl! (safe because of check)
            child: hasImage
                ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!, // Safe here because hasImage is true
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text("Failed to load image"));
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: () => _showFullImage(context, imageUrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text("View", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text(
                  "No Geo Location Image added yet",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. FIXED BASIC INFO (Removed '!' operators) ---
  Widget _buildBasicInfo() {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Basic Information", Icons.info_outline),
          const Divider(),
          _buildInfoRow(Icons.badge_outlined, "Registration", doctor.registrationNumber),

          // FIX: Check for NULL before formatting date
          _buildInfoRow(
              Icons.calendar_today_outlined,
              "DOB",
              doctor.dateOfBirth != null
                  ? DateFormat('dd MMM yyyy').format(doctor.dateOfBirth!)
                  : "N/A"
          ),

          // FIX: Check for NULL before formatting anniversary
          _buildInfoRow(
              Icons.cake_outlined,
              "Anniversary",
              doctor.anniversary != null
                  ? DateFormat('dd MMM yyyy').format(doctor.anniversary!)
                  : 'N/A'
          ),

          _buildInfoRow(
              Icons.work_history_outlined,
              "Experience",
              doctor.yearsOfExperience != null ? "${doctor.yearsOfExperience} Years" : "N/A"
          ),

          _buildInfoRow(Icons.person_outline, "Gender", doctor.gender),
        ],
      ),
    );
  }

  // --- OTHER WIDGETS ---

  Widget _buildProfileHeader() {
    String priority = doctor.priority; // Use value from model
    Color priorityColor;
    String priorityLabel;


    // Normalize input to handle potential "null" strings or empty values
    if (priority.isEmpty || priority.toLowerCase() == 'null') {
      priorityColor = Colors.grey;
      priorityLabel = "Not added";
    } else {
      switch (priority) {
        case 'A':
          priorityColor = Colors.red;
          priorityLabel = "High Priority";
          break;
        case 'B':
          priorityColor = Colors.orange;
          priorityLabel = "Medium Priority";
          break;
        case 'C':
          priorityColor = Colors.blueGrey;
          priorityLabel = "Standard Priority";
          break;
        default:
        // Handles cases where priority might be "D" or random text
          priorityColor = Colors.grey;
          priorityLabel = "Not added";
          break;
      }
    }

    return _buildStyledCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TColors.primary.withOpacity(0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: TColors.primary.withOpacity(0.1),
              child: const Icon(Icons.person, color: TColors.primary, size: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        doctor.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: priorityColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        priorityLabel,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: priorityColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  doctor.specialization.isNotEmpty ? doctor.specialization : "N/A",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.location.isNotEmpty ? doctor.location : "N/A",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Contact Information", Icons.contact_phone_outlined),
          const Divider(),
          _buildInfoRow(Icons.email_outlined, "Email", doctor.email),
          _buildInfoRow(Icons.phone_outlined, "Phone", doctor.phone),
        ],
      ),
    );
  }

  Widget _buildHeadOfficeInfo() {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Head Office", Icons.business_outlined),
          const Divider(),
          _buildInfoRow(Icons.store_mall_directory_outlined, "Office Name", doctor.headOffice.name),
        ],
      ),
    );
  }

  Widget _buildVisitHistory() {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Visit History", Icons.history_edu_outlined),
          const Divider(),
          if (doctor.visitHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  "No visit history available.",
                  style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("History data items..."),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Account Metadata", Icons.manage_accounts_outlined),
          const Divider(),
          _buildInfoRow(Icons.access_time, "Created", DateFormat('dd MMM yyyy, hh:mm a').format(doctor.createdAt)),
          _buildInfoRow(Icons.update, "Last Updated", DateFormat('dd MMM yyyy, hh:mm a').format(doctor.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildMapSection({double height = 220}) {
    double? lat = double.tryParse(doctor.latitude);
    double? lng = double.tryParse(doctor.longitude);
    bool isValidLocation = lat != null && lng != null && lat != 0.0 && lng != 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.primary.withOpacity(0.3), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: TColors.primary.withOpacity(0.04),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: TColors.primary),
                const SizedBox(width: 8),
                const Text("Location on Map", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.primary)),
              ],
            ),
          ),
          SizedBox(
            height: height,
            child: isValidLocation
                ? GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 15),
              markers: {Marker(markerId: const MarkerId("doctor_location"), position: LatLng(lat, lng), infoWindow: InfoWindow(title: doctor.name))},
            )
                : const Center(child: Text("Invalid Location Coordinates")),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.primary.withOpacity(0.3), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: TColors.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: TColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: TColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                Text(value.isNotEmpty ? value : "N/A", style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}