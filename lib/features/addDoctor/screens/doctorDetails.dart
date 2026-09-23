import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../controllers/doctor_details_controller.dart';
import '../models/DoctorModelList.dart';
import '../../../utils/camera/CameraLocationResult.dart';
import '../../../utils/camera/image_overlay_utils.dart';
import '../../../utils/loder/CircularLoaderController.dart';
import '../models/doctor_details_model.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

// --- Project Imports ---

// --- Geo Overlay Utilities ---

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailsScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  late final DoctorDetailsController controller;
  DoctorDetailsModel get doctor => controller.doctor.value!;

  // Holds the locally captured image before uploading
  File? _localImageFile;

  @override
  void initState() {
    super.initState();

    controller = Get.put(
      DoctorDetailsController(widget.doctorId),
      tag: widget.doctorId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value || controller.doctor.value == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Scaffold(
        backgroundColor: TColors.hex_FFF5F5F5,
        appBar: AppBar(
          title: Text(
            controller.doctor.value?.name ?? "Doctor Details",
            style: const TextStyle(color: TColors.white),
          ),
          backgroundColor: TColors.primary,
          iconTheme: const IconThemeData(color: TColors.white),
        ),
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return _buildTabletLayout(context, constraints);
                } else {
                  return _buildMobileLayout(context);
                }
              },
            ),
            if (_isUploading)
              Container(
                color: TColors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: TColors.white,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: TSizes.v16),
          _buildContactInfo(),
          const SizedBox(height: TSizes.v16),
          _buildMapSection(),
          const SizedBox(height: TSizes.v16),
          // GEO IMAGE SECTION
          _buildGeoImageSection(context),
          const SizedBox(height: TSizes.v16),
          _buildBasicInfo(),
          const SizedBox(height: TSizes.v16),
          _buildHeadOfficeInfo(),
          const SizedBox(height: TSizes.v16),

          _buildAccountInfo(),
          const SizedBox(height: TSizes.v16),
          _buildVisitHistory(),

          const SizedBox(height: TSizes.v20),
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
          const SizedBox(height: TSizes.v24),
          if (isWideLandscape)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildContactInfo(),
                      const SizedBox(height: TSizes.v24),
                      _buildBasicInfo(),
                      const SizedBox(height: TSizes.v24),
                      _buildAccountInfo(),
                    ],
                  ),
                ),
                const SizedBox(width: TSizes.v24),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _buildContactInfo(),
                              const SizedBox(height: TSizes.v24),
                              _buildBasicInfo(),
                              const SizedBox(height: TSizes.v24),
                              _buildAccountInfo(),
                            ],
                          ),
                        ),
                        const SizedBox(width: TSizes.v24),
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: [
                              _buildMapSection(height: TSizes.v300),
                              const SizedBox(height: TSizes.v24),
                              _buildGeoImageSection(context),
                              const SizedBox(height: TSizes.v24),
                              _buildHeadOfficeInfo(),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: TSizes.v24),

                    _buildVisitHistory(), // <-- FULL WIDTH
                  ],
                )
              ],
            )
          else
            Column(
              children: [
                _buildMapSection(height: TSizes.v300),
                const SizedBox(height: TSizes.v24),

                _buildGeoImageSection(context),
                const SizedBox(height: TSizes.v24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildContactInfo(),
                          const SizedBox(height: TSizes.v24),
                          _buildBasicInfo(),
                        ],
                      ),
                    ),
                    const SizedBox(width: TSizes.v24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildHeadOfficeInfo(),
                          const SizedBox(height: TSizes.v24),
                          _buildAccountInfo(),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: TSizes.v24),

                _buildVisitHistory(), // <-- FULL WIDTH
              ],
            ),
        ],
      ),
    );
  }

  // ==================== GEO IMAGE SECTION (LOGIC UPDATED) ====================

  Widget _buildGeoImageSection(BuildContext context) {
    // 1. Check existing Server Image
    final String? serverImageUrl = doctor.geoImageUrl;
    final bool hasServerImage =
        serverImageUrl != null && serverImageUrl.isNotEmpty;

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
                  icon: const Icon(Icons.edit,
                      size: TSizes.v20, color: TColors.materialGrey),
                  tooltip: TTexts.uiTextReplaceImage,
                ),
            ],
          ),
          const Divider(),
          const SizedBox(height: TSizes.v8),

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
      height: TSizes.v250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: TColors.materialGrey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.materialGrey300),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, color: TColors.materialGrey)),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                    child: CircularProgressIndicator(color: TColors.primary));
              },
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: () => _showFullImage(context, url, isLocal: false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: TColors.pureBlack.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.visibility,
                        color: TColors.white, size: TSizes.v18),
                    SizedBox(width: TSizes.v6),
                    Text(TTexts.uiTextView,
                        style: TextStyle(
                            color: TColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: TSizes.v12)),
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
          height: TSizes.v250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: TColors.materialGrey100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: TColors.primary, width: TSizes.v2), // Highlight border
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
                  onTap: () => _showFullImage(context, _localImageFile!.path,
                      isLocal: true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: TColors.pureBlack.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.zoom_in,
                        color: TColors.white, size: TSizes.v20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TSizes.v16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showImageSourceSheet(context), // Re-pick
                icon: const Icon(Icons.refresh, color: TColors.materialGrey),
                label: const Text(TTexts.uiTextChange,
                    style: TextStyle(color: TColors.materialGrey)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: TColors.materialGrey),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: TSizes.v16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _uploadImageToApi(_localImageFile!), // Upload
                icon: const Icon(Icons.cloud_upload),
                label: const Text(TTexts.uiTextSubmitImage),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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
      height: TSizes.v180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: TColors.materialGrey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: TColors.materialGrey300, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined,
              size: TSizes.v40, color: TColors.materialGrey400),
          const SizedBox(height: TSizes.v12),
          const Text(
            TTexts.uiTextNoGeoLocationImageAddedYet,
            style: TextStyle(
                color: TColors.materialGrey,
                fontSize: TSizes.v14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: TSizes.v16),
          ElevatedButton.icon(
            onPressed: () => _showImageSourceSheet(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text(TTexts.uiTextCaptureUpload),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(TTexts.uiTextTakePhotoGeoOverlay),
              subtitle: const Text(TTexts.uiTextRecommended),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(TTexts.uiTextChooseFromGallery),
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
        if (status.isDenied) status = await Permission.storage.request();
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
        final CameraLocationResult? result =
            await CameraLocationService.captureImageWithLocation();

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
      Get.snackbar("Error", "Failed to capture image: $e",
          backgroundColor: TColors.materialRed, colorText: TColors.white);
    }
  }

  Future<void> _uploadImageToApi(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      final token = await AuthManager().getAuthToken();

      // API Endpoint
      final String url =
          '${THttpHelper.baseUrl}/doctors/${widget.doctorId}/geo-image';

      // POST Request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // --- FIX: Explicitly set Content-Type ---
      request.files.add(await http.MultipartFile.fromPath(
        'geo_image',
        imageFile.path,
        contentType:
            MediaType('image', 'jpeg'), // <--- THIS FIXES THE SERVER ERROR
      ));

      print("Uploading to: $url");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", TTexts.uiTextGeoImageUploadedSuccessfully,
            backgroundColor: TColors.materialGreen, colorText: TColors.white);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context, true); // Refresh list
      } else {
        // If server sends HTML error, try to show a generic message instead of raw HTML
        String msg = response.body.contains("Only image files")
            ? "Server Error: Only image files are allowed."
            : "Upload failed: ${response.statusCode}";

        Get.snackbar("Failed", msg,
            backgroundColor: TColors.materialRed, colorText: TColors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e",
          backgroundColor: TColors.materialRed, colorText: TColors.white);
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
          _buildSectionTitle(
            "Basic Information",
            Icons.info_outline,
          ),
          const Divider(),
          _buildInfoRow(
            Icons.badge_outlined,
            "Registration",
            doctor.registrationNumber ?? "N/A",
          ),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            "DOB",
            doctor.dateOfBirth != null &&
                    doctor.dateOfBirth!.toString().isNotEmpty
                ? DateFormat('dd MMM yyyy').format(
                    DateTime.parse(doctor.dateOfBirth!.toString()),
                  )
                : "N/A",
          ),
          _buildInfoRow(
            Icons.cake_outlined,
            "Anniversary",
            doctor.anniversary != null &&
                    doctor.anniversary!.toString().isNotEmpty
                ? DateFormat('dd MMM yyyy').format(
                    DateTime.parse(doctor.anniversary!.toString()),
                  )
                : "N/A",
          ),
          _buildInfoRow(
            Icons.work_history_outlined,
            "Experience",
            doctor.yearsOfExperience != null
                ? "${doctor.yearsOfExperience} Years"
                : "N/A",
          ),
          _buildInfoRow(
            Icons.person_outline,
            "Gender",
            doctor.gender ?? "N/A",
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final priority = doctor.priority;
    Color priorityColor;
    String priorityLabel;

    if (priority!.isEmpty || priority.toLowerCase() == 'null') {
      priorityColor = TColors.materialGrey;
      priorityLabel = "Not added";
    } else {
      switch (priority) {
        case 'A':
          priorityColor = TColors.materialRed;
          priorityLabel = "High Priority";
          break;
        case 'B':
          priorityColor = TColors.materialOrange;
          priorityLabel = "Medium Priority";
          break;
        case 'C':
          priorityColor = TColors.materialBlueGrey;
          priorityLabel = "Standard Priority";
          break;
        default:
          priorityColor = TColors.materialGrey;
          priorityLabel = "Not added";
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
              border: Border.all(
                color: TColors.primary.withOpacity(0.5),
                width: TSizes.v2,
              ),
            ),
            child: CircleAvatar(
              radius: TSizes.v35,
              backgroundColor: TColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: TColors.primary,
                size: TSizes.v40,
              ),
            ),
          ),
          const SizedBox(width: TSizes.v16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        controller.doctor.value?.name ?? "Unknown Doctor",
                        style: const TextStyle(
                          fontSize: TSizes.v22,
                          fontWeight: FontWeight.bold,
                          color: TColors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: priorityColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        priorityLabel,
                        style: TextStyle(
                          fontSize: TSizes.v11,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.v6),
                Text(
                  (doctor.specialization?.isNotEmpty ?? false)
                      ? doctor.specialization!
                      : "N/A",
                  style: TextStyle(
                    color: TColors.materialGrey600,
                    fontSize: TSizes.v16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: TSizes.v8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: TSizes.v14,
                      color: TColors.materialGrey500,
                    ),
                    const SizedBox(width: TSizes.v4),
                    Expanded(
                      child: Text(
                        (doctor.location?.isNotEmpty ?? false)
                            ? doctor.location!
                            : "N/A",
                        style: TextStyle(
                          color: TColors.materialGrey600,
                          fontSize: TSizes.v13,
                        ),
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
          _buildSectionTitle(
            "Contact Information",
            Icons.contact_phone_outlined,
          ),
          const Divider(),
          _buildInfoRow(
            Icons.email_outlined,
            "Email",
            (doctor.email?.isNotEmpty ?? false) ? doctor.email! : "N/A",
          ),
          _buildInfoRow(
            Icons.phone_outlined,
            "Phone",
            (doctor.phone?.isNotEmpty ?? false) ? doctor.phone! : "N/A",
          ),
        ],
      ),
    );
  }

  Widget _buildHeadOfficeInfo() {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Head Office",
            Icons.business_outlined,
          ),
          const Divider(),
          _buildInfoRow(
            Icons.store_mall_directory_outlined,
            "Office Name",
            doctor.headOffice?.name ?? "N/A",
          ),
        ],
      ),
    );
  }

  Widget _buildVisitHistory() {
    final visits = doctor.visitHistory ?? [];

    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Visit History",
            Icons.history_edu_outlined,
          ),
          const Divider(),
          if (visits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  TTexts.uiTextNoVisitHistory,
                  style: TextStyle(color: TColors.materialGrey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visits.length,
              itemBuilder: (_, index) {
                final visit = visits[index];

                return _buildVisitCard(visit);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(VisitHistory visit) {
    final confirmed = visit.confirmed ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.materialGrey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              confirmed ? TColors.materialGreen200 : TColors.materialOrange200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              CircleAvatar(
                radius: TSizes.v22,
                backgroundColor: confirmed
                    ? TColors.materialGreen100
                    : TColors.materialOrange100,
                child: Icon(
                  confirmed ? Icons.check : Icons.schedule,
                  color: confirmed
                      ? TColors.materialGreen
                      : TColors.materialOrange,
                ),
              ),
              const SizedBox(width: TSizes.v14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.date != null
                          ? DateFormat("dd MMM yyyy").format(visit.date!)
                          : "N/A",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: TSizes.v17,
                      ),
                    ),
                    const SizedBox(height: TSizes.v3),
                    Text(
                      visit.userName ?? "Unknown MR",
                      style: TextStyle(
                        color: TColors.materialGrey700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: confirmed
                      ? TColors.materialGreen100
                      : TColors.materialOrange100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  confirmed ? "Confirmed" : "Pending",
                  style: TextStyle(
                    color: confirmed
                        ? TColors.materialGreen900
                        : TColors.materialOrange900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: TSizes.v16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 700;

              return Wrap(
                spacing: TSizes.v16,
                runSpacing: TSizes.v16,
                children: [
                  SizedBox(
                    width: isTablet
                        ? (constraints.maxWidth - 32) / 3
                        : (constraints.maxWidth - 16) / 2,
                    child: _miniInfo(
                      Icons.person,
                      "MR Name",
                      visit.userName ?? "-",
                    ),
                  ),
                  SizedBox(
                    width: isTablet
                        ? (constraints.maxWidth - 32) / 3
                        : (constraints.maxWidth - 16) / 2,
                    child: _miniInfo(
                      Icons.email,
                      "Email",
                      visit.userEmail ?? "-",
                    ),
                  ),
                  SizedBox(
                    width: isTablet
                        ? (constraints.maxWidth - 32) / 3
                        : (constraints.maxWidth - 16) / 2,
                    child: _miniInfo(
                      Icons.medication,
                      "Product",
                      visit.product?.name ?? "-",
                    ),
                  ),
                  SizedBox(
                    width: isTablet
                        ? (constraints.maxWidth - 32) / 3
                        : (constraints.maxWidth - 16) / 2,
                    child: _miniInfo(
                      Icons.location_on,
                      "Location",
                      "${visit.latitude ?? "-"}, ${visit.longitude ?? "-"}",
                    ),
                  ),
                ],
              );
            },
          ),

          if ((visit.notes ?? "").isNotEmpty) ...[
            const SizedBox(height: TSizes.v16),
            const Text(
              TTexts.notes,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TSizes.v6),
            Text(visit.notes!),
          ],

          if ((visit.remark ?? "").isNotEmpty) ...[
            const SizedBox(height: TSizes.v16),
            const Text(
              TTexts.uiTextRemark,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TSizes.v6),
            Text(visit.remark!),
          ],

          if ((visit.productsDetailed ?? []).isNotEmpty) ...[
            const SizedBox(height: TSizes.v18),
            const Text(
              TTexts.uiTextProductsDetailed,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TSizes.v8),
            Wrap(
              spacing: TSizes.v8,
              runSpacing: TSizes.v8,
              children: visit.productsDetailed!
                  .map(
                    (e) => Chip(
                      avatar: const Icon(
                        Icons.medication,
                        size: TSizes.v18,
                      ),
                      label: Text(e),
                    ),
                  )
                  .toList(),
            ),
          ],

          if ((visit.giftsGiven ?? []).isNotEmpty) ...[
            const SizedBox(height: TSizes.v18),
            const Text(
              TTexts.uiTextGiftsGiven,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TSizes.v8),
            Wrap(
              spacing: TSizes.v8,
              runSpacing: TSizes.v8,
              children: visit.giftsGiven!
                  .map(
                    (e) => Chip(
                      backgroundColor: TColors.materialOrange50,
                      avatar: const Icon(
                        Icons.card_giftcard,
                        size: TSizes.v18,
                      ),
                      label: Text(e),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniInfo(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: TSizes.v18,
          color: TColors.primary,
        ),
        const SizedBox(width: TSizes.v8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColors.materialGrey600,
                  fontSize: TSizes.v12,
                ),
              ),
              const SizedBox(height: TSizes.v2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfo() {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Account Metadata",
            Icons.manage_accounts_outlined,
          ),
          const Divider(),
          _buildInfoRow(
            Icons.access_time,
            "Created",
            doctor.createdAt!.toString().isNotEmpty
                ? DateFormat('dd MMM yyyy, hh:mm a').format(
                    DateTime.parse(doctor.createdAt!.toString()),
                  )
                : "N/A",
          ),
          _buildInfoRow(
            Icons.update,
            "Last Updated",
            doctor.updatedAt!.toString().isNotEmpty
                ? DateFormat('dd MMM yyyy, hh:mm a').format(
                    DateTime.parse(doctor.updatedAt!.toString()),
                  )
                : "N/A",
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection({double height = 220}) {
    double? lat = double.tryParse(doctor.latitude ?? '');
    double? lng = double.tryParse(doctor.longitude ?? '');
    bool isValidLocation =
        lat != null && lng != null && lat != 0.0 && lng != 0.0;

    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: TColors.primary.withOpacity(0.3), width: TSizes.v1),
        boxShadow: [
          BoxShadow(
              color: TColors.pureBlack.withOpacity(0.06),
              blurRadius: TSizes.v15,
              offset: const Offset(0, 6))
        ],
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
                const SizedBox(width: TSizes.v8),
                const Text(TTexts.uiTextLocationOnMap,
                    style: TextStyle(
                        fontSize: TSizes.v16,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary)),
              ],
            ),
          ),
          SizedBox(
            height: height,
            child: isValidLocation
                ? GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: LatLng(lat, lng), zoom: 15),
                    markers: {
                      Marker(
                          markerId: const MarkerId("doctor_location"),
                          position: LatLng(lat, lng),
                          infoWindow: InfoWindow(title: doctor.name))
                    },
                  )
                : const Center(
                    child: Text(TTexts.uiTextInvalidLocationCoordinates)),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: TColors.primary.withOpacity(0.3), width: TSizes.v1),
        boxShadow: [
          BoxShadow(
              color: TColors.pureBlack.withOpacity(0.06),
              blurRadius: TSizes.v15,
              offset: const Offset(0, 6))
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: TSizes.v20, color: TColors.primary),
        const SizedBox(width: TSizes.v8),
        Text(title,
            style: const TextStyle(
                fontSize: TSizes.v16,
                fontWeight: FontWeight.bold,
                color: TColors.hex_FF333333)),
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
            decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: TSizes.v18, color: TColors.primary),
          ),
          const SizedBox(width: TSizes.v16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: TSizes.v12,
                        color: TColors.materialGrey500,
                        fontWeight: FontWeight.w600)),
                Text(value.isNotEmpty ? value : "N/A",
                    style: const TextStyle(
                        fontSize: TSizes.v14,
                        color: TColors.black87,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String path,
      {required bool isLocal}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: TColors.transparent,
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
                    color: TColors.pureBlack.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: TColors.white, width: TSizes.v1_5),
                  ),
                  child: const Icon(Icons.close,
                      color: TColors.white, size: TSizes.v22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
