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
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import '../../../../../../utils/local_storage/auth_manager.dart';
import '../../../../common/Model/DoctorVisitResponse.dart';
import '../../../../utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/features/addClinic/controllers/ClinicListController.dart';
import '../../../product/controller/ProductController.dart';
import '../controllers/visitListController.dart';
import '../models/ChemisVisitModel.dart';
import 'ScheduleChemistVisitScreen.dart';

// Use ClinicController for Chemists
// Import the new Schedule Screen

class VisitChemistScreen extends StatefulWidget {
  const VisitChemistScreen({super.key});

  @override
  State<VisitChemistScreen> createState() => _VisitChemistScreenState();
}

class _VisitChemistScreenState extends State<VisitChemistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Controller for fetching Chemist list (for dropdowns/cache)
  final ClinicListController _clinicListController =
      Get.put(ClinicListController());

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

      Get.snackbar("Success", TTexts.uiTextChemistListUpdated,
          backgroundColor: TColors.primary.withOpacity(0.1),
          colorText: TColors.primary);
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
                onPrimary: TColors.white,
                onSurface: TColors.pureBlack,
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
      case VisitDateFilter.today:
        return "Today";
      case VisitDateFilter.last7Days:
        return "Last 7 Days";
      case VisitDateFilter.last15Days:
        return "Last 15 Days";
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
                labelText: TTexts.uiTextSearchChemist,
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
            height: TSizes.v50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(VisitDateFilter.today),
                const SizedBox(width: TSizes.v8),
                _buildFilterChip(VisitDateFilter.last7Days),
                const SizedBox(width: TSizes.v8),
                _buildFilterChip(VisitDateFilter.last15Days),
                const SizedBox(width: TSizes.v8),
                _buildFilterChip(VisitDateFilter.custom),
              ],
            ),
          ),

          const SizedBox(height: TSizes.v10),

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
                  final int confirmedVisits =
                      allVisits.where((v) => v.confirmed == true).length;
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
                      _buildStatusSummaryDashboard(
                          totalVisits, confirmedVisits, pendingVisits),

                      const SizedBox(height: TSizes.v10),

                      if (filteredChemists.isEmpty)
                        const Expanded(
                            child: Center(
                                child: Text(TTexts
                                    .uiTextNoChemistsFoundMatchingYourSearch)))
                      else
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              bool isTablet = constraints.maxWidth > 600;

                              // 3. Reusable Card Builder Function
                              Widget buildCard(ChemistVisitModel visit) {
                                final chemistName = visit.chemist?.firmName ??
                                    "Unknown Chemist";
                                final String initials =
                                    chemistName.trim().isNotEmpty
                                        ? chemistName
                                            .trim()
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : "C";

                                // Status Helpers
                                final isConfirmed = visit.confirmed == true;
                                final statusColor = isConfirmed
                                    ? TColors.materialGreen
                                    : TColors.primary;
                                final statusText =
                                    isConfirmed ? "Completed" : "Action Needed";
                                final statusIcon = isConfirmed
                                    ? Icons.check_circle
                                    : Icons.pending;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: TColors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: TColors.primary.withOpacity(0.4),
                                        width: TSizes.v1),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            TColors.pureBlack.withOpacity(0.06),
                                        blurRadius: TSizes.v15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Left Colored Strip
                                        Container(
                                            width: TSizes.v6,
                                            color: statusColor),

                                        // Main Content
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // --- Header Section ---
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  color: statusColor
                                                      .withOpacity(0.04),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Avatar
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: statusColor
                                                                .withOpacity(
                                                                    0.3),
                                                            width: TSizes.v2),
                                                      ),
                                                      child: CircleAvatar(
                                                        radius: TSizes.v22,
                                                        backgroundColor:
                                                            TColors.white,
                                                        child: Text(
                                                          initials,
                                                          style: TextStyle(
                                                            fontSize:
                                                                TSizes.v18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: statusColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width: TSizes.v12),

                                                    // Name, Date
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            chemistName,
                                                            style:
                                                                const TextStyle(
                                                              fontSize:
                                                                  TSizes.v16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: TColors
                                                                  .black87,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                              height:
                                                                  TSizes.v6),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .calendar_today_rounded,
                                                                  size: TSizes
                                                                      .v14,
                                                                  color: TColors
                                                                      .materialGrey600),
                                                              const SizedBox(
                                                                  width: TSizes
                                                                      .v4),
                                                              Expanded(
                                                                child: Text(
                                                                  DateFormat(
                                                                          'dd MMM, hh:mm a')
                                                                      .format(visit
                                                                              .date ??
                                                                          DateTime
                                                                              .now()),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        TSizes
                                                                            .v12,
                                                                    color: TColors
                                                                        .materialGrey600,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
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
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 16, 16, 12),
                                                child: Column(
                                                  children: [
                                                    // --- Status Badge ---
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: statusColor
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(statusIcon,
                                                                  size: TSizes
                                                                      .v12,
                                                                  color:
                                                                      statusColor),
                                                              const SizedBox(
                                                                  width: TSizes
                                                                      .v4),
                                                              Text(
                                                                statusText,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      TSizes
                                                                          .v10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      statusColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(
                                                        height: TSizes.v12),

                                                    // --- Notes ---
                                                    Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        color: TColors
                                                            .materialGrey50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            color: TColors
                                                                .materialGrey200!),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            TTexts
                                                                .uiTextCALLNOTES,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  TSizes.v10,
                                                              color: TColors
                                                                  .materialGrey500,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height:
                                                                  TSizes.v4),
                                                          Text(
                                                            visit.notes?.isNotEmpty ==
                                                                    true
                                                                ? visit.notes!
                                                                : "No notes provided.",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  TSizes.v13,
                                                              color: TColors
                                                                  .materialGrey700,
                                                              fontStyle: visit
                                                                          .notes
                                                                          ?.isNotEmpty ==
                                                                      true
                                                                  ? FontStyle
                                                                      .normal
                                                                  : FontStyle
                                                                      .italic,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: TSizes.v12),

                                                    // --- Action Button ---
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: isConfirmed
                                                            ? () {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        TTexts
                                                                            .uiTextYouHaveAlreadyMarkedThisVisitConfirmed),
                                                                    backgroundColor:
                                                                        TColors
                                                                            .materialOrange,
                                                                  ),
                                                                );
                                                              }
                                                            : () {
                                                                _handleChemistVisitFlow(
                                                                    visit);
                                                              },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              isConfirmed
                                                                  ? TColors
                                                                      .materialGreen
                                                                  : TColors
                                                                      .primary,
                                                          foregroundColor:
                                                              TColors.white,
                                                          elevation: isConfirmed
                                                              ? 0
                                                              : 2,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          minimumSize:
                                                              const Size(
                                                                  double
                                                                      .infinity,
                                                                  44),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                isConfirmed
                                                                    ? Icons
                                                                        .verified
                                                                    : Icons
                                                                        .touch_app_rounded,
                                                                size:
                                                                    TSizes.v20),
                                                            const SizedBox(
                                                                width:
                                                                    TSizes.v8),
                                                            Text(
                                                              isConfirmed
                                                                  ? TTexts
                                                                      .visitConfirmed
                                                                  : TTexts
                                                                      .confirmVisit,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      TSizes
                                                                          .v15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
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
                                final bool isLandscape = constraints.maxWidth >
                                    constraints.maxHeight;
                                final int crossAxisCount = isLandscape ? 3 : 2;
                                double padding = 16.0;
                                double spacing = 16.0;
                                double totalSpacing = (padding * 2) +
                                    ((crossAxisCount - 1) * spacing);
                                double itemWidth =
                                    (constraints.maxWidth - totalSpacing) /
                                        crossAxisCount;
                                double requiredHeight = 330.0;
                                double childAspectRatio =
                                    itemWidth / requiredHeight;

                                return GridView.builder(
                                  padding: EdgeInsets.all(padding),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  itemCount: filteredChemists.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
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
        child: const Icon(Icons.add, color: TColors.white),
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
            color: TColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TColors.materialGrey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: TColors.pureBlack.withOpacity(0.03),
                blurRadius: TSizes.v10,
                offset: const Offset(0, 2),
              )
            ]),
        child: Row(
          children: [
            _buildStatusCard(
                "Total", total.toString(), TColors.primary, Icons.store),
            Container(
                width: TSizes.v1,
                height: TSizes.v40,
                color: TColors.materialGrey.withOpacity(0.2)), // Divider
            _buildStatusCard("Done", confirmed.toString(),
                TColors.materialGreen, Icons.check_circle_outline),
            Container(
                width: TSizes.v1,
                height: TSizes.v40,
                color: TColors.materialGrey.withOpacity(0.2)), // Divider
            _buildStatusCard("Pending", pending.toString(),
                TColors.materialOrange, Icons.pending_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: TSizes.v16, color: color.withOpacity(0.8)),
              const SizedBox(width: TSizes.v6),
              Text(
                count,
                style: TextStyle(
                  fontSize: TSizes.v18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.v4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: TSizes.v10,
              fontWeight: FontWeight.w600,
              color: TColors.materialGrey600,
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
        title: TTexts.confirmVisit,
        text: TTexts.uiTextMarkThisVisitAsCompleted,
        confirmBtnText: TTexts.yes,
        confirmBtnColor: TColors.primary,
        onConfirmBtnTap: () async {
          Navigator.pop(context); // Close alert

          // Permission
          var permission = await Permission.location.request();
          if (!permission.isGranted) {
            Get.snackbar(
                "Permission", TTexts.uiTextLocationPermissionIsRequired);
            return;
          }

          try {
            Position pos = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);

            final response = await http.put(
              Uri.parse(
                  '${THttpHelper.baseUrl}/chemist-visits/${visit.id}/confirm'),
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
                  text: TTexts.uiTextVisitConfirmedSuccessfully,
                  confirmBtnColor: TColors.primary,
                );
                // Refresh List
                _visitListController.fetchVisitList(
                    filter: _selectedFilter,
                    startDate: _selectedDateRange?.start,
                    endDate: _selectedDateRange?.end);
              } else {
                Get.snackbar("Error", body['message'] ?? "Failed to confirm.");
              }
            } else {
              Get.snackbar("Error", "Server error: ${response.statusCode}");
            }
          } catch (e) {
            Get.snackbar("Error", "Unexpected error: $e");
          }
        });
  }

  // --- Widget Methods ---

  Widget _buildFilterChip(VisitDateFilter filter) {
    final bool isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(
        _getFilterName(filter),
        style: TextStyle(
          color: isSelected ? TColors.white : TColors.black87,
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
      backgroundColor: TColors.materialGrey200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side:
          BorderSide(color: isSelected ? TColors.primary : TColors.transparent),
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
              size: TSizes.v64,
              color: TColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: TSizes.v24),
          Text(
            TTexts.uiTextNoSchedulesAvailable,
            style: TextStyle(
              fontSize: TSizes.v20,
              fontWeight: FontWeight.bold,
              color: TColors.materialGrey800,
            ),
          ),
          const SizedBox(height: TSizes.v8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: TSizes.v16,
              color: TColors.materialGrey600,
            ),
          ),
          const SizedBox(height: TSizes.v32),
          ElevatedButton.icon(
            onPressed: _navigateToScheduleScreen,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(TTexts.scheduleVisitTitle),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
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

  Future<void> _showAssignAreaBottomSheet(
    ChemistVisitModel chemistVisit,
  ) async {
    final allAreas = await _visitListController.fetchAreas();

    debugPrint(
      "TOTAL AREAS => ${allAreas.length}",
    );

    final RxList<dynamic> filteredAreas = allAreas.obs;

    final TextEditingController searchController = TextEditingController();

    Get.bottomSheet(
      Container(
        height: Get.height * .80,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: TTexts.uiTextSearchArea,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                filteredAreas.assignAll(
                  allAreas.where(
                    (e) => (e["name"] ?? "").toString().toLowerCase().contains(
                          value.toLowerCase(),
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: TSizes.v10),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: filteredAreas.length,
                  itemBuilder: (_, index) {
                    final area = filteredAreas[index];

                    return ListTile(
                      title: Text(
                        area["name"] ?? "",
                      ),
                      subtitle: Text(
                        "${area["pincode"] ?? ""} • ${area["post_office"] ?? ""}",
                      ),
                      onTap: () async {
                        Get.back();

                        await _visitListController.assignAreaToChemist(
                          chemistId: chemistVisit.chemistId,
                          areaId: area["id"],
                        );

                        await _visitListController.fetchVisitList(
                          filter: _selectedFilter,
                          startDate: _selectedDateRange?.start,
                          endDate: _selectedDateRange?.end,
                        );

                        final updatedVisit =
                            _visitListController.salesList.firstWhere(
                          (e) => e.id == chemistVisit.id,
                        );

                        _confirmVisitLogic(
                          updatedVisit,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(
                  TTexts.uiTextAreaNotFoundCreateNew,
                ),
                onPressed: () {
                  Get.back();

                  _showAddAreaDialog(
                    chemistVisit.chemist!,
                    chemistVisit,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAreaSelectionSheet(
    ChemistInfo chemist,
    String pincode,
    List offices,
    ChemistVisitModel chemistVisit,
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
                        chemist,
                        office,
                        pincode,
                        chemistVisit,
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

  void _showAddAreaDialog(
    ChemistInfo chemist,
    ChemistVisitModel chemistVisit,
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
                  prefixIcon: const Icon(Icons.pin_drop),
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
                        TTexts.uiTextPleaseEnterValidPincode,
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
                      chemist,
                      pin,
                      offices,
                      chemistVisit,
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

  void _showCreateAreaForm(
    ChemistInfo chemist,
    Map office,
    String pincode,
    ChemistVisitModel chemistVisit,
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
                    prefixIcon: const Icon(
                      Icons.edit_location_alt,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.v20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TColors.materialGrey50,
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
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
                              await _visitListController.createArea(
                            areaName: areaController.text.trim(),
                            pincode: pincode,
                            postOffice: office['Name'] ?? '',
                            headOfficeId: chemist.headOfficeId ?? '',
                          );

                          if (createdAreaId == null) {
                            return;
                          }

                          await _visitListController.assignAreaToChemist(
                            chemistId: chemist.id,
                            areaId: createdAreaId,
                          );

                          Get.back();

                          await Future.delayed(
                            const Duration(
                              milliseconds: 300,
                            ),
                          );

                          await _visitListController.fetchVisitList(
                            filter: _selectedFilter,
                            startDate: _selectedDateRange?.start,
                            endDate: _selectedDateRange?.end,
                          );

                          final updatedVisit =
                              _visitListController.salesList.firstWhere(
                            (e) => e.id == chemistVisit.id,
                          );

                          Future.microtask(
                            () {
                              _confirmVisitLogic(
                                updatedVisit,
                              );
                            },
                          );
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

  Future<void> _handleChemistVisitFlow(
    ChemistVisitModel visit,
  ) async {
    final areaId = visit.chemist?.areaId;

    debugPrint(
      "Chemist Area Id => $areaId",
    );

    if (areaId == null || areaId.trim().isEmpty) {
      await _showAssignAreaBottomSheet(
        visit,
      );

      return;
    }

    _confirmVisitLogic(
      visit,
    );
  }
}
