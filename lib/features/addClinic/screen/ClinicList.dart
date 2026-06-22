import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/features/addClinic/model/Cilinic_Test_Model.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/text_strings.dart'; // Ensure this exists
import '../controllers/ClinicListController.dart';
import '../model/clinic.dart';
import 'ClinicDetailsScreen.dart';
import 'AddClinicScreen.dart'; // Points to your AddChemistScreen

class ClinicListScreen extends StatefulWidget {
  const ClinicListScreen({super.key});

  @override
  State<ClinicListScreen> createState() => _ClinicListScreenState();
}

class _ClinicListScreenState extends State<ClinicListScreen> {
  final ClinicListController _clinicListController = Get.put(ClinicListController());
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
                labelText: "Search Chemist", // TTexts.searchChemist
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

              final filteredClinics = _clinicListController.clinicList.where((clinic) {
                return clinic.firmName.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              if (filteredClinics.isEmpty) {
                return const Center(child: Text("No chemist available"));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  // Breakpoints (Same as Doctor)
                  final bool isMobile = width < 600;
                  final bool isTabletPortrait = width >= 600 && width < 900;

                  // --- CARD BUILDER FUNCTION (Matches buildDoctorCard) ---
                  Widget buildClinicCard(Clinic clinic, {required bool isTablet}) {
                    // Initials
                    final String initials = clinic.firmName.trim().isNotEmpty
                        ? clinic.firmName.trim()[0].toUpperCase()
                        : "?";

                    const Color themeColor = TColors.primary;

                    // Map Validation
                    final double? lat = double.tryParse(clinic.latitude);
                    final double? lng = double.tryParse(clinic.longitude);
                    final bool isValidMap = lat != null && lng != null && lat != 0 && lng != 0;

                    // --- Inner Content Widget ---
                    Widget cardContent = Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left strip (Same as Doctor)
                        Container(width: 5, color: themeColor),

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
                                    bottom: BorderSide(color: Colors.grey.shade100),
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
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.white,
                                        child: Text(
                                          initials,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: themeColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Name & Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            clinic.firmName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          (clinic.areaId ?? '').trim().isEmpty
                                              ? GestureDetector(
                                            onTap: () => _showAssignAreaSheet(clinic),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: Colors.amber.shade700.withOpacity(0.4),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.add_location_alt_outlined,
                                                    size: 12,
                                                    color: Colors.amber.shade900,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Add Area Missing",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.amber.shade900,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                              : Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: Colors.green.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.pin_drop,
                                                  size: 12,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  clinic.area?.name ?? "Area Assigned",
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 4),
                                          // Contact Person (Replaces Specialization)
                                          Text(
                                            clinic.contactPersonName,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Address (Replaces Location)
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_rounded, size: 12, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  clinic.address,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                              _buildBodyContent(context, clinic, isValidMap, themeColor, isTablet),
                            ],
                          ),
                        ),
                      ],
                    );

                    // Container Wrapper
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: themeColor.withOpacity(0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      // IntrinsicHeight ensures the Row stretches correctly in ListView
                      child: isTablet ? cardContent : IntrinsicHeight(child: cardContent),
                    );
                  }

                  // --- Layout Selection (Matches Doctor Logic) ---
                  if (isMobile) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredClinics.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: buildClinicCard(filteredClinics[i], isTablet: false),
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
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: ratio,
                      ),
                      itemCount: filteredClinics.length,
                      itemBuilder: (_, i) => buildClinicCard(filteredClinics[i], isTablet: true),
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- BODY CONTENT BUILDER (Matches Doctor Logic) ---
  Widget _buildBodyContent(BuildContext context, Clinic clinic, bool isValidMap, Color themeColor, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info Row
          Row(
            children: [
              Icon(Icons.history, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                "${clinic.yearsInBusiness} Years Exp.", // Years in Business
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Mobile No Badge (Instead of Gender)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 12, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      clinic.mobileNo,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
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
                color: Colors.orange.shade50,
                borderRadius:
                BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [

                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
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
                color: Colors.green.shade50,
                borderRadius:
                BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [

                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
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

          const SizedBox(height: 16),

          // View Profile Button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ClinicDetailScreen(clinic: clinic)),
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
                "View Profile",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),

          // Map Button (Only if valid)
          if (isValidMap) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ClinicDetailScreen(clinic: clinic)),
                  );
                },
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text(
                  "Locate on Map",
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

    final areas =
    await _clinicListController
        .fetchAreas();

    final searchController =
    TextEditingController();

    List<dynamic> filteredAreas =
    List.from(areas);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: Get.height * .80,
            padding:
            const EdgeInsets.all(16),
            decoration:
            const BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [

                const Text(
                  "Assign Area",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller:
                  searchController,
                  decoration:
                  InputDecoration(
                    hintText:
                    "Search Area",
                    prefixIcon:
                    const Icon(
                      Icons.search,
                    ),
                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredAreas =
                          areas
                              .where(
                                (area) =>
                                (area["name"] ??
                                    "")
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                  value
                                      .toLowerCase(),
                                ),
                          )
                              .toList();
                    });
                  },
                ),

                const SizedBox(height: 16),

                Expanded(
                  child:
                  ListView.builder(
                    itemCount:
                    filteredAreas.length,
                    itemBuilder:
                        (_, index) {

                      final area =
                      filteredAreas[
                      index];

                      return ListTile(
                        leading:
                        const Icon(
                          Icons.location_on,
                        ),
                        title: Text(
                          area["name"] ??
                              "",
                        ),
                        subtitle: Text(
                          area["pincode"] ??
                              "",
                        ),
                        onTap: () async {

                          Get.back();

                          await _clinicListController
                              .assignAreaToChemist(
                            chemistId:
                            clinic.id,
                            areaId:
                            area["id"],
                          );
                        },
                      );
                    },
                  ),
                ),

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  ElevatedButton.icon(
                    icon:
                    const Icon(
                      Icons.add,
                    ),
                    label:
                    const Text(
                      "Create New Area",
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
      ){
    final pinController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_searching,
                  size: 50,
                  color: TColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Create New Area",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Enter pincode and we'll automatically fetch all available areas and post offices.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
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
                        "No need to enter Post Office manually. We will fetch it automatically.",
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "201306",
                  prefixIcon: const Icon(
                    Icons.pin_drop,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text(
                    "Verify & Fetch Areas",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {

                    final pin =
                    pinController.text.trim();

                    if (pin.length != 6) {
                      Get.snackbar(
                        "Invalid Pincode",
                        "Please enter a valid 6 digit pincode",
                      );
                      return;
                    }

                    final response = await http.get(
                      Uri.parse(
                        "https://api.postalpincode.in/pincode/$pin",
                      ),
                    );

                    final data =
                    jsonDecode(response.body);

                    if (data.isEmpty ||
                        data[0]['Status'] !=
                            'Success' ||
                        data[0]['PostOffice'] ==
                            null) {
                      Get.snackbar(
                        "Error",
                        "Invalid Pincode",
                      );
                      return;
                    }

                    final offices =
                    data[0]['PostOffice'];

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
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "Select Area",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: offices.length,
                    itemBuilder: (_, index) {
                      final office =
                      offices[index];

                      return RadioListTile<int>(
                        value: index,
                        groupValue:
                        selectedIndex,
                        title: Text(
                          office['Name'],
                        ),
                        subtitle: Text(
                          office['Block'] ??
                              '',
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedIndex =
                            value!;
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
                      "Continue",
                    ),
                    onPressed: () {
                      Get.back();

                      final office =
                      offices[selectedIndex];

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
            maxWidth: 500,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_city,
                    color: Colors.green,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Confirm New Area",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Review the detected area information before creating it.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: areaController,
                  decoration: InputDecoration(
                    labelText: "Area Name",
                    prefixIcon:
                    const Icon(Icons.edit_location_alt),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius:
                    BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
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

                const SizedBox(height: 24),

                Row(
                  children: [

                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          "Cancel",
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.check_circle,
                        ),
                        label: const Text(
                          "Create Area",
                        ),
                          onPressed: () async {

                            final createdAreaId =
                            await _clinicListController
                                .createNewArea(
                              name: areaController.text.trim(),
                              pincode: pincode,
                              postOffice: office['Name'],
                              headOfficeId: doctor.headOfficeId,
                            );

                            if (createdAreaId != null) {

                              await _clinicListController
                                  .assignAreaToChemist(
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
          size: 18,
          color: TColors.primary,
        ),
        const SizedBox(width: 10),
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