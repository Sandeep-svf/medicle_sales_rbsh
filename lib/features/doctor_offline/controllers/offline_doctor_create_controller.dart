import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import '../services/doctor_creation_store.dart';
import '../models/doctor.dart';
import '../../../utils/camera/CameraLocationResult.dart';
import '../../../utils/camera/image_overlay_utils.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../ui/doctor_location_picker.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class OfflineDoctorCreateController extends GetxController {
  OfflineDoctorCreateController(
      {required this.store, required this.cachedDoctors});
  final DoctorCreationStore store;
  final List<Doctor> cachedDoctors;
  final clinicNameController = TextEditingController();
  final locationController = TextEditingController();
  final landmarkController = TextEditingController();
  final saving = false.obs;
  final areaSearchController = TextEditingController();

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
  final areaNameController = TextEditingController();

  final blockController = TextEditingController();
  final districtController = TextEditingController();
  final divisionController = TextEditingController();

  // --- Observables ---
  final RxnString selectedGender = RxnString();
  var headOffices = <Map<String, String>>[].obs;
  var isLoadingHeadOffices = false.obs;
  var selectedHeadOfficeId = Rxn<String>();
  var areas = <Map<String, dynamic>>[].obs;
  var isLoadingAreas = false.obs;
  var selectedAreaId = Rxn<String>();
  final isOnline = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Stores all post offices for currently selected pincode
  final RxList<Map<String, dynamic>> postOfficeList =
      <Map<String, dynamic>>[].obs;

  /// Current selected post office
  final RxnString selectedPostOffice = RxnString();

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
    _startConnectivityMonitoring();
    fetchHeadOffices();
    fetchAreas();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_showPincodeIfOnline());
    });
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
          _applyConnectivity,
        );
    unawaited(_refreshConnectivity());
  }

  void _applyConnectivity(List<ConnectivityResult> results) {
    isOnline.value = results.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  Future<bool> _refreshConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _applyConnectivity(results);
      return isOnline.value;
    } catch (_) {
      // Treat an unknown network state as offline for area creation. Existing
      // cached areas remain safe to use in this case.
      isOnline.value = false;
      return false;
    }
  }

  Future<bool> ensureOnlineForAreaCreation() async {
    if (await _refreshConnectivity()) return true;
    Get.snackbar(
      'Internet required',
      TTexts.uiTextNewAreasCanBeCreatedOnlyOnlineSelect,
    );
    return false;
  }

  Future<void> _showPincodeIfOnline() async {
    try {
      if (await _refreshConnectivity()) {
        await showPincodeDialog();
      }
    } catch (_) {
      // If connectivity cannot be determined, keep manual entry available.
    }
  }

  // --- 1. FETCH HEAD OFFICES ---
  Future<void> fetchHeadOffices() async {
    isLoadingHeadOffices.value = true;
    try {
      final saved = await store.readLookup('headOffices');
      final fallback = <String, String>{};
      for (final d in cachedDoctors) {
        if (d.headOfficeId != null) {
          fallback[d.headOfficeId!] = d.headOfficeName ?? 'Head office';
        }
      }
      final assigned = await AuthManager().getHeadOffices();
      if (assigned != null) {
        for (final office in assigned) {
          if (office.id != null && office.name != null) {
            fallback[office.id!] = office.name!;
          }
        }
      }
      headOffices.assignAll(saved.isNotEmpty
          ? saved.map(
              (e) => {'id': e['id'].toString(), 'name': e['name'].toString()})
          : fallback.entries.map((e) => {'id': e.key, 'name': e.value}));
      if (headOffices.length == 1) {
        selectedHeadOfficeId.value = headOffices.first['id'];
      }
      final token = await AuthManager().getAuthToken();
      const String baseUrl = THttpHelper.baseUrl;

      final response = await http.get(
        Uri.parse('$baseUrl/users/my-head-offices'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> dataList = jsonResponse['data'];

          headOffices.assignAll(dataList
              .map((e) => {
                    'id': e['id'].toString(),
                    'name': e['name'].toString(),
                  })
              .toList());
          await store.saveLookup('headOffices', headOffices.toList());
          if (headOffices.length == 1) {
            selectedHeadOfficeId.value = headOffices.first['id'];
          }
        }
      }
    } catch (_) {
      // Keep locally available head offices when the server is unavailable.
    } finally {
      isLoadingHeadOffices.value = false;
    }
  }

  // fetch address by pincode
  Future<bool> fetchAddressByPincode(String pincode) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://api.postalpincode.in/pincode/$pincode',
            ),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        Get.snackbar(
          "Error",
          TTexts.uiTextUnableToFetchPincodeDetails,
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

      postOfficeList.assignAll(
        offices.map((e) => Map<String, dynamic>.from(e)).toList(),
      );

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
    selectedPostOffice.value = office['Name'];
    areaNameController.text = office['Name'] ?? '';

    postOfficeController.text = office['Name'] ?? '';

    blockController.text = office['Block'] ?? '';

    districtController.text = office['District'] ?? '';

    divisionController.text = office['Division'] ?? '';

    stateController.text = office['State'] ?? '';

    countryController.text = office['Country'] ?? '';

    pincodeController.text = pincode;

    /* address1Controller.text =
    "${office['Name']}, "
        "${office['Block'] ?? ''}, "
        "${office['District'] ?? ''}, "
        "${office['State'] ?? ''}, "
        "${office['Country'] ?? ''} - "
        "$pincode";*/

    autoSelectOrCreateArea(
      postOffice: office['Name'] ?? '',
      pincode: pincode,
    );
  }

  Future<void> showPostOfficeSelection(
    List offices,
    String pincode,
  ) async {
    int selectedIndex = 0;
    String search = "";

    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          final filtered = offices.where((office) {
            final text =
                "${office['Name']} ${office['Block']} ${office['District']}"
                    .toLowerCase();

            return text.contains(search.toLowerCase());
          }).toList();

          if (filtered.isEmpty) {
            selectedIndex = 0;
          } else if (selectedIndex >= filtered.length) {
            selectedIndex = 0;
          }

          return SafeArea(
            child: Container(
              height: Get.height * .82,
              decoration: const BoxDecoration(
                color: TColors.hex_FFF6F7FB,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: TSizes.v12),
                  Container(
                    width: TSizes.v70,
                    height: TSizes.v5,
                    decoration: BoxDecoration(
                      color: TColors.materialGrey400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: TSizes.v22),
                  Container(
                    height: TSizes.v70,
                    width: TSizes.v70,
                    decoration: BoxDecoration(
                      color: TColors.primary.withValues(alpha: .12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_city,
                      size: TSizes.v36,
                      color: TColors.primary,
                    ),
                  ),
                  const SizedBox(height: TSizes.v18),
                  const Text(
                    TTexts.uiTextSelectPostOffice,
                    style: TextStyle(
                      fontSize: TSizes.v24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: TSizes.v8),
                  Text(
                    TTexts.uiTextChooseTheCorrectPostOffice,
                    style: TextStyle(
                      color: TColors.materialGrey600,
                    ),
                  ),
                  const SizedBox(height: TSizes.v18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.materialGreen50,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: TColors.materialGreen200,
                      ),
                    ),
                    child: Text(
                      "${offices.length} Post Offices Available",
                      style: TextStyle(
                        color: TColors.materialGreen800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.v20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: TTexts.uiTextSearchPostOffice,
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: TColors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          search = v;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: TSizes.v15),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 18,
                          right: 18,
                          bottom: 100,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (_, index) {
                          final office = filtered[index];

                          final selected = selectedIndex == index;

                          return AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? TColors.primary.withValues(alpha: .08)
                                  : TColors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected
                                    ? TColors.primary
                                    : TColors.materialGrey200,
                                width: selected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      TColors.pureBlack.withValues(alpha: .04),
                                  blurRadius: TSizes.v10,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      height: TSizes.v28,
                                      width: TSizes.v28,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? TColors.materialGreen
                                            : TColors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: selected
                                              ? TColors.materialGreen
                                              : TColors.materialGrey,
                                        ),
                                      ),
                                      child: selected
                                          ? const Icon(
                                              Icons.check,
                                              color: TColors.white,
                                              size: TSizes.v18,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: TSizes.v16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            office['Name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: TSizes.v16,
                                            ),
                                          ),

                                          /* const SizedBox(
                                              height: 4),

                                          Text(
                                            office['BranchType'] ??
                                                '',
                                            style:
                                            TextStyle(
                                              color: TColors.materialGrey700,
                                            ),
                                          ),*/

                                          const SizedBox(height: TSizes.v6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: TSizes.v15,
                                                color: TColors.materialRed,
                                              ),
                                              const SizedBox(width: TSizes.v4),
                                              Expanded(
                                                child: Text(
                                                  "${office['Block']} • ${office['District']}",
                                                  style: TextStyle(
                                                    color:
                                                        TColors.materialGrey600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: TSizes.v6),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: TColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: TColors.pureBlack.withValues(alpha: .08),
                          blurRadius: TSizes.v20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: Get.back,
                            child: const Text(TTexts.cancel),
                          ),
                        ),
                        const SizedBox(width: TSizes.v14),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: TColors.white,
                              minimumSize: const Size.fromHeight(55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text(TTexts.uiTextContinue),
                            onPressed: () {
                              fillAddress(
                                Map<String, dynamic>.from(
                                  filtered[selectedIndex],
                                ),
                                pincode,
                              );

                              Get.back();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: TColors.transparent,
    );
  }

  Future<bool> createArea({
    required String name,
    required String pincode,
    required String postOffice,
  }) async {
    if (!await ensureOnlineForAreaCreation()) return false;

    try {
      final token = await AuthManager().getAuthToken();

      final response = await http
          .post(
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
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        final createdAreaId = jsonResponse['data']?['id']?.toString();
        if (createdAreaId == null || createdAreaId.isEmpty) {
          Get.snackbar('Error', TTexts.uiTextTheServerDidNotReturnAnAreaID);
          return false;
        }

        await fetchAreas();

        selectedAreaId.value = createdAreaId;
        areaNameController.text = name.trim();

        Get.snackbar(
          "Success",
          TTexts.uiTextAreaCreated,
          backgroundColor: TColors.materialGreen,
          colorText: TColors.white,
        );
        return true;
      } else {}
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
    return false;
  }

  // New Added
  Future<void> fetchAreas() async {
    isLoadingAreas.value = true;
    try {
      final saved = await store.readLookup('areas');
      final fallback = <String, Map<String, dynamic>>{};
      for (final d in cachedDoctors) {
        if (d.areaId != null) {
          fallback[d.areaId!] = {'id': d.areaId, 'name': d.areaName ?? 'Area'};
        }
      }
      areas.assignAll(saved.isNotEmpty ? saved : fallback.values.toList());
      if (!await _refreshConnectivity()) return;
      final token = await AuthManager().getAuthToken();
      final response = await http.get(Uri.parse('${THttpHelper.baseUrl}/areas'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          areas.assignAll(List<Map<String, dynamic>>.from(body['data']));
          await store.saveLookup('areas', areas.toList());
        }
      }
    } catch (_) {
      // Cached choices remain available without a network connection.
    } finally {
      isLoadingAreas.value = false;
    }
  }

  void selectExistingArea(Map<String, dynamic> area) {
    final id = (area['id'] ?? area['_id'])?.toString().trim();
    final name = area['name']?.toString().trim();
    if (id == null || id.isEmpty || name == null || name.isEmpty) return;
    selectedAreaId.value = id;
    areaNameController.text = name;
  }

  Future<void> submit(BuildContext context) async {
    if (saving.value || !(formKey.currentState?.validate() ?? false)) return;
    if (selectedHeadOfficeId.value == null || selectedGender.value == null) {
      Get.snackbar('Required', TTexts.uiTextSelectHeadOfficeAndGender);
      return;
    }
    if (doctorImage.value == null || !isLocationSet.value) {
      Get.snackbar('Required', TTexts.uiTextCaptureAPhotoAndSelectTheLocation);
      return;
    }
    if (selectedAreaId.value == null ||
        areaNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Area required',
        TTexts.uiTextSelectAnExistingAreaNewAreasCanBe,
      );
      return;
    }
    saving.value = true;
    try {
      final user = await AuthManager().getUserData();
      final name = nameController.text.trim();
      final selectedAreaName = areaNameController.text.trim();
      final body = <String, dynamic>{
        'name': name.toUpperCase().startsWith('DR.') ? name : 'DR. $name',
        'specialization': specializationController.text.trim(),
        'clinic_name': clinicNameController.text.trim(),
        'clinic_address': [
          address1Controller.text,
          address2Controller.text,
          landmarkController.text,
          blockController.text,
          districtController.text,
          divisionController.text,
          stateController.text,
          pincodeController.text,
          countryController.text
        ].map((v) => v.trim()).where((v) => v.isNotEmpty).join(', '),
        'location': locationController.text.trim(),
        'latitude': latitude.value,
        'longitude': longitude.value,
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'priority': selectedPriority.value,
        'headOfficeId': selectedHeadOfficeId.value,
        'areaId': selectedAreaId.value,
        'areaName': selectedAreaName,
        'created_by_name': user?.user?.name ?? '',
        'gender': selectedGender.value,
        if (registrationController.text.trim().isNotEmpty)
          'registration_number': registrationController.text.trim(),
        if (experienceController.text.trim().isNotEmpty)
          'years_of_experience': int.parse(experienceController.text.trim()),
        if (dobController.text.isNotEmpty) 'date_of_birth': dobController.text,
        if (anniversaryController.text.isNotEmpty)
          'anniversary': anniversaryController.text,
      };
      await store.save(
          payload: body,
          image: doctorImage.value!,
          headOfficeName: headOffices.firstWhereOrNull(
              (e) => e['id'] == selectedHeadOfficeId.value)?['name'],
          areaName: selectedAreaName);
      if (context.mounted) Navigator.of(context).pop(true);
    } catch (_) {
      Get.snackbar('Could not save',
          TTexts.uiTextPleaseCheckTheFieldsPhotoAndAvailableDevice);
    } finally {
      saving.value = false;
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
            dialogTheme: const DialogThemeData(backgroundColor: TColors.white),
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
      final CameraLocationResult? result =
          await CameraLocationService.captureImageWithLocation();
      if (result == null) return;

      final File layeredImage = await ImageOverlayUtil.addOverlay(
        original: result.image,
        lat: result.latitude,
        lng: result.longitude,
      );

      doctorImage.value = layeredImage;
      latitude.value = result.latitude;
      longitude.value = result.longitude;
      isLocationSet.value = true;
      imageCapturedAt.value = DateTime.now();
    } catch (e) {
      Get.snackbar("Error", "$e",
          backgroundColor: TColors.materialRed, colorText: TColors.white);
    } finally {
      isImageProcessing.value = false;
    }
  }

  // --- Helper: Location Picker ---
  Future<void> pickLocationOnMap() async {
    final result = await Get.to(() => const OfflineDoctorLocationPicker());
    if (result != null && result is Map<String, dynamic>) {
      latitude.value = result['latitude'] ?? 0.0;
      longitude.value = result['longitude'] ?? 0.0;
      // address1Controller.text = result['address'] ?? '';

      if (result.containsKey('state')) {
        stateController.text = result['state'] ?? '';
      }
      if (result.containsKey('pincode')) {
        pincodeController.text = result['pincode'] ?? '';
      }
      if (result.containsKey('country')) {
        countryController.text = result['country'] ?? '';
      }
      if (result.containsKey('postOffice')) {
        postOfficeController.text = result['postOffice'] ?? '';
      }

      isLocationSet.value = true;
      Get.snackbar("Location Fetched", TTexts.uiTextCoordinatesSet,
          backgroundColor: TColors.materialGreen.withValues(alpha: 0.9),
          colorText: TColors.white);
    }
  }

  Future<void> autoSelectOrCreateArea({
    required String postOffice,
    required String pincode,
  }) async {
    // Wait if areas are still loading
    if (isLoadingAreas.value) {
      while (isLoadingAreas.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    final existingArea = areas.firstWhereOrNull(
      (e) =>
          (e['name'] ?? '').toString().trim().toLowerCase() ==
          postOffice.trim().toLowerCase(),
    );

    if (existingArea != null) {
      selectExistingArea(existingArea);
      return;
    }

    // Area doesn't exist -> create it
    await createArea(
      name: postOffice,
      pincode: pincode,
      postOffice: postOffice,
    );
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    areaSearchController.dispose();
    areaNameController.dispose();
    clinicNameController.dispose();
    locationController.dispose();
    landmarkController.dispose();
    blockController.dispose();
    districtController.dispose();
    divisionController.dispose();
    nameController.dispose();
    specializationController.dispose();
    emailController.dispose();
    phoneController.dispose();
    registrationController.dispose();
    experienceController.dispose();
    dobController.dispose();
    anniversaryController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
    postOfficeController.dispose();
    super.onClose();
  }

  Future<void> showPincodeDialog() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (!results.any((result) => result != ConnectivityResult.none)) {
        return;
      }
    } catch (_) {
      return;
    }
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
            width: TSizes.v420,
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          TTexts.uiTextDoctorLocationSetup,
                          style: TextStyle(
                            fontSize: TSizes.v22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: TColors.materialGrey200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: TSizes.v20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: TSizes.v20),

                  /// Illustration
                  Container(
                    height: TSizes.v90,
                    width: TSizes.v90,
                    decoration: BoxDecoration(
                      color: TColors.primary.withValues(alpha: .10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_city,
                      size: TSizes.v50,
                      color: TColors.primary,
                    ),
                  ),

                  const SizedBox(height: TSizes.v20),

                  Text(
                    TTexts.uiTextEnterDoctorSAreaPincodeWeWillAutomatically,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColors.materialGrey600,
                      height: TSizes.v1_5,
                    ),
                  ),

                  const SizedBox(height: TSizes.v20),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TColors.materialBlue50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: TColors.materialBlue100,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: TColors.materialBlue,
                        ),
                        SizedBox(width: TSizes.v10),
                        Expanded(
                          child: Text(
                            TTexts
                                .uiTextAddressFieldsWillBeAutoFilledAfterSuccessful,
                            style: TextStyle(fontSize: TSizes.v13),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: TSizes.v20),

                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: TSizes.v22,
                      letterSpacing: 6,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: TTexts.uiText201306,
                      hintStyle: TextStyle(
                        color: TColors.materialGrey400,
                        fontSize: TSizes.v18,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                      counterText: "",
                      prefixIcon: const Icon(Icons.pin_drop),
                      errorText:
                          errorText.value.isEmpty ? null : errorText.value,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: TSizes.v20),

                  SizedBox(
                    width: double.infinity,
                    height: TSizes.v54,
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
                              final pin = pinController.text.trim();

                              errorText.value = '';

                              if (pin.length != 6) {
                                errorText.value = "Please enter valid pincode";
                                return;
                              }

                              isLoading.value = true;

                              final success = await fetchAddressByPincode(pin);

                              isLoading.value = false;

                              if (success) {
                                Get.back();

                                Get.snackbar(
                                  "Address Verified",
                                  TTexts
                                      .uiTextLocationDetailsFetchedSuccessfully,
                                  backgroundColor: TColors.materialGreen,
                                  colorText: TColors.white,
                                );
                              } else {
                                errorText.value =
                                    "Invalid pincode or no address found";
                              }
                            },
                      child: isLoading.value
                          ? const SizedBox(
                              height: TSizes.v22,
                              width: TSizes.v22,
                              child: CircularProgressIndicator(
                                strokeWidth: TSizes.v2,
                                color: TColors.white,
                              ),
                            )
                          : const Text(
                              TTexts.uiTextVerifyContinue,
                              style: TextStyle(
                                fontSize: TSizes.v16,
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
