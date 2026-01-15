import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
// --- Ensure these imports match your project structure ---
import '../../../utils/camera/CameraLocationResult.dart';
import '../../../utils/camera/image_overlay_utils.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/http/http_client.dart'; // Contains THttpHelper
import '../../../utils/local_storage/auth_manager.dart'; // Contains AuthManager
import '../screens/map.dart';

// import '../../../utils/sqlite_helper/GenericDatabaseHelper.dart';
// import '../models/CityOfflineModel.dart';

class AddDoctorNewController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // --- Text Controllers ---
  final nameController = TextEditingController();
  final specializationController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final registrationController = TextEditingController();
  final experienceController = TextEditingController();
  final dobController = TextEditingController();
  final anniversaryController = TextEditingController();

  // --- Address Controllers ---
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final countryController = TextEditingController();
  final postOfficeController = TextEditingController();

  // --- Observables ---
  var selectedGender = 'Male'.obs;
  var headOffices = <Map<String, String>>[].obs;
  var isLoadingHeadOffices = false.obs;
  var selectedHeadOfficeId = Rxn<String>();

  // --- Priority Observable ---
  var selectedPriority = 'A'.obs;
  final List<String> priorities = ['A', 'B', 'C'];

  // Location & Image Data
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var isLocationSet = false.obs;
  var doctorImage = Rxn<File>();
  var imageCapturedAt = Rxn<DateTime>();
  var isImageProcessing = false.obs;

  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void onInit() {
    super.onInit();
    fetchHeadOffices();
  }

  // --- 1. FETCH HEAD OFFICES ---
  Future<void> fetchHeadOffices() async {
    isLoadingHeadOffices.value = true;
    try {
      final token = await AuthManager().getAuthToken();
      final String baseUrl = THttpHelper.baseUrl;

      final response = await http.get(
        Uri.parse('$baseUrl/users/my-head-offices'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> dataList = jsonResponse['data'];

          headOffices.assignAll(dataList.map((e) => {
            'id': e['id'].toString(),
            'name': e['name'].toString(),
          }).toList());

          print("[DEBUG] Loaded ${headOffices.length} Head Offices.");
        }
      } else {
        print("[ERROR] Failed to load Head Offices: ${response.statusCode}");
      }
    } catch (e) {
      print("[ERROR] Exception fetching Head Offices: $e");
    } finally {
      isLoadingHeadOffices.value = false;
    }
  }

  // --- 2. SUBMIT FUNCTION (FIXED) ---


// ... inside AddDoctorNewController

  Future<void> submit() async {
    // 1. Validation
    if (!formKey.currentState!.validate()) {
      Get.snackbar("Required", "Please fill all fields.", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (doctorImage.value == null) {
      Get.snackbar("Missing Photo", "Please capture the doctor's photo.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (latitude.value == 0.0) {
      Get.snackbar("Missing Location", "Please select location on map.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      final token = await AuthManager().getAuthToken();
      final String url = '${THttpHelper.baseUrl}/doctors';

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // Add Text Fields
      request.fields['name'] = nameController.text;
      request.fields['specialization'] = specializationController.text;
      request.fields['location'] = address1Controller.text;
      request.fields['latitude'] = latitude.value.toString();
      request.fields['longitude'] = longitude.value.toString();
      request.fields['email'] = emailController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['registration_number'] = registrationController.text;
      request.fields['years_of_experience'] = experienceController.text;
      request.fields['date_of_birth'] = dobController.text;
      request.fields['gender'] = selectedGender.value;
      request.fields['anniversary'] = anniversaryController.text;
      request.fields['headOfficeId'] = selectedHeadOfficeId.value ?? "";
      request.fields['priority'] = selectedPriority.value;

      /*if(address2Controller.text.isNotEmpty) request.fields['address2'] = address2Controller.text;
      if(stateController.text.isNotEmpty) request.fields['state'] = stateController.text;
      if(pincodeController.text.isNotEmpty) request.fields['pincode'] = pincodeController.text;
      if(countryController.text.isNotEmpty) request.fields['country'] = countryController.text;
      if(postOfficeController.text.isNotEmpty) request.fields['post_office'] = postOfficeController.text;*/

      // --- FIX: Explicitly set Content Type ---
      if (doctorImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'geo_image',
          doctorImage.value!.path,
          contentType: MediaType('image', 'jpeg'), // Explicitly sets MIME type to image/jpeg
        ));
      }

      print("[DEBUG] Submitting to $url");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      Get.back(); // Hide Loader

      print('[DEBUG] Response Status: ${response.statusCode}');
      print('[DEBUG] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Doctor Created Successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
      } else {
        // Parse error message safely
        String errorMsg = "Failed to add doctor";
        try {
          // Your server returned HTML error, so JSON decode might fail.
          // If it is JSON:
          var jsonBody = json.decode(response.body);
          if(jsonBody['message'] != null) errorMsg = jsonBody['message'];
        } catch (_) {
          // If server returned HTML (like the error you posted), use generic message
          if(response.body.contains("Only image files are allowed")) {
            errorMsg = "Server Error: Only image files allowed.";
          }
        }
        Get.snackbar("Error", errorMsg, backgroundColor: Colors.red, colorText: Colors.white);
      }

    } catch (e) {
      Get.back();
      print("[ERROR] Submit Exception: $e");
      Get.snackbar("Error", "An error occurred: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- Helper: Date Picker ---
  // --- Date Picker (Updated Format to yyyy-MM-dd) ---
  Future<void> selectDate(BuildContext context, bool isAnniversary) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: TColors.primary),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // CHANGED: Format is now yyyy-MM-dd (e.g., 2024-12-12)
      String val = DateFormat('yyyy-MM-dd').format(picked);

      if (isAnniversary) {
        anniversaryController.text = val;
      } else {
        dobController.text = val;
      }
    }
  }

  // --- Helper: Capture Image ---
  Future<void> captureImage() async {
    try {
      isImageProcessing.value = true;
      final CameraLocationResult? result = await CameraLocationService.captureImageWithLocation();
      if (result == null) return;

      final File layeredImage = await ImageOverlayUtil.addOverlay(
        original: result.image,
        lat: result.latitude,
        lng: result.longitude,
      );

      doctorImage.value = layeredImage;
      imageCapturedAt.value = DateTime.now();
    } catch (e) {
      Get.snackbar("Error", "$e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isImageProcessing.value = false;
    }
  }

  // --- Helper: Location Picker ---
  Future<void> pickLocationOnMap() async {
    final result = await Get.to(() => LocationPickerScreen());
    if (result != null && result is Map<String, dynamic>) {
      latitude.value = result['latitude'] ?? 0.0;
      longitude.value = result['longitude'] ?? 0.0;
      address1Controller.text = result['address'] ?? '';

      if (result.containsKey('state')) stateController.text = result['state'] ?? '';
      if (result.containsKey('pincode')) pincodeController.text = result['pincode'] ?? '';
      if (result.containsKey('country')) countryController.text = result['country'] ?? '';
      if (result.containsKey('postOffice')) postOfficeController.text = result['postOffice'] ?? '';

      isLocationSet.value = true;
      Get.snackbar("Location Fetched", "Coordinates set.", backgroundColor: Colors.green.withOpacity(0.9), colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    nameController.dispose(); specializationController.dispose();
    emailController.dispose(); phoneController.dispose();
    registrationController.dispose(); experienceController.dispose();
    dobController.dispose(); anniversaryController.dispose();
    address1Controller.dispose(); address2Controller.dispose();
    stateController.dispose(); pincodeController.dispose();
    countryController.dispose(); postOfficeController.dispose();
    super.onClose();
  }
}