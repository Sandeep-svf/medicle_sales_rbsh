import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart'; // <--- ADD THIS
// --- Project Imports ---
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../../../utils/constants/colors.dart';
import '../models/DoctorModelList.dart';

// --- Geo Overlay Utilities ---
import '../../../utils/camera/CameraLocationResult.dart';
import '../../../utils/camera/image_overlay_utils.dart';
import '../../../utils/loder/CircularLoaderController.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // Holds the locally captured image before uploading
  File? _localImageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.doctor.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: TColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        elevation: 0,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isTablet = constraints.maxWidth > 600;
              if (isTablet) {
                return _buildTabletLayout(context, constraints);
              } else {
                return _buildMobileLayout(context);
              }
            },
          ),

          // Loading Overlay
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
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
          // GEO IMAGE SECTION
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

  // ==================== GEO IMAGE SECTION (LOGIC UPDATED) ====================

  Widget _buildGeoImageSection(BuildContext context) {
    // 1. Check existing Server Image
    final String? serverImageUrl = widget.doctor.geoImageUrl;
    final bool hasServerImage = serverImageUrl != null && serverImageUrl.isNotEmpty;

    // 2. Check local preview Image (User just took a photo)
    final bool hasLocalPreview = _localImageFile != null;

    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle("Geo Location Image", Icons.image_outlined),
              // Show Edit button ONLY if we are currently showing the server image
              // If we have a local preview, the "Change" button is already inside that view
              if (hasServerImage && !hasLocalPreview)
                IconButton(
                  onPressed: () => _showImageSourceSheet(context),
                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                  tooltip: "Replace Image",
                ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // --- FIXED LOGIC ORDER ---
          if (hasLocalPreview)
          // PRIORITY 1: Show the new image user just captured (Review Mode)
            _buildLocalPreviewView()

          else if (hasServerImage)
          // PRIORITY 2: Show existing server image (Read-Only)
            _buildServerImageView(context, serverImageUrl!)

          else
          // PRIORITY 3: Nothing exists, show upload placeholder
            _buildUploadPlaceholder(context),
        ],
      ),
    );
  }

  // --- View for Server Image ---
  Widget _buildServerImageView(BuildContext context, String url) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(color: TColors.primary));
              },
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: () => _showFullImage(context, url, isLocal: false),
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
      ),
    );
  }

  // --- View for Local Preview (With Submit/Change) ---
  Widget _buildLocalPreviewView() {
    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TColors.primary, width: 2), // Highlight border
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_localImageFile!, fit: BoxFit.cover),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: GestureDetector(
                  onTap: () => _showFullImage(context, _localImageFile!.path, isLocal: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showImageSourceSheet(context), // Re-pick
                icon: const Icon(Icons.refresh, color: Colors.grey),
                label: const Text("Change", style: TextStyle(color: Colors.grey)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _uploadImageToApi(_localImageFile!), // Upload
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Submit Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- View for No Image (Initial State) ---
  Widget _buildUploadPlaceholder(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            "No Geo Location Image added yet",
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showImageSourceSheet(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text("Capture / Upload"),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== IMAGE PICKER & API LOGIC ====================

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo (Geo Overlay)'),
              subtitle: const Text("Recommended"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool isCamera}) async {
    // 1. Permission Check
    PermissionStatus status;
    if (isCamera) {
      status = await Permission.camera.request();
    } else {
      if (Platform.isAndroid) {
        status = await Permission.photos.request();
        if(status.isDenied) status = await Permission.storage.request();
      } else {
        status = await Permission.photos.request();
      }
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    try {
      File? tempImage;

      // 2. Capture
      if (isCamera) {
        // --- CAMERA: Capture + Geo Overlay ---
        final CameraLocationResult? result = await CameraLocationService.captureImageWithLocation();

        if (result != null) {
          // Apply Overlay (Lat/Lng/Date)
          tempImage = await ImageOverlayUtil.addOverlay(
            original: result.image,
            lat: result.latitude,
            lng: result.longitude,
          );
        }
      } else {
        // --- GALLERY: Simple Pick ---
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          tempImage = File(pickedFile.path);
        }
      }

      // 3. Update State (Preview Mode) - Do NOT upload yet
      if (tempImage != null) {
        setState(() {
          _localImageFile = tempImage;
        });
      }

    } catch (e) {
      Get.snackbar("Error", "Failed to capture image: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _uploadImageToApi(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      final token = await AuthManager().getAuthToken();

      // API Endpoint
      final String url = '${THttpHelper.baseUrl}/doctors/${widget.doctor.id}/geo-image';

      // POST Request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // --- FIX: Explicitly set Content-Type ---
      request.files.add(await http.MultipartFile.fromPath(
        'geo_image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'), // <--- THIS FIXES THE SERVER ERROR
      ));

      print("Uploading to: $url");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Geo Image Uploaded Successfully!", backgroundColor: Colors.green, colorText: Colors.white);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context, true); // Refresh list
      } else {
        // If server sends HTML error, try to show a generic message instead of raw HTML
        String msg = response.body.contains("Only image files")
            ? "Server Error: Only image files are allowed."
            : "Upload failed: ${response.statusCode}";

        Get.snackbar("Failed", msg, backgroundColor: Colors.red, colorText: Colors.white);
      }

    } catch (e) {
      Get.snackbar("Error", "Exception: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ==================== OTHER WIDGETS ====================

  Widget _buildBasicInfo() {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Basic Information", Icons.info_outline),
          const Divider(),
          _buildInfoRow(Icons.badge_outlined, "Registration", widget.doctor.registrationNumber),

          _buildInfoRow(
              Icons.calendar_today_outlined,
              "DOB",
              widget.doctor.dateOfBirth != null
                  ? DateFormat('dd MMM yyyy').format(widget.doctor.dateOfBirth!)
                  : "N/A"
          ),

          _buildInfoRow(
              Icons.cake_outlined,
              "Anniversary",
              widget.doctor.anniversary != null
                  ? DateFormat('dd MMM yyyy').format(widget.doctor.anniversary!)
                  : 'N/A'
          ),

          _buildInfoRow(
              Icons.work_history_outlined,
              "Experience",
              widget.doctor.yearsOfExperience != null ? "${widget.doctor.yearsOfExperience} Years" : "N/A"
          ),

          _buildInfoRow(Icons.person_outline, "Gender", widget.doctor.gender),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    String priority = widget.doctor.priority;
    Color priorityColor;
    String priorityLabel;

    if (priority.isEmpty || priority.toLowerCase() == 'null') {
      priorityColor = Colors.grey;
      priorityLabel = "Not added";
    } else {
      switch (priority) {
        case 'A': priorityColor = Colors.red; priorityLabel = "High Priority"; break;
        case 'B': priorityColor = Colors.orange; priorityLabel = "Medium Priority"; break;
        case 'C': priorityColor = Colors.blueGrey; priorityLabel = "Standard Priority"; break;
        default: priorityColor = Colors.grey; priorityLabel = "Not added"; break;
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
                        widget.doctor.name,
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
                  widget.doctor.specialization.isNotEmpty ? widget.doctor.specialization : "N/A",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.doctor.location.isNotEmpty ? widget.doctor.location : "N/A",
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
          _buildInfoRow(Icons.email_outlined, "Email", widget.doctor.email),
          _buildInfoRow(Icons.phone_outlined, "Phone", widget.doctor.phone),
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
          _buildInfoRow(Icons.store_mall_directory_outlined, "Office Name", widget.doctor.headOffice.name),
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
          if (widget.doctor.visitHistory.isEmpty)
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
          _buildInfoRow(Icons.access_time, "Created", DateFormat('dd MMM yyyy, hh:mm a').format(widget.doctor.createdAt)),
          _buildInfoRow(Icons.update, "Last Updated", DateFormat('dd MMM yyyy, hh:mm a').format(widget.doctor.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildMapSection({double height = 220}) {
    double? lat = double.tryParse(widget.doctor.latitude);
    double? lng = double.tryParse(widget.doctor.longitude);
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
              markers: {Marker(markerId: const MarkerId("doctor_location"), position: LatLng(lat, lng), infoWindow: InfoWindow(title: widget.doctor.name))},
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

  void _showFullImage(BuildContext context, String path, {required bool isLocal}) {
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
                child: isLocal
                    ? Image.file(File(path), fit: BoxFit.contain)
                    : Image.network(path, fit: BoxFit.contain),
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