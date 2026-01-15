import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                    final double ratio = isTabletPortrait ? 1.3 : 1.2;

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
}