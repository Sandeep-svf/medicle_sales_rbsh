import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
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
                                          const SizedBox(height: 4),
                                          Text(
                                            stockist.contactPerson ?? "No Contact Person",
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
                    final double ratio = isTabletPortrait ? 1.3 : 1.2;

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
}


