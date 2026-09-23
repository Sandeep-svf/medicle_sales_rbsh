import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../../../../../../utils/LocationHelper/LocationHelper.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import '../../../../../../utils/local_storage/auth_manager.dart';
import '../../../../common/Model/DoctorVisitResponse.dart';
import '../../../../utils/http/http_client.dart';
import '../../../addStokist/controllers/StokistListController.dart';
import '../controllers/visitListController.dart';
import '../models/visitSalesData.dart';
import 'ScheduleStockistVisitScreen.dart';

// Import Stockist Controller and Model

class VisitStockistScreen extends StatefulWidget {
  const VisitStockistScreen({super.key});

  @override
  State<VisitStockistScreen> createState() => _VisitStockistScreenState();
}

class _VisitStockistScreenState extends State<VisitStockistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final StokistListController _stokistListController =
      Get.put(StokistListController());
  late VisitListController _visitListController;
  final AuthManager authManager = AuthManager();

  String _location = 'Fetching location...';
  LocationHelper locationHelper = LocationHelper();

  // Filter State
  VisitDateFilter _selectedFilter = VisitDateFilter.today;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _stokistListController.fetchStokist();

    _visitListController = VisitListController();
    _visitListController.fetchSalesList(filter: VisitDateFilter.today);
  }

  // --- NAVIGATION ---
  void _navigateToScheduleScreen() async {
    final result = await Get.to(() => const ScheduleStockistVisitScreen());
    if (result == true) {
      _visitListController.fetchSalesList(
        filter: _selectedFilter,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );
      Get.snackbar("Success", TTexts.uiTextStockistListUpdated,
          backgroundColor: TColors.success.withOpacity(0.1),
          colorText: TColors.success);
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
                primary: TColors.primary,
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
        _visitListController.fetchSalesList(
            filter: VisitDateFilter.custom,
            startDate: picked.start,
            endDate: picked.end);
      }
    } else {
      setState(() {
        _selectedFilter = filter;
        _selectedDateRange = null;
      });
      _visitListController.fetchSalesList(filter: filter);
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
      backgroundColor: TColors.materialGrey50,
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: TTexts.uiTextSearchStockist,
                fillColor: TColors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColors.materialGrey.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TColors.primary)),
                prefixIcon: const Icon(Icons.search, color: TColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                              _searchController.clear();
                              _searchQuery = "";
                            }))
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
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

          // 3. Main Content (Summary + List)
          Expanded(
            child: ListenableBuilder(
              listenable: _visitListController,
              builder: (context, child) {
                if (_visitListController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (_visitListController.salesList.isEmpty) {
                  return _buildEmptyState();
                } else {
                  // Stats
                  final allVisits = _visitListController.salesList;
                  final int totalVisits = allVisits.length;
                  final int confirmedVisits = allVisits
                      .where((v) => (v as StockistVisit).confirmed == true)
                      .length;
                  final int pendingVisits = totalVisits - confirmedVisits;

                  // Filter List
                  List<StockistVisit> filteredList = allVisits
                      .cast<StockistVisit>()
                      .where((visit) =>
                          (visit.stockist?.firmName?.toLowerCase() ?? "")
                              .contains(_searchQuery.toLowerCase()))
                      .toList();

                  return Column(
                    children: [
                      _buildStatusSummaryDashboard(
                          totalVisits, confirmedVisits, pendingVisits),
                      const SizedBox(height: TSizes.v10),
                      if (filteredList.isEmpty)
                        const Expanded(
                            child: Center(
                                child: Text(TTexts
                                    .uiTextNoStockistsFoundMatchingYourSearch)))
                      else
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              bool isTablet = constraints.maxWidth > 600;

                              Widget buildCard(StockistVisit visit) {
                                final stockistName = visit.stockist?.firmName ??
                                    "Unknown Stockist";
                                final String initials =
                                    stockistName.trim().isNotEmpty
                                        ? stockistName
                                            .trim()
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : "S";

                                final isConfirmed = visit.confirmed == true;
                                final statusColor = isConfirmed
                                    ? TColors.success
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
                                          color: TColors.pureBlack
                                              .withOpacity(0.06),
                                          blurRadius: TSizes.v15,
                                          offset: const Offset(0, 6)),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                            width: TSizes.v6,
                                            color: statusColor),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Header
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                    color: statusColor
                                                        .withOpacity(0.04)),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: statusColor
                                                                  .withOpacity(
                                                                      0.3),
                                                              width:
                                                                  TSizes.v2)),
                                                      child: CircleAvatar(
                                                        radius: TSizes.v22,
                                                        backgroundColor:
                                                            TColors.white,
                                                        child: Text(initials,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    TSizes.v18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    statusColor)),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width: TSizes.v12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            stockistName,
                                                            style: const TextStyle(
                                                                fontSize:
                                                                    TSizes.v16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: TColors
                                                                    .black87),
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
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          TSizes
                                                                              .v12,
                                                                      color: TColors
                                                                          .materialGrey600,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
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
                                              // Body
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 16, 16, 12),
                                                child: Column(
                                                  children: [
                                                    // Info Row (Status)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 6),
                                                          decoration: BoxDecoration(
                                                              color: statusColor
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                          child: Row(
                                                            children: [
                                                              Icon(statusIcon,
                                                                  size: TSizes
                                                                      .v14,
                                                                  color:
                                                                      statusColor),
                                                              const SizedBox(
                                                                  width: TSizes
                                                                      .v6),
                                                              Text(statusText,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          TSizes
                                                                              .v11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          statusColor)),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                        height: TSizes.v12),
                                                    // Notes
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
                                                                  .materialGrey200!)),
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
                                                                      TSizes
                                                                          .v10,
                                                                  color: TColors
                                                                      .materialGrey500,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  letterSpacing:
                                                                      0.5)),
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
                                                                        .italic),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: TSizes.v12),
                                                    // Button
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: isConfirmed
                                                            ? () {
                                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                    content: Text(
                                                                        TTexts
                                                                            .uiTextVisitAlreadyConfirmed),
                                                                    backgroundColor:
                                                                        TColors
                                                                            .materialOrange));
                                                              }
                                                            : () =>
                                                                _confirmVisitLogic(
                                                                    visit),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              statusColor,
                                                          foregroundColor:
                                                              TColors.white,
                                                          elevation: isConfirmed
                                                              ? 0
                                                              : 2,
                                                          shadowColor:
                                                              statusColor
                                                                  .withOpacity(
                                                                      0.4),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
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
                                                                            .bold)),
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

                              if (isTablet) {
                                return GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: TSizes.v16,
                                          mainAxisSpacing: TSizes.v16,
                                          childAspectRatio:
                                              1.3 // Changed from 2.0 to 1.3 to fix Overflow
                                          ),
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) =>
                                      buildCard(filteredList[index]),
                                );
                              } else {
                                return ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: buildCard(filteredList[index])),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToScheduleScreen,
        backgroundColor: TColors.primary,
        icon: const Icon(Icons.add, color: TColors.white),
        label: const Text(TTexts.uiTextNewVisit,
            style:
                TextStyle(color: TColors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _confirmVisitLogic(StockistVisit visit) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        title: TTexts.confirmVisit,
        text: TTexts.uiTextMarkThisStockistVisitAsCompleted,
        confirmBtnText: TTexts.yes,
        confirmBtnColor: TColors.primary,
        onConfirmBtnTap: () async {
          Navigator.pop(context);

          var permission = await Permission.location.request();
          if (!permission.isGranted) {
            Get.snackbar("Permission", TTexts.uiTextLocationRequired);
            return;
          }

          try {
            Position pos = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);

            final response = await http.put(
              Uri.parse(
                  '${THttpHelper.baseUrl}/stockist-visits/${visit.id}/confirm'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'userLatitude': pos.latitude,
                'userLongitude': pos.longitude,
              }),
            );

            if (response.statusCode == 200) {
              final body = json.decode(response.body);
              VisitConfirmResponse res = VisitConfirmResponse.fromJson(body);

              if (res.status == true) {
                QuickAlert.show(
                    context: context,
                    type: QuickAlertType.success,
                    text: res.message,
                    confirmBtnColor: TColors.primary);
                _visitListController.fetchSalesList(filter: _selectedFilter);
              } else {
                Get.snackbar("Error", res.message ?? "Failed");
              }
            } else {
              Get.snackbar("Error", "Server error: ${response.statusCode}");
            }
          } catch (e) {
            Get.snackbar("Error", e.toString());
          }
        });
  }

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
                  offset: const Offset(0, 2))
            ]),
        child: Row(
          children: [
            _buildStatusCard(
                "Total", total.toString(), TColors.primary, Icons.inventory_2),
            Container(
                width: TSizes.v1,
                height: TSizes.v40,
                color: TColors.materialGrey.withOpacity(0.2)),
            _buildStatusCard("Done", confirmed.toString(), TColors.success,
                Icons.check_circle_outline),
            Container(
                width: TSizes.v1,
                height: TSizes.v40,
                color: TColors.materialGrey.withOpacity(0.2)),
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
        child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: TSizes.v16, color: color.withOpacity(0.8)),
        const SizedBox(width: TSizes.v6),
        Text(count,
            style: TextStyle(
                fontSize: TSizes.v18,
                fontWeight: FontWeight.bold,
                color: color))
      ]),
      const SizedBox(height: TSizes.v4),
      Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: TSizes.v10,
              fontWeight: FontWeight.w600,
              color: TColors.materialGrey600))
    ]));
  }

  Widget _buildFilterChip(VisitDateFilter filter) {
    final bool isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(_getFilterName(filter),
          style: TextStyle(
              color: isSelected ? TColors.white : TColors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) _onFilterChanged(filter);
      },
      selectedColor: TColors.primary,
      backgroundColor: TColors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isSelected ? TColors.primary : TColors.materialGrey300)),
      showCheckmark: false,
    );
  }

  Widget _buildEmptyState() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inventory_2_outlined,
          size: TSizes.v64, color: TColors.materialGrey300),
      const SizedBox(height: TSizes.v16),
      Text(TTexts.uiTextNoStockistVisitsFound,
          style: TextStyle(
              fontSize: TSizes.v18,
              fontWeight: FontWeight.bold,
              color: TColors.materialGrey600)),
      TextButton(
          onPressed: _navigateToScheduleScreen,
          child: const Text(TTexts.uiTextScheduleNow))
    ]));
  }
}
