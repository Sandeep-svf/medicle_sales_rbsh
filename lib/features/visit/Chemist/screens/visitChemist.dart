import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/common/Model/SMResponseModel.dart';

import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../../../../../utils/LocationHelper/LocationHelper.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/text_strings.dart';
import '../../../../../../utils/local_storage/auth_manager.dart';
import '../../../../common/Model/DoctorVisitResponse.dart';
import '../../../../utils/http/http_client.dart';
// Use ClinicController for Chemists
import 'package:medicle_sales_rbsh/features/addClinic/controllers/ClinicListController.dart';
import '../../../product/controller/ProductController.dart';
import '../controllers/visitListController.dart';
import '../models/ChemisVisitModel.dart'; // Ensure this model is imported
// Import the new Schedule Screen
import 'ScheduleChemistVisitScreen.dart';

class VisitChemistScreen extends StatefulWidget {
  const VisitChemistScreen({super.key});

  @override
  State<VisitChemistScreen> createState() => _VisitChemistScreenState();
}

class _VisitChemistScreenState extends State<VisitChemistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Controller for fetching Chemist list (for dropdowns/cache)
  final ClinicListController _clinicListController = Get.put(ClinicListController());

  // Controller for fetching Visits
  late VisitListController _visitListController;
  final AuthManager authManager = AuthManager();

  // Location
  String _location = 'Fetching location...';
  LocationHelper locationHelper = LocationHelper();

  // Filter State
  VisitDateFilter _selectedFilter = VisitDateFilter.today;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _clinicListController.fetchClinicList();

    _visitListController = VisitListController();
    // Initial Fetch (Default: Today)
    _visitListController.fetchVisitList(filter: VisitDateFilter.today);
  }

  // --- NAVIGATION ---
  void _navigateToScheduleScreen() async {
    // Navigate to the new Searchable Schedule Screen
    final result = await Get.to(() => const ScheduleChemistVisitScreen());

    if (result == true) {
      // Refresh list based on current filter
      _visitListController.fetchVisitList(
        filter: _selectedFilter,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      Get.snackbar(
          "Success",
          "Chemist list updated",
          backgroundColor: TColors.primary.withOpacity(0.1),
          colorText: TColors.primary
      );
    }
  }

  // --- FILTER LOGIC ---
  void _onFilterChanged(VisitDateFilter filter) async {
    if (filter == VisitDateFilter.custom) {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2023),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: TColors.primary, // Chemist Theme
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          _selectedFilter = filter;
          _selectedDateRange = picked;
        });
        _visitListController.fetchVisitList(
          filter: VisitDateFilter.custom,
          startDate: picked.start,
          endDate: picked.end,
        );
      }
    } else {
      setState(() {
        _selectedFilter = filter;
        _selectedDateRange = null;
      });
      _visitListController.fetchVisitList(filter: filter);
    }
  }

  String _getFilterName(VisitDateFilter filter) {
    switch (filter) {
      case VisitDateFilter.today: return "Today";
      case VisitDateFilter.last7Days: return "Last 7 Days";
      case VisitDateFilter.last15Days: return "Last 15 Days";
      case VisitDateFilter.custom:
        if (_selectedDateRange != null) {
          return "${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}";
        }
        return "Custom Range";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Chemist",
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

          // 2. Horizontal Filter List
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(VisitDateFilter.today),
                const SizedBox(width: 8),
                _buildFilterChip(VisitDateFilter.last7Days),
                const SizedBox(width: 8),
                _buildFilterChip(VisitDateFilter.last15Days),
                const SizedBox(width: 8),
                _buildFilterChip(VisitDateFilter.custom),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. Main Content List (Includes Status Summary)
          Expanded(
            child: ListenableBuilder(
              listenable: _visitListController,
              builder: (context, child) {
                if (_visitListController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (_visitListController.salesList.isEmpty) {
                  // Custom Empty State
                  return _buildEmptyState();
                } else {
                  // --- CALCULATE SUMMARY STATS ---
                  final allVisits = _visitListController.salesList;
                  final int totalVisits = allVisits.length;
                  final int confirmedVisits = allVisits.where((v) => v.confirmed == true).length;
                  final int pendingVisits = totalVisits - confirmedVisits;

                  // --- FILTER LOGIC (SEARCH) ---
                  List<ChemistVisitModel> filteredChemists = allVisits
                      .where((visit) =>
                  visit.chemist?.firmName
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                      false)
                      .toList();

                  // Use a Column to show Summary + List
                  return Column(
                    children: [
                      // --- STATUS SUMMARY WIDGET ---
                      _buildStatusSummaryDashboard(totalVisits, confirmedVisits, pendingVisits),

                      const SizedBox(height: 10),

                      if (filteredChemists.isEmpty)
                        const Expanded(child: Center(child: Text("No chemists found matching your search.")))
                      else
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              bool isTablet = constraints.maxWidth > 600;

                              // 3. Reusable Card Builder Function
                              Widget buildCard(ChemistVisitModel visit) {
                                final chemistName = visit.chemist?.firmName ?? "Unknown Chemist";
                                final String initials = chemistName.trim().isNotEmpty
                                    ? chemistName.trim().substring(0, 1).toUpperCase()
                                    : "C";

                                // Status Helpers
                                final isConfirmed = visit.confirmed == true;
                                final statusColor = isConfirmed ? Colors.green : TColors.primary;
                                final statusText = isConfirmed ? "Completed" : "Action Needed";
                                final statusIcon = isConfirmed ? Icons.check_circle : Icons.pending;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: TColors.primary.withOpacity(0.4), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Left Colored Strip
                                        Container(width: 6, color: statusColor),

                                        // Main Content
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // --- Header Section ---
                                              Container(
                                                padding: const EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.04),
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
                                                            color: statusColor.withOpacity(0.3),
                                                            width: 2),
                                                      ),
                                                      child: CircleAvatar(
                                                        radius: 22,
                                                        backgroundColor: Colors.white,
                                                        child: Text(
                                                          initials,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                            color: statusColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),

                                                    // Name, Date
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            chemistName,
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black87,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 6),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.calendar_today_rounded,
                                                                  size: 14,
                                                                  color: Colors.grey[600]),
                                                              const SizedBox(width: 4),
                                                              Expanded(
                                                                child: Text(
                                                                  DateFormat('dd MMM, hh:mm a').format(visit.date ?? DateTime.now()),
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Colors.grey[600],
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
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

                                              // --- Body Section ---
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                                child: Column(
                                                  children: [
                                                    // --- Status Badge ---
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: statusColor.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(statusIcon,
                                                                  size: 12, color: statusColor),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                statusText,
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: statusColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 12),

                                                    // --- Notes ---
                                                    Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[50],
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(color: Colors.grey[200]!),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "CALL NOTES",
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.grey[500],
                                                              fontWeight: FontWeight.w700,
                                                              letterSpacing: 0.5,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            visit.notes?.isNotEmpty == true
                                                                ? visit.notes!
                                                                : "No notes provided.",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.grey[700],
                                                              fontStyle: visit.notes?.isNotEmpty == true
                                                                  ? FontStyle.normal
                                                                  : FontStyle.italic,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),

                                                    // --- Action Button ---
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: isConfirmed
                                                            ? () {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text('You have already marked this visit confirmed.'),
                                                              backgroundColor: Colors.orange,
                                                            ),
                                                          );
                                                        }
                                                            : () {
                                                          _confirmVisitLogic(visit);
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: isConfirmed
                                                              ? Colors.green
                                                              : TColors.primary,
                                                          foregroundColor: Colors.white,
                                                          elevation: isConfirmed ? 0 : 2,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          minimumSize: const Size(double.infinity, 44),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                                isConfirmed
                                                                    ? Icons.verified
                                                                    : Icons.touch_app_rounded,
                                                                size: 20),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              isConfirmed
                                                                  ? TTexts.visitConfirmed
                                                                  : TTexts.confirmVisit,
                                                              style: const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // Layout Selection
                              if (isTablet) {
                                final bool isLandscape = constraints.maxWidth > constraints.maxHeight;
                                final int crossAxisCount = isLandscape ? 3 : 2;
                                double padding = 16.0;
                                double spacing = 16.0;
                                double totalSpacing = (padding * 2) + ((crossAxisCount - 1) * spacing);
                                double itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
                                double requiredHeight = 330.0;
                                double childAspectRatio = itemWidth / requiredHeight;

                                return GridView.builder(
                                  padding: EdgeInsets.all(padding),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: spacing,
                                    mainAxisSpacing: spacing,
                                    childAspectRatio: childAspectRatio,
                                  ),
                                  itemCount: filteredChemists.length,
                                  itemBuilder: (context, index) =>
                                      buildCard(filteredChemists[index]),
                                );
                              } else {
                                return ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  itemCount: filteredChemists.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: buildCard(filteredChemists[index]),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToScheduleScreen,
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- NEW: STATUS SUMMARY WIDGETS ---

  Widget _buildStatusSummaryDashboard(int total, int confirmed, int pending) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ]
        ),
        child: Row(
          children: [
            _buildStatusCard("Total", total.toString(), TColors.primary, Icons.store),
            Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)), // Divider
            _buildStatusCard("Done", confirmed.toString(), Colors.green, Icons.check_circle_outline),
            Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)), // Divider
            _buildStatusCard("Pending", pending.toString(), Colors.orange, Icons.pending_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color.withOpacity(0.8)),
              const SizedBox(width: 6),
              Text(
                count,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- CONFIRM LOGIC ---
  void _confirmVisitLogic(ChemistVisitModel visit) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        title: "Confirm Visit",
        text: "Mark this visit as completed?",
        confirmBtnText: "Yes",
        confirmBtnColor: TColors.primary,
        onConfirmBtnTap: () async {
          Navigator.pop(context); // Close alert

          // Permission
          var permission = await Permission.location.request();
          if (!permission.isGranted) {
            Get.snackbar("Permission", "Location permission is required.");
            return;
          }

          try {
            Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

            final response = await http.put(
              Uri.parse('${THttpHelper.baseUrl}/chemist-visits/${visit.id}/confirm'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'userLatitude': pos.latitude,
                'userLongitude': pos.longitude,
              }),
            );

            if (response.statusCode == 200) {
              final body = json.decode(response.body);
              // Adapt based on your specific response model structure
              bool success = body['success'] ?? body['status'] ?? false;

              if (success) {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  text: "Visit Confirmed Successfully!",
                  confirmBtnColor: TColors.primary,
                );
                // Refresh List
                _visitListController.fetchVisitList(
                    filter: _selectedFilter,
                    startDate: _selectedDateRange?.start,
                    endDate: _selectedDateRange?.end
                );
              } else {
                Get.snackbar("Error", body['message'] ?? "Failed to confirm.");
              }
            } else {
              Get.snackbar("Error", "Server error: ${response.statusCode}");
            }
          } catch (e) {
            Get.snackbar("Error", "Unexpected error: $e");
          }
        }
    );
  }

  // --- Widget Methods ---

  Widget _buildFilterChip(VisitDateFilter filter) {
    final bool isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(
        _getFilterName(filter),
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          _onFilterChanged(filter);
        }
      },
      selectedColor: TColors.primary,
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: isSelected ? TColors.primary : Colors.transparent),
      showCheckmark: false,
    );
  }

  Widget _buildEmptyState() {
    String message = "No chemist visits found.";
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_mall_directory,
              size: 64,
              color: TColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Schedules Available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToScheduleScreen,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Schedule New Visit"),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          )
        ],
      ),
    );
  }
}