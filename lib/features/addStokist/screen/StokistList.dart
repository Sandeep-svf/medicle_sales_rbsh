import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../controllers/StokistListController.dart';
import '../widets/AddStokistDialog.dart';
import 'AddStokist.dart';
import 'StokistDetailsScreen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../controllers/StokistListController.dart';
import '../model/Stokist.dart';
import 'AddStokist.dart';
import 'StokistDetailsScreen.dart';

class StokistListScreen extends StatefulWidget {
  const StokistListScreen({Key? key}) : super(key: key);

  @override
  State<StokistListScreen> createState() => _StokistListScreenState();
}

class _StokistListScreenState extends State<StokistListScreen> {
  final StokistListController _stokistController = Get.put(StokistListController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Stockist Directory", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () => _stokistController.fetchStokist(),
          )
        ],
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Stockists",
                hintText: "Search by Firm Name or Contact Person...",
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

          // --- Content List ---
          Expanded(
            child: Obx(() {
              if (_stokistController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filter Logic
              final filteredStockists = _stokistController.stokistList.where((stockist) {
                final query = _searchQuery.toLowerCase();
                final name = stockist.firmName?.toLowerCase() ?? '';
                final person = stockist.contactPerson?.toLowerCase() ?? '';
                final address = stockist.registeredOfficeAddress?.toLowerCase() ?? '';

                return name.contains(query) || person.contains(query) || address.contains(query);
              }).toList();

              if (filteredStockists.isEmpty) {
                return _buildEmptyState();
              }

              // --- Layout Builder for Responsiveness ---
              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  // Breakpoints matching your reference
                  final bool isMobile = width < 600;
                  final bool isTabletPortrait = width >= 600 && width < 900;

                  // --- Card Builder Helper ---
                  Widget buildStockistCard(Stockist stockist, {required bool isTablet}) {
                    // Initials
                    final String initials = (stockist.firmName != null && stockist.firmName!.isNotEmpty)
                        ? stockist.firmName!.trim()[0].toUpperCase()
                        : "S";

                    // Theme Color
                    const Color themeColor = TColors.primary;

                    // Map Validation
                    final double? lat = double.tryParse(stockist.latitude ?? "");
                    final double? lng = double.tryParse(stockist.longitude ?? "");
                    final bool isValidMap = lat != null && lng != null && lat != 0 && lng != 0;

                    // --- Inner Card Content ---
                    Widget cardContent = Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Colored Strip
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
                                            stockist.firmName ?? "Unknown Firm",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),



                                          const SizedBox(height: 6),

                                          stockist.areaId == null
                                              ? GestureDetector(
                                            onTap: () => _showAssignAreaSheet(stockist),
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
                                                Flexible(
                                                  child: Text(
                                                    stockist.area?.name ?? "Area Assigned",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),


                                          const SizedBox(height: 4),
                                          Text(
                                            stockist.contactPerson ?? "No Contact Person",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_rounded,
                                                  size: 12, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  stockist.registeredOfficeAddress ?? "No Address",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12, color: Colors.grey[600]),
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
                              _buildBodyContent(context, stockist, isValidMap, themeColor, isTablet),
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
                      child: isTablet
                          ? cardContent
                          : IntrinsicHeight(child: cardContent),
                    );
                  }

                  // --- Layout Logic ---
                  if (isMobile) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredStockists.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: buildStockistCard(filteredStockists[i], isTablet: false),
                      ),
                    );
                  } else {
                    // Tablet Grid Logic
                    final int crossAxisCount = isTabletPortrait ? 2 : 3;
                   // final double ratio = isTabletPortrait ? 1.3 : 1.2;

                    final double ratio = isTabletPortrait ? 1.05 : 1.10;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: ratio,
                      ),
                      itemCount: filteredStockists.length,
                      itemBuilder: (_, i) => buildStockistCard(filteredStockists[i], isTablet: true),
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),

      // --- FAB ---
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PharmaDistributorFormScreen(),
            ),
          );

          if (result == true) {
            _stokistController.fetchStokist();
          }
        },
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildBodyContent(BuildContext context, Stockist stockist, bool isValidMap,
      Color themeColor, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info Row: Years in Business & Type Chip
          Row(
            children: [
              Icon(Icons.store_mall_directory, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                "${stockist.yearsInBusiness ?? 0} Years in Biz",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (stockist.natureOfBusiness != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stockist.natureOfBusiness!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Primary Action: View Profile
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () => Get.to(() => StokistDetailScreen(stokist: stockist)),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "View Details",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),

          // Secondary Action: Map (Only if location valid)
          if (isValidMap) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.to(() => StokistDetailScreen(stokist: stockist)),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text("Locate on Map"),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storage, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No Stockists Found", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAssignAreaSheet(
      Stockist clinic,
      ) async {

    final areas =
    await _stokistController
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

                          await _stokistController
                              .assignAreaToStockist(
                            stockistId: clinic.id,
                            areaId: area["id"],
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
      Stockist doctor,
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
      Stockist doctor,
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
      Stockist doctor,
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
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Area Name",
                    prefixIcon: const Icon(Icons.edit_location_alt),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
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
                          await _stokistController
                              .createNewArea(
                            name: areaController.text.trim(),
                            pincode: pincode,
                            postOffice: office['Name'],
                            headOfficeId: doctor.headOfficeId,
                          );

                          if (createdAreaId != null) {

                            await _stokistController
                                .assignAreaToStockist(
                              stockistId: doctor.id,
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


