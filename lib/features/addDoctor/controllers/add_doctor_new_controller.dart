import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../utils/camera/CameraLocationResult.dart';
import '../../../utils/camera/image_overlay_utils.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../screens/map.dart';
import 'DoctroController.dart';

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
  var areas = <Map<String, dynamic>>[].obs;
  var isLoadingAreas = false.obs;
  var selectedAreaId = Rxn<String>();

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
    fetchAreas();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPincodeDialog();
    });
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
        }
      }
    } catch (e) {
      print("[ERROR] Exception fetching Head Offices: $e");
    } finally {
      isLoadingHeadOffices.value = false;
    }
  }


  // fetch address by pincode
  Future<bool> fetchAddressByPincode(String pincode) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.postalpincode.in/pincode/$pincode',
        ),
      );

      if (response.statusCode != 200) {
        Get.snackbar(
          "Error",
          "Unable to fetch pincode details",
        );
        return false;
      }

      final data = jsonDecode(response.body);

      if (data.isEmpty ||
          data[0]['Status'] != 'Success' ||
          data[0]['PostOffice'] == null ||
          (data[0]['PostOffice'] as List).isEmpty) {
        Get.snackbar(
          "Invalid Pincode",
          data[0]['Message'] ?? "Invalid Pincode",
        );
        return false;
      }

      final List offices = data[0]['PostOffice'];

      if (offices.length == 1) {
        fillAddress(
          Map<String, dynamic>.from(offices.first),
          pincode,
        );
      } else {
        await showPostOfficeSelection(
          offices,
          pincode,
        );
      }

      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
      return false;
    }
  }

  void fillAddress(
      Map<String, dynamic> office,
      String pincode,
      ) {
    stateController.text =
        office['State'] ?? '';

    countryController.text =
        office['Country'] ?? '';

    postOfficeController.text =
        office['Name'] ?? '';

    pincodeController.text =
        pincode;

    address1Controller.text =
    "${office['Name']}, "
        "${office['Block'] ?? ''}, "
        "${office['District'] ?? ''}, "
        "${office['State'] ?? ''}, "
        "${office['Country'] ?? ''} - "
        "$pincode";
  }

  Future<void> showPostOfficeSelection(
      List offices,
      String pincode,
      ) async {
    int selectedIndex = 0;

    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select Doctor Area",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "$pincode has multiple areas. Select one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: offices.length,
                      itemBuilder: (_, index) {
                        final office = offices[index];

                        return RadioListTile<int>(
                          value: index,
                          groupValue: selectedIndex,
                          title: Text(
                            office['Name'] ?? '',
                          ),
                          subtitle: Text(
                            office['Block'] ??
                                office['District'] ??
                                '',
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedIndex = value!;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        fillAddress(
                          Map<String, dynamic>.from(
                            offices[selectedIndex],
                          ),
                          pincode,
                        );

                        Get.back();
                      },
                      child: const Text(
                        "Continue",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> createArea({
    required String name,
    required String pincode,
    required String postOffice,
  }) async {
    try {
      print(
        '[AddDoctorNewController] createArea() START',
      );

      print(
        '[AddDoctorNewController] Payload => '
            'name=$name, '
            'pincode=$pincode, '
            'postOffice=$postOffice, '
            'headOfficeId=${selectedHeadOfficeId.value}',
      );

      final token = await AuthManager().getAuthToken();

      final response = await http.post(
        Uri.parse('${THttpHelper.baseUrl}/areas'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "pincode": pincode,
          "post_office": postOffice,
          "head_office_id": selectedHeadOfficeId.value,
        }),
      );

      print(
        '[AddDoctorNewController] Status Code => ${response.statusCode}',
      );

      print(
        '[AddDoctorNewController] Response Body => ${response.body}',
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        final jsonResponse =
        json.decode(response.body);

        print(
          '[AddDoctorNewController] Parsed Response => $jsonResponse',
        );

        final createdAreaId =
        jsonResponse['data']?['id'];

        print(
          '[AddDoctorNewController] Created Area ID => $createdAreaId',
        );

        await fetchAreas();

        print(
          '[AddDoctorNewController] Areas Count After Refresh => ${areas.length}',
        );

        print(
          '[AddDoctorNewController] Areas => $areas',
        );

        selectedAreaId.value = createdAreaId;

        print(
          '[AddDoctorNewController] Selected Area ID => ${selectedAreaId.value}',
        );

        Get.snackbar(
          "Success",
          "Area Created",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print(
          '[AddDoctorNewController] Create Area Failed => ${response.body}',
        );
      }
    } catch (e, s) {
      print(
        '[AddDoctorNewController] Exception => $e',
      );

      print(
        '[AddDoctorNewController] StackTrace => $s',
      );

      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  // New Added
  Future<void> fetchAreas() async {
    isLoadingAreas.value = true;

    try {
      final token = await AuthManager().getAuthToken();

      final response = await http.get(
        Uri.parse('${THttpHelper.baseUrl}/areas'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          areas.assignAll(
            List<Map<String, dynamic>>.from(
              jsonResponse['data'],
            ),
          );
        }
      }
    } catch (e) {
      print("Area Fetch Error => $e");
    } finally {
      isLoadingAreas.value = false;
    }
  }

  // --- 2. SUBMIT FUNCTION (UPDATED) ---
  Future<void> submit(BuildContext context) async {
    // 1. Validation for REQUIRED fields only
    if (!formKey.currentState!.validate()) {
      Get.snackbar("Required", "Please fill required fields (marked *).",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (selectedHeadOfficeId.value == null) {
      Get.snackbar("Missing Info", "Please select a Head Office.",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (selectedAreaId.value == null) {
      Get.snackbar(
        "Missing Info",
        "Please select Area",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (doctorImage.value == null) {
      Get.snackbar("Missing Photo", "Please capture the doctor's photo.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (latitude.value == 0.0) {
      Get.snackbar("Missing Location", "Please select location on map.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // 2. Show Loader
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: TColors.primary)),
      barrierDismissible: false,
    );

    try {
      final token = await AuthManager().getAuthToken();
      final String url = '${THttpHelper.baseUrl}/doctors';

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // --- ADD FIELDS ---

      // REQUIRED FIELDS
      request.fields['name'] = nameController.text.trim();
      request.fields['headOfficeId'] = selectedHeadOfficeId.value!;
      request.fields['areaId'] = selectedAreaId.value!;
      request.fields['latitude'] = latitude.value.toString();
      request.fields['longitude'] = longitude.value.toString();
      request.fields['gender'] = selectedGender.value;
      request.fields['priority'] = selectedPriority.value;

      // OPTIONAL: INT TYPES (Send "0" if empty)
      request.fields['years_of_experience'] = experienceController.text.isEmpty
          ? "0"
          : experienceController.text.trim();

      // OPTIONAL: TEXT TYPES (Send "" if empty)
      request.fields['specialization'] = specializationController.text.trim();
      request.fields['location'] = address1Controller.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['phone'] = phoneController.text.trim();
      request.fields['registration_number'] = registrationController.text.trim();

      // --- UPDATED PART: DATES (Send null) ---
      // Logic: In Multipart, we cannot send actual 'null'.
      // We must OMIT the key entirely so the backend treats it as null.

      if (dobController.text.isNotEmpty) {
        request.fields['date_of_birth'] = dobController.text;
      }

      if (anniversaryController.text.isNotEmpty) {
        request.fields['anniversary'] = anniversaryController.text;
      }
      // ----------------------------------------

      // Add Image
      if (doctorImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'geo_image',
          doctorImage.value!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // 3. CLOSE LOADER
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print('[DEBUG] Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Doctor Created Successfully",
            backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 2));

        if (Get.isRegistered<DoctorListController>()) {
          Get.find<DoctorListController>().fetchDoctorList();
        }

        await Future.delayed(const Duration(seconds: 2));

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        String errorMsg = "Failed to add doctor";
        try {
          var jsonBody = json.decode(response.body);
          if (jsonBody['message'] != null) errorMsg = jsonBody['message'];
        } catch (_) {}
        Get.snackbar("Error", errorMsg, backgroundColor: Colors.red, colorText: Colors.white);
      }

    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      print("[ERROR] Submit Exception: $e");
      Get.snackbar("Error", "An error occurred: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- Helper: Date Picker ---
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

  void showPincodeDialog() {
    final pinController = TextEditingController();

    final RxBool isLoading = false.obs;
    final RxString errorText = ''.obs;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 420,
            child: Obx(
                  () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Illustration
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_city,
                      size: 50,
                      color: TColors.primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Doctor Location Setup",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Enter doctor's area pincode. We will automatically fetch State, Post Office, Country and Address details.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.blue.shade100,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Address fields will be auto-filled after successful verification.",
                            style: TextStyle(fontSize: 13),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      letterSpacing: 6,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "201306",
                      counterText: "",
                      prefixIcon: const Icon(Icons.pin_drop),
                      errorText: errorText.value.isEmpty
                          ? null
                          : errorText.value,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isLoading.value
                          ? null
                          : () async {
                        final pin =
                        pinController.text.trim();

                        errorText.value = '';

                        if (pin.length != 6) {
                          errorText.value =
                          "Please enter valid pincode";
                          return;
                        }

                        isLoading.value = true;

                        final success =
                        await fetchAddressByPincode(
                          pin,
                        );

                        isLoading.value = false;

                        if (success) {
                          Get.back();

                          Get.snackbar(
                            "Address Verified",
                            "Location details fetched successfully",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } else {
                          errorText.value =
                          "Invalid pincode or no address found";
                        }
                      },
                      child: isLoading.value
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Verify & Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}