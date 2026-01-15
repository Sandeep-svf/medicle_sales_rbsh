import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// --- Project Imports ---
import '../../../utils/camera/CameraLocationResult.dart';
import '../../../utils/camera/image_overlay_utils.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../controllers/ClinicListController.dart';
import '../../addDoctor/screens/map.dart';

class AddChemistController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // --- Text Controllers ---
  final firmNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final designationController = TextEditingController();
  final drugLicenseNumberController = TextEditingController();
  final gstController = TextEditingController();
  final yearsInBusinessController = TextEditingController();

  // --- Observables ---
  var isLoading = false.obs;
  var isLoadingHeadOffices = false.obs;

  var headOffices = <Map<String, String>>[].obs;
  var selectedHeadOfficeId = Rxn<String>();

  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var selectedLocationAddress = "".obs;

  var chemistImage = Rxn<File>();
  var isImageProcessing = false.obs;

  // --- Annual Turnover List (Observable) ---
  // We initialize it with one empty entry for the current year
  var annualTurnovers = <Map<String, dynamic>>[
    {"year": DateTime.now().year, "amount": 0}
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHeadOffices();
  }

  // --- HELPER: Update Turnovers ---
  // This method is critical for Obx to detect changes
  void updateTurnovers(List<Map<String, dynamic>> newList) {
    annualTurnovers.assignAll(newList);
  }

  // --- 1. FETCH HEAD OFFICES ---
  Future<void> fetchHeadOffices() async {
    isLoadingHeadOffices.value = true;
    try {
      final token = await AuthManager().getAuthToken();
      final response = await http.get(
        Uri.parse('${THttpHelper.baseUrl}/users/my-head-offices'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          headOffices.assignAll(data.map((e) => {
            'id': e['_id'].toString(), // Adjust key if needed (e.g., 'id' or '_id')
            'name': e['name'].toString(),
          }).toList());
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load Head Offices: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingHeadOffices.value = false;
    }
  }

  // --- 2. CAPTURE IMAGE ---
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

      chemistImage.value = layeredImage;

      // Auto-fill location if empty
      if(latitude.value == 0.0) {
        latitude.value = result.latitude;
        longitude.value = result.longitude;
      }
    } catch (e) {
      Get.snackbar("Error", "$e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isImageProcessing.value = false;
    }
  }

  // --- 3. PICK LOCATION ---
  Future<void> pickLocation() async {
    final result = await Get.to(() => LocationPickerScreen());
    if (result != null) {
      latitude.value = double.tryParse(result['latitude'].toString()) ?? 0.0;
      longitude.value = double.tryParse(result['longitude'].toString()) ?? 0.0;
      addressController.text = result['address'].toString();
      Get.snackbar("Location Set", "Coordinates updated.", backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  // --- 4. SUBMIT FORM ---
  // --- 4. SUBMIT FORM (Updated) ---
  Future<void> submitForm() async {
    // 1. Validation checks...
    if (!formKey.currentState!.validate()) {
      Get.snackbar("Required", "Please fill all required fields", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (chemistImage.value == null) {
      Get.snackbar("Missing Image", "Please capture the Chemist shop photo", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (latitude.value == 0.0 || selectedHeadOfficeId.value == null) {
      Get.snackbar("Incomplete", "Please select Location and Head Office", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    // Validation: At least one turnover > 0
    bool hasValidTurnover = annualTurnovers.isNotEmpty &&
        annualTurnovers.any((t) => (t['amount'] is num) && t['amount'] > 0);
    if (!hasValidTurnover) {
      Get.snackbar("Required", "Please add at least one valid Annual Turnover amount", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final token = await AuthManager().getAuthToken();
      final uri = Uri.parse("${THttpHelper.baseUrl}/chemists");

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({"Authorization": "Bearer $token"});

      // --- Add Fields ---
      request.fields['firmName'] = firmNameController.text;
      request.fields['contactPersonName'] = contactPersonController.text;
      request.fields['designation'] = designationController.text;
      request.fields['mobileNo'] = phoneController.text;
      request.fields['emailId'] = emailController.text;
      request.fields['drugLicenseNumber'] = drugLicenseNumberController.text;
      request.fields['gstNo'] = gstController.text;
      request.fields['address'] = addressController.text;
      request.fields['headOffice'] = selectedHeadOfficeId.value!;
      request.fields['latitude'] = latitude.value.toString();
      request.fields['longitude'] = longitude.value.toString();
      request.fields['yearsInBusiness'] = yearsInBusinessController.text.isEmpty ? "0" : yearsInBusinessController.text;
      request.fields['annualTurnover'] = jsonEncode(annualTurnovers.toList());

      if (chemistImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'geo_image',
          chemistImage.value!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // --- SUCCESS SEQUENCE ---

        // 1. Refresh the List (Try to find the list controller)
        try {
          final listController = Get.find<ClinicListController>();
          await listController.fetchClinicList(); // Ensure it waits for refresh
        } catch(e) {
          print("List Controller not found in memory: $e");
        }

        // 2. Clear Form Data
        _clearForm();

        // 3. Show Success Message
        Get.snackbar("Success", "Chemist Added Successfully!",
            backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 2));

        // 4. Go Back (Return 'true' to trigger refresh in previous screen if waiting)
        Get.back(result: true);

      } else {
        Get.snackbar("Failed", "Server Error: ${response.statusCode}", backgroundColor: Colors.red, colorText: Colors.white);
      }

    } catch (e) {
      Get.snackbar("Error", "$e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- HELPER: Clear Form ---
  void _clearForm() {
    firmNameController.clear();
    contactPersonController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    designationController.clear();
    drugLicenseNumberController.clear();
    gstController.clear();
    yearsInBusinessController.clear();

    chemistImage.value = null;
    latitude.value = 0.0;
    longitude.value = 0.0;
    selectedLocationAddress.value = "";
    selectedHeadOfficeId.value = null;

    // Reset turnover to default state
    annualTurnovers.assignAll([{"year": DateTime.now().year, "amount": 0}]);
  }

  @override
  void onClose() {
    firmNameController.dispose(); contactPersonController.dispose();
    phoneController.dispose(); emailController.dispose();
    addressController.dispose(); designationController.dispose();
    drugLicenseNumberController.dispose(); gstController.dispose();
    yearsInBusinessController.dispose();
    super.onClose();
  }
}