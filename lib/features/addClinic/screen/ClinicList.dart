import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/features/addClinic/model/Cilinic_Test_Model.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import '../controllers/ClinicListController.dart';
import '../model/clinic.dart';
import 'ClinicDetailsScreen.dart';
import 'AddClinicScreen.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class ClinicListScreen extends StatefulWidget {
  const ClinicListScreen({super.key});

  @override
  State<ClinicListScreen> createState() => _ClinicListScreenState();
}

class _ClinicListScreenState extends State<ClinicListScreen> {
  final ClinicListController _clinicListController =
      Get.put(ClinicListController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _clinicListController.fetchClinicList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // --- SEARCH BAR (Matches Doctor Screen) ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: TTexts.uiTextSearchChemist, // TTexts.searchChemist
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search, color: TColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // --- LIST CONTENT ---
          Expanded(
            child: Obx(() {
              if (_clinicListController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredClinics =
                  _clinicListController.clinicList.where((clinic) {
                return clinic.firmName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
              }).toList();

              if (filteredClinics.isEmpty) {
                return const Center(
                    child: Text(TTexts.uiTextNoChemistAvailable));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  // Breakpoints (Same as Doctor)
                  final bool isMobile = width < 600;
                  final bool isTabletPortrait = width >= 600 && width < 900;

                  // --- CARD BUILDER FUNCTION (Matches buildDoctorCard) ---
                  Widget buildClinicCard(Clinic clinic,
                      {required bool isTablet}) {
                    // Initials
                    final String initials = clinic.firmName.trim().isNotEmpty
                        ? clinic.firmName.trim()[0].toUpperCase()
                        : "?";

                    const Color themeColor = TColors.primary;

                    // Map Validation
                    final double? lat = double.tryParse(clinic.latitude);
                    final double? lng = double.tryParse(clinic.longitude);
                    final bool isValidMap =
                        lat != null && lng != null && lat != 0 && lng != 0;

                    // --- Inner Content Widget ---
                    Widget cardContent = Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left strip (Same as Doctor)
                        Container(width: TSizes.v5, color: themeColor),

                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ================= HEADER =================
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.04),
                                  border: Border(
                                    bottom: BorderSide(
                                        color: TColors.materialGrey100),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: themeColor.withOpacity(0.3),
                                          width: TSizes.v2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: TSizes.v24,
                                        backgroundColor: TColors.white,
                                        child: Text(
                                          initials,
                                          style: const TextStyle(
                                            fontSize: TSizes.v20,
                                            fontWeight: FontWeight.bold,
                                            color: themeColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: TSizes.v12),

                                    // Name & Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            clinic.firmName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: TSizes.v16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: TSizes.v6),

                                          (clinic.areaId ?? '').trim().isEmpty
                                              ? GestureDetector(
                                                  onTap: () =>
                                                      _showAssignAreaSheet(
                                                          clinic),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: TColors
                                                          .materialAmber
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      border: Border.all(
                                                        color: TColors
                                                            .materialAmber700
                                                            .withOpacity(0.4),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .add_location_alt_outlined,
                                                          size: TSizes.v12,
                                                          color: TColors
                                                              .materialAmber900,
                                                        ),
                                                        const SizedBox(
                                                            width: TSizes.v4),
                                                        Text(
                                                          TTexts
                                                              .uiTextAddAreaMissing,
                                                          style: TextStyle(
                                                            fontSize:
                                                                TSizes.v10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: TColors
                                                                .materialAmber900,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: TColors.materialGreen
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                      color: TColors
                                                          .materialGreen
                                                          .withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.pin_drop,
                                                        size: TSizes.v12,
                                                        color: TColors
                                                            .materialGreen,
                                                      ),
                                                      const SizedBox(
                                                          width: TSizes.v4),
                                                      Text(
                                                        clinic.area?.name ??
                                                            "Area Assigned",
                                                        style: const TextStyle(
                                                          fontSize: TSizes.v10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: TColors
                                                              .materialGreen,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                          const SizedBox(height: TSizes.v4),
                                          // Contact Person (Replaces Specialization)
                                          Text(
                                            clinic.contactPersonName,
                                            style: TextStyle(
                                              fontSize: TSizes.v13,
                                              fontWeight: FontWeight.w600,
                                              color: TColors.materialGrey800,
                                            ),
                                          ),
                                          const SizedBox(height: TSizes.v4),
                                          // Address (Replaces Location)
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_rounded,
                                                  size: TSizes.v12,
                                                  color:
                                                      TColors.materialGrey600),
                                              const SizedBox(width: TSizes.v4),
                                              Expanded(
                                                child: Text(
                                                  clinic.address,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: TSizes.v12,
                                                      color: TColors
                                                          .materialGrey600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ================= BODY =================
                              _buildBodyContent(context, clinic, isValidMap,
                                  themeColor, isTablet),
                            ],
                          ),
                        ),
                      ],
                    );

                    // Container Wrapper
                    return Container(
                      decoration: BoxDecoration(
                        color: TColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: themeColor.withOpacity(0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.pureBlack.withOpacity(0.05),
                            blurRadius: TSizes.v12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      // IntrinsicHeight ensures the Row stretches correctly in ListView
                      child: isTablet
                          ? cardContent
                          : IntrinsicHeight(child: cardContent),
                    );
                  }

                  // --- Layout Selection (Matches Doctor Logic) ---
                  if (isMobile) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredClinics.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: buildClinicCard(filteredClinics[i],
                            isTablet: false),
                      ),
                    );
                  } else {
                    // Tablet Grid Configuration
                    final int crossAxisCount = isTabletPortrait ? 2 : 3;
                    // final double ratio = isTabletPortrait ? 1.3 : 1.2;
                    final double ratio = isTabletPortrait ? 1.05 : 1.0;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: TSizes.v16,
                        mainAxisSpacing: TSizes.v16,
                        childAspectRatio: ratio,
                      ),
                      itemCount: filteredClinics.length,
                      itemBuilder: (_, i) =>
                          buildClinicCard(filteredClinics[i], isTablet: true),
                    );
                  }
                },
              );
            }),
          )
        ],
      ),

      // --- FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => const AddChemistScreen());
          if (result == true) {
            _clinicListController.fetchClinicList();
          }
        },
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: TColors.white),
      ),
    );
  }

  // --- BODY CONTENT BUILDER (Matches Doctor Logic) ---
  Widget _buildBodyContent(BuildContext context, Clinic clinic, bool isValidMap,
      Color themeColor, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info Row
          Row(
            children: [
              Icon(Icons.history,
                  size: TSizes.v16, color: TColors.materialGrey700),
              const SizedBox(width: TSizes.v6),
              Text(
                "${clinic.yearsInBusiness} Years Exp.", // Years in Business
                style: const TextStyle(
                  fontSize: TSizes.v13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Mobile No Badge (Instead of Gender)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TColors.materialGrey100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone,
                        size: TSizes.v12, color: TColors.materialGrey700),
                    const SizedBox(width: TSizes.v4),
                    Text(
                      clinic.mobileNo,
                      style: TextStyle(
                        fontSize: TSizes.v11,
                        fontWeight: FontWeight.w600,
                        color: TColors.materialGrey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /* if ((clinic.areaId ?? '').trim().isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColors.materialOrange50,
                borderRadius:
                BorderRadius.circular(12),
                border: Border.all(
                  color: TColors.materialOrange200,
                ),
              ),
              child: Row(
                children: [

                  const Icon(
                    Icons.warning_amber_rounded,
                    color: TColors.materialOrange,
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Text(
                      "Area not assigned",
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      _showAssignAreaSheet(
                        clinic,
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 16,
                    ),
                    label: const Text(
                      "Add Area",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ]
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColors.materialGreen50,
                borderRadius:
                BorderRadius.circular(12),
                border: Border.all(
                  color: TColors.materialGreen200,
                ),
              ),
              child: Row(
                children: [

                  const Icon(
                    Icons.check_circle,
                    color: TColors.materialGreen,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      clinic.area?.name ??
                          'Area Assigned',
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],*/

          const SizedBox(height: TSizes.v16),

          // View Profile Button
          SizedBox(
            width: double.infinity,
            height: TSizes.v40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ClinicDetailScreen(clinic: clinic)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                TTexts.uiTextViewProfile,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: TColors.white),
              ),
            ),
          ),

          // Map Button (Only if valid)
          if (isValidMap) ...[
            const SizedBox(height: TSizes.v8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ClinicDetailScreen(clinic: clinic)),
                  );
                },
                icon: const Icon(Icons.map_outlined, size: TSizes.v18),
                label: const Text(
                  TTexts.uiTextLocateOnMap,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: themeColor.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAssignAreaSheet(
    Clinic clinic,
  ) async {
    final areas = await _clinicListController.fetchAreas();

    final searchController = TextEditingController();

    List<dynamic> filteredAreas = List.from(areas);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: Get.height * .80,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  TTexts.uiTextAssignArea,
                  style: TextStyle(
                    fontSize: TSizes.v22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: TSizes.v16),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: TTexts.uiTextSearchArea,
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredAreas = areas
                          .where(
                            (area) => (area["name"] ?? "")
                                .toString()
                                .toLowerCase()
                                .contains(
                                  value.toLowerCase(),
                                ),
                          )
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: TSizes.v16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredAreas.length,
                    itemBuilder: (_, index) {
                      final area = filteredAreas[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                        ),
                        title: Text(
                          area["name"] ?? "",
                        ),
                        subtitle: Text(
                          area["pincode"] ?? "",
                        ),
                        onTap: () async {
                          Get.back();

                          await _clinicListController.assignAreaToChemist(
                            chemistId: clinic.id,
                            areaId: area["id"],
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.add,
                    ),
                    label: const Text(
                      TTexts.uiTextCreateNewArea,
                    ),
                    onPressed: () {
                      Get.back();

                      _showAddAreaDialog(
                        clinic,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showAddAreaDialog(
    Clinic doctor,
  ) {
    final pinController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: TSizes.v90,
                width: TSizes.v90,
                decoration: BoxDecoration(
                  color: TColors.materialBlue50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_searching,
                  size: TSizes.v50,
                  color: TColors.primary,
                ),
              ),
              const SizedBox(height: TSizes.v20),
              const Text(
                TTexts.uiTextCreateNewArea,
                style: TextStyle(
                  fontSize: TSizes.v24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: TSizes.v8),
              Text(
                TTexts.uiTextEnterPincodeAndWeLlAutomaticallyFetchAll,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColors.materialGrey600,
                  height: TSizes.v1_4,
                ),
              ),
              const SizedBox(height: TSizes.v20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TColors.materialBlue50,
                  borderRadius: BorderRadius.circular(14),
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
                        TTexts.uiTextNoNeedToEnterPostOfficeManuallyWe,
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
                  fontSize: TSizes.v24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: TTexts.uiText201306,
                  prefixIcon: const Icon(
                    Icons.pin_drop,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.v20),
              SizedBox(
                width: double.infinity,
                height: TSizes.v55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text(
                    TTexts.uiTextVerifyFetchAreas,
                    style: TextStyle(
                      fontSize: TSizes.v16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    final pin = pinController.text.trim();

                    if (pin.length != 6) {
                      Get.snackbar(
                        "Invalid Pincode",
                        TTexts.uiTextPleaseEnterAValid6DigitPincode,
                      );
                      return;
                    }

                    final response = await http.get(
                      Uri.parse(
                        "https://api.postalpincode.in/pincode/$pin",
                      ),
                    );

                    final data = jsonDecode(response.body);

                    if (data.isEmpty ||
                        data[0]['Status'] != 'Success' ||
                        data[0]['PostOffice'] == null) {
                      Get.snackbar(
                        "Error",
                        TTexts.uiTextInvalidPincode,
                      );
                      return;
                    }

                    final offices = data[0]['PostOffice'];

                    Get.back();

                    _showAreaSelectionSheet(
                      doctor,
                      pin,
                      offices,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAreaSelectionSheet(
    Clinic doctor,
    String pincode,
    List offices,
  ) {
    int selectedIndex = 0;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  TTexts.uiTextSelectArea,
                  style: TextStyle(
                    fontSize: TSizes.v20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: TSizes.v20),
                SizedBox(
                  height: TSizes.v300,
                  child: ListView.builder(
                    itemCount: offices.length,
                    itemBuilder: (_, index) {
                      final office = offices[index];

                      return RadioListTile<int>(
                        value: index,
                        groupValue: selectedIndex,
                        title: Text(
                          office['Name'],
                        ),
                        subtitle: Text(
                          office['Block'] ?? '',
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text(
                      TTexts.uiTextContinue,
                    ),
                    onPressed: () {
                      Get.back();

                      final office = offices[selectedIndex];

                      _showCreateAreaForm(
                        doctor,
                        office,
                        pincode,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateAreaForm(
    Clinic doctor,
    Map office,
    String pincode,
  ) {
    final areaController = TextEditingController(
      text: office['Name'],
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(
            maxWidth: TSizes.v500,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: TSizes.v90,
                  width: TSizes.v90,
                  decoration: BoxDecoration(
                    color: TColors.materialGreen50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_city,
                    color: TColors.materialGreen,
                    size: TSizes.v50,
                  ),
                ),
                const SizedBox(height: TSizes.v20),
                const Text(
                  TTexts.uiTextConfirmNewArea,
                  style: TextStyle(
                    fontSize: TSizes.v24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: TSizes.v8),
                Text(
                  TTexts.uiTextReviewTheDetectedAreaInformationBeforeCreatingIt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColors.materialGrey600,
                  ),
                ),
                const SizedBox(height: TSizes.v24),
                TextField(
                  controller: areaController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: TTexts.uiTextAreaName,
                    prefixIcon: const Icon(Icons.edit_location_alt),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.v20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TColors.materialGrey50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: TColors.materialGrey300,
                    ),
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        Icons.pin_drop,
                        "Pincode",
                        pincode,
                      ),
                      const Divider(),
                      _infoRow(
                        Icons.local_post_office,
                        "Post Office",
                        office['Name'] ?? '',
                      ),
                      const Divider(),
                      _infoRow(
                        Icons.location_city,
                        "Block",
                        office['Block'] ?? '-',
                      ),
                      const Divider(),
                      _infoRow(
                        Icons.map,
                        "District",
                        office['District'] ?? '-',
                      ),
                      const Divider(),
                      _infoRow(
                        Icons.flag,
                        "State",
                        office['State'] ?? '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.v24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          TTexts.cancel,
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.v12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.check_circle,
                        ),
                        label: const Text(
                          TTexts.uiTextCreateArea,
                        ),
                        onPressed: () async {
                          final createdAreaId =
                              await _clinicListController.createNewArea(
                            name: areaController.text.trim(),
                            pincode: pincode,
                            postOffice: office['Name'],
                            headOfficeId: doctor.headOfficeId,
                          );

                          if (createdAreaId != null) {
                            await _clinicListController.assignAreaToChemist(
                              chemistId: doctor.id,
                              areaId: createdAreaId,
                            );

                            Get.back();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: TSizes.v18,
          color: TColors.primary,
        ),
        const SizedBox(width: TSizes.v10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
