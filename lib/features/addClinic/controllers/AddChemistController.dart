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
  // This is purely for internal logic; the address text is sent via addressController
  var selectedLocationAddress = "".obs;

  var chemistImage = Rxn<File>();
  var isImageProcessing = false.obs;

  var annualTurnovers = <Map<String, dynamic>>[
    {"year": DateTime.now().year, "amount": 0}
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHeadOffices();
  }

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
            'id': e['id'].toString(),
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

      // We fill the address controller so the user can see/edit it
      addressController.text = result['address'].toString();

      Get.snackbar("Location Set", "Coordinates updated.", backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  // --- 4. SUBMIT FORM ---
  Future<void> submitForm() async {
    // 1. Basic Form Validation (Checks Firm Name & Contact Person in UI)
    if (!formKey.currentState!.validate()) {
      Get.snackbar("Required", "Please fill all mandatory fields (marked with *)", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // 2. Manual Validation for Non-Form Fields
    if (chemistImage.value == null) {
      Get.snackbar("Missing Image", "Please capture the Chemist shop photo", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Check Head Office
    if (selectedHeadOfficeId.value == null) {
      Get.snackbar("Required", "Please select a Head Office", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Check Location (Lat/Lng)
    if (latitude.value == 0.0 || longitude.value == 0.0) {
      Get.snackbar("Location Required", "Please select the location on the map", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final token = await AuthManager().getAuthToken();
      final uri = Uri.parse("${THttpHelper.baseUrl}/chemists");

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({"Authorization": "Bearer $token"});

      // --- MANDATORY FIELDS ---
      request.fields['firmName'] = firmNameController.text.trim();
      request.fields['contactPersonName'] = contactPersonController.text.trim();
      request.fields['headOffice'] = selectedHeadOfficeId.value!;

      // Location is mandatory
      request.fields['latitude'] = latitude.value.toString();
      request.fields['longitude'] = longitude.value.toString();

      // --- OPTIONAL FIELDS (Default Logic) ---

      // String Defaults: Send "" if empty
      request.fields['mobileNo'] = phoneController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['designation'] = designationController.text.trim();
      request.fields['drugLicenseNumber'] = drugLicenseNumberController.text.trim();
      request.fields['gstNo'] = gstController.text.trim();
      request.fields['address'] = addressController.text.trim();

      // Integer Defaults: Send "0" if empty
      String yearsInput = yearsInBusinessController.text.trim();
      int yearsVal = yearsInput.isEmpty ? 0 : (int.tryParse(yearsInput) ?? 0);
      request.fields['yearsInBusiness'] = yearsVal.toString();

      // Turnover: Usually contains numbers. If amount is empty or invalid, logic ensures valid JSON.
      // If list is empty or amounts are 0, it sends 0s.
      request.fields['annualTurnover'] = jsonEncode(annualTurnovers.toList());

      // --- ADD IMAGE (Mandatory) ---
      if (chemistImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'geo_image',
          chemistImage.value!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      print("Submitting to: $uri");
      print("Fields: ${request.fields}");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // --- SUCCESS SEQUENCE ---
        try {
          if (Get.isRegistered<ClinicListController>()) {
            final listController = Get.find<ClinicListController>();
            await listController.fetchClinicList();
          }
        } catch(e) {
          print("List Controller error: $e");
        }

        _clearForm();

        Get.snackbar("Success", "Chemist Added Successfully!",
            backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 2));

        await Future.delayed(const Duration(milliseconds: 1500));

        if(Get.context != null && Navigator.canPop(Get.context!)) {
          Navigator.of(Get.context!).pop(true);
        } else {
          Get.back(result: true);
        }

      } else {
        print("Server Error Body: ${response.body}");
        Get.snackbar("Failed", "Server Error: ${response.statusCode}", backgroundColor: Colors.red, colorText: Colors.white);
      }

    } catch (e) {
      Get.snackbar("Error", "$e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

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