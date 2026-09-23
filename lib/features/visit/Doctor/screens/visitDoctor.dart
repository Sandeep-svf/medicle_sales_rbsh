import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/common/Model/SMResponseModel.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/doctor_offline.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../../../../../utils/LocationHelper/LocationHelper.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import '../../../../../../utils/local_storage/auth_manager.dart';
import '../../../../common/Model/DoctorVisitResponse.dart';
import '../../../../utils/camera/CameraLocationResult.dart';
import '../../../../utils/camera/image_overlay_utils.dart';
import '../../../../utils/http/http_client.dart';
import '../../../addDoctor/controllers/DoctroController.dart';
import '../../GeoVerificationScreen.dart';
import '../controllers/doctor_visit_product_controller.dart';
import '../controllers/visitListController.dart';
import '../models/visitSalesData.dart';
import '../services/pending_visit_sync_service.dart';
import '../services/visit_confirmation_service.dart';
import '../services/doctor_offline_upload_coordinator.dart';
import 'ScheduleVisitScreen.dart';

class VisitDoctorScreen extends StatefulWidget {
  const VisitDoctorScreen({super.key});

  @override
  State<VisitDoctorScreen> createState() => _VisitDoctorScreenState();
}

class _VisitDoctorScreenState extends State<VisitDoctorScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final DoctorListController _doctorListController =
      Get.put(DoctorListController());

  late VisitListController _visitListController;
  final AuthManager authManager = AuthManager();
  late DoctorVisitProductController productController;
  late PendingVisitSyncService _pendingVisitSyncService;
  late DoctorOfflineUploadCoordinator _uploadCoordinator;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isRefreshingAfterReconnect = false;
  bool _refreshQueued = false;
  bool _queuedRefreshShowsMessage = false;

  // Location helper
  String _location = 'Fetching location...';
  LocationHelper locationHelper = LocationHelper();

  // Filter State
  VisitDateFilter _selectedFilter = VisitDateFilter.today;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _doctorListController.fetchDoctorList();

    // Initialize controller
    _visitListController = VisitListController();

    productController = DoctorVisitProductController();
    _pendingVisitSyncService = PendingVisitSyncService();
    _uploadCoordinator = DoctorOfflineUploadCoordinator(
      visitSyncService: _pendingVisitSyncService,
    );
    _uploadCoordinator.startListening();
    _startConnectivityRefresh();
    // Local cache is loaded first, then visits/products and pending
    // confirmations are refreshed in the background on every screen open.
    unawaited(_refreshAll(showMessage: false));
  }

  void _startConnectivityRefresh() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((connectivity) {
      if (!connectivity.contains(ConnectivityResult.none)) {
        unawaited(_refreshAfterReconnect());
      }
    });
  }

  Future<void> _refreshAfterReconnect() async {
    await _refreshAll(showMessage: false);
  }

  Future<void> _refreshAll({required bool showMessage}) async {
    if (_isRefreshingAfterReconnect) {
      _refreshQueued = true;
      _queuedRefreshShowsMessage = _queuedRefreshShowsMessage || showMessage;
      debugPrint(
          'VisitDoctorScreen: refresh already running; queued a follow-up refresh.');
      return;
    }

    _isRefreshingAfterReconnect = true;
    try {
      // Keep cached products visible while checking the server.
      await productController.loadProducts(refresh: false);
      // Run the ordered outbox pipeline before refreshing the visit list:
      // doctors/geo images -> schedules -> visit confirmations.
      await _uploadCoordinator.syncAll();
      await productController.refreshProducts();
      await _visitListController.fetchSalesList(
        filter: _selectedFilter,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );
      await _visitListController.refreshPendingVisits();
      debugPrint(
        'VisitDoctorScreen: UI pending visit IDs after refresh = '
        '${_visitListController.pendingVisits.toList()}',
      );

      if (showMessage && mounted) {
        Get.snackbar(
          'Visits refreshed',
          TTexts.uiTextVisitsAndProductsAreUpToDatePending,
          backgroundColor: TColors.success,
          colorText: TColors.white,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('VisitDoctorScreen: Refresh failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isRefreshingAfterReconnect = false;
      if (_refreshQueued && mounted) {
        final showQueuedMessage = _queuedRefreshShowsMessage;
        _refreshQueued = false;
        _queuedRefreshShowsMessage = false;
        debugPrint('VisitDoctorScreen: running queued post-sync refresh.');
        unawaited(_refreshAll(showMessage: showQueuedMessage));
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshAfterReconnect());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    productController.dispose();
    _uploadCoordinator.dispose();
    _pendingVisitSyncService.dispose();
    _visitListController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- NEW: Navigation to Schedule Screen ---
  void _navigateToScheduleScreen() async {
    // Navigate and wait for result
    final result = await Get.to(() => const ScheduleVisitScreen());

    // If result is true, it means a visit was successfully created
    if (result == true) {
      _visitListController.fetchSalesList(
        filter: _selectedFilter,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      Get.snackbar("Success", TTexts.uiTextListUpdatedSuccessfully,
          backgroundColor: TColors.success.withOpacity(0.1),
          colorText: TColors.success);
    }
  }

  // --- Filter Handling Logic ---
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
          endDate: picked.end,
        );
      }
    } else {
      setState(() {
        _selectedFilter = filter;
        _selectedDateRange = null;
      });
      _visitListController.fetchSalesList(filter: filter);
    }
  }

  // Helper to get friendly name for filter
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
                labelText: TTexts.searchDoctor,
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.sync_rounded, color: TColors.primary),
                const SizedBox(width: TSizes.v8),
                const Expanded(
                  child: Text(
                    TTexts.uiTextLocalFirstVisitsSyncsAutomatically,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: TTexts.uiTextRefreshVisitsAndProducts,
                  onPressed: _isRefreshingAfterReconnect
                      ? null
                      : () => _refreshAll(showMessage: true),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                TTexts.uiTextPullDownToRefreshVisitsAndProductsConfirmations,
                style: TextStyle(fontSize: TSizes.v12, color: TColors.black54),
              ),
            ),
          ),

          const SizedBox(height: TSizes.v10),

          // 3. Main Content List (Includes Status Summary)
          Expanded(
            child: ListenableBuilder(
              listenable: _visitListController,
              builder: (context, child) {
                if (_visitListController.isLoading) {
                  return RefreshIndicator(
                    onRefresh: () => _refreshAll(showMessage: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: TSizes.v260,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    ),
                  );
                } else if (_visitListController.salesList.isEmpty) {
                  // Custom Empty State
                  return RefreshIndicator(
                    onRefresh: () => _refreshAll(showMessage: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                            height: TSizes.v260, child: _buildEmptyState()),
                      ],
                    ),
                  );
                } else {
                  // --- CALCULATE SUMMARY STATS ---
                  final allVisits = _visitListController.salesList;
                  final int totalVisits = allVisits.length;
                  final int confirmedVisits =
                      allVisits.where((v) => v.confirmed == true).length;
                  final int pendingVisits = totalVisits - confirmedVisits;

                  // --- FILTER LOGIC (SEARCH) ---
                  List<VisitSalesLogModel> filteredDoctors = allVisits
                      .where((doctor) =>
                          doctor.doctor?.name
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

                      if (filteredDoctors.isEmpty)
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => _refreshAll(showMessage: true),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(
                                  height: TSizes.v220,
                                  child: Center(
                                    child: Text(
                                      TTexts
                                          .uiTextNoDoctorsFoundMatchingYourSearch,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              bool isTablet = constraints.maxWidth > 600;

                              // 3. Reusable Card Builder Function
                              Widget buildCard(VisitSalesLogModel doctorVisit) {
                                final doctorName = doctorVisit.doctor?.name ??
                                    "Unknown VisitDoctor";
                                final String initials =
                                    doctorName.trim().isNotEmpty
                                        ? doctorName
                                            .trim()
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : "?";

                                // Status Helpers
                                final isPendingSync = _visitListController
                                    .pendingVisits
                                    .contains(doctorVisit.id);
                                final isSchedulePending =
                                    doctorVisit.schedulePending;
                                final hasScheduleSyncError =
                                    isSchedulePending &&
                                        doctorVisit.scheduleSyncError != null;

                                final isConfirmed =
                                    doctorVisit.confirmed == true ||
                                        isPendingSync;

                                final statusColor =
                                    doctorVisit.confirmed == true
                                        ? TColors.success
                                        : isPendingSync
                                            ? TColors.materialOrange
                                            : isSchedulePending
                                                ? TColors.materialOrange
                                                : TColors.primary;

                                final statusText = doctorVisit.confirmed == true
                                    ? "Completed"
                                    : isPendingSync
                                        ? "Pending Sync"
                                        : isSchedulePending
                                            ? hasScheduleSyncError
                                                ? "Schedule Sync Error"
                                                : "Schedule Pending Sync"
                                            : "Action Needed";

                                final statusIcon = doctorVisit.confirmed == true
                                    ? Icons.check_circle
                                    : isPendingSync
                                        ? Icons.sync
                                        : isSchedulePending
                                            ? Icons.sync_problem
                                            : Icons.pending;

                                // Priority Logic (Placeholder)
                                const String priority = "C";
                                Color priorityColor = TColors.materialBlueGrey;

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

                                                    // Name, Date & Priority
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  doctorName,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        TSizes
                                                                            .v16,
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
                                                              ),
                                                              // Priority Badge
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: priorityColor
                                                                      .withOpacity(
                                                                          0.1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                  border: Border.all(
                                                                      color: priorityColor
                                                                          .withOpacity(
                                                                              0.3)),
                                                                ),
                                                                child: Text(
                                                                  "Priority $priority",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        TSizes
                                                                            .v10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        priorityColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
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
                                                                  doctorVisit
                                                                          .date
                                                                          ?.toString() ??
                                                                      "Unknown Date",
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
                                                    // --- Rep Name & Status Row ---
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                TTexts
                                                                    .uiTextSALESREP,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      TSizes
                                                                          .v10,
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
                                                                  height: TSizes
                                                                      .v4),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .person_rounded,
                                                                      size: TSizes
                                                                          .v16,
                                                                      color: TColors
                                                                          .materialGrey700),
                                                                  const SizedBox(
                                                                      width: TSizes
                                                                          .v6),
                                                                  Expanded(
                                                                    child: Text(
                                                                      doctorVisit
                                                                              .user
                                                                              ?.name ??
                                                                          'N/A',
                                                                      style: const TextStyle(
                                                                          fontSize: TSizes
                                                                              .v13,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          color:
                                                                              TColors.black87),
                                                                      maxLines:
                                                                          1,
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
                                                            maxLines: 1,
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
                                                            doctorVisit.notes
                                                                        ?.isNotEmpty ==
                                                                    true
                                                                ? doctorVisit
                                                                    .notes!
                                                                : "No notes provided.",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  TSizes.v13,
                                                              color: TColors
                                                                  .materialGrey700,
                                                              height:
                                                                  TSizes.v1_4,
                                                              fontStyle: doctorVisit
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
                                                        onPressed: doctorVisit
                                                                    .confirmed ==
                                                                true
                                                            ? () {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        TTexts
                                                                            .uiTextVisitAlreadyConfirmed),
                                                                    backgroundColor:
                                                                        TColors
                                                                            .materialGreen,
                                                                  ),
                                                                );
                                                              }
                                                            : isPendingSync
                                                                ? () {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Text(
                                                                          TTexts
                                                                              .uiTextThisVisitHasBeenSavedOfflineAndIs,
                                                                        ),
                                                                        backgroundColor:
                                                                            TColors.materialOrange,
                                                                      ),
                                                                    );
                                                                  }
                                                                : () {
                                                                    _handleVisitConfirmationFlow(
                                                                      context,
                                                                      doctorVisit,
                                                                    );
                                                                  },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor: doctorVisit
                                                                      .confirmed ==
                                                                  true
                                                              ? TColors.success
                                                              : isPendingSync
                                                                  ? TColors
                                                                      .materialOrange
                                                                  : TColors
                                                                      .primary,
                                                          foregroundColor:
                                                              TColors.white,
                                                          elevation: doctorVisit
                                                                      .confirmed ==
                                                                  true
                                                              ? 0
                                                              : 2,
                                                          shadowColor: (doctorVisit
                                                                          .confirmed ==
                                                                      true
                                                                  ? TColors
                                                                      .success
                                                                  : isPendingSync
                                                                      ? TColors
                                                                          .materialOrange
                                                                      : TColors
                                                                          .primary)
                                                              .withOpacity(0.4),
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
                                                              doctorVisit.confirmed ==
                                                                      true
                                                                  ? Icons
                                                                      .verified
                                                                  : isPendingSync
                                                                      ? Icons
                                                                          .sync
                                                                      : Icons
                                                                          .touch_app_rounded,
                                                              size: TSizes.v20,
                                                            ),
                                                            const SizedBox(
                                                                width:
                                                                    TSizes.v8),
                                                            Text(
                                                              doctorVisit.confirmed ==
                                                                      true
                                                                  ? TTexts
                                                                      .visitConfirmed
                                                                  : isPendingSync
                                                                      ? "Pending Sync"
                                                                      : TTexts
                                                                          .confirmVisit,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize:
                                                                    TSizes.v15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
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

                                return RefreshIndicator(
                                  onRefresh: () =>
                                      _refreshAll(showMessage: true),
                                  child: GridView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(padding),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: spacing,
                                      childAspectRatio: childAspectRatio,
                                    ),
                                    itemCount: filteredDoctors.length,
                                    itemBuilder: (context, index) =>
                                        buildCard(filteredDoctors[index]),
                                  ),
                                );
                              } else {
                                return RefreshIndicator(
                                  onRefresh: () =>
                                      _refreshAll(showMessage: true),
                                  child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    itemCount: filteredDoctors.length,
                                    itemBuilder: (context, index) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: buildCard(filteredDoctors[index]),
                                    ),
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
        onPressed: _navigateToScheduleScreen, // Corrected to use new screen
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
            _buildStatusCard("Total", total.toString(), TColors.primary,
                Icons.calendar_today),
            Container(
                width: TSizes.v1,
                height: TSizes.v40,
                color: TColors.materialGrey.withOpacity(0.2)),
            // Divider
            _buildStatusCard("Done", confirmed.toString(), TColors.success,
                Icons.check_circle_outline),
            Container(
                width: TSizes.v1,
                height: TSizes.v40,
                color: TColors.materialGrey.withOpacity(0.2)),
            // Divider
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
    String message = "";
    switch (_selectedFilter) {
      case VisitDateFilter.today:
        message = "No visits scheduled for Today.";
        break;
      case VisitDateFilter.last7Days:
        message = "No visits found in the last 7 days.";
        break;
      case VisitDateFilter.last15Days:
        message = "No visits found in the last 15 days.";
        break;
      case VisitDateFilter.custom:
        message = "No visits found for the selected date range.";
        break;
    }

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
              Icons.calendar_month_outlined,
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
            onPressed: _navigateToScheduleScreen, // Corrected to use new screen
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

  // --- Methods from original code (Add Product, Confirm, etc) ---

  void _showProductSelectionBeforeConfirm(
      BuildContext context, String visitId) async {
    // Included via logic flow in cards
  }

  Future<List<String>> _showProductSelectionDialog(BuildContext context) async {
    final RxList<String> selectedProductIds = <String>[].obs;
    final RxString searchQuery = "".obs;

    await productController.loadProducts(
      refresh: !_visitListController.offlineMode,
    );

    return await showDialog<List<String>>(
          context: context,
          builder: (_) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text(TTexts.uiTextSelectProductsOptional),
                  content: SizedBox(
                    height: TSizes.v500,
                    width: double.maxFinite,
                    child: Obx(() {
                      if (productController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (productController.productList.isEmpty) {
                        return const Center(
                            child: Text(TTexts.uiTextNoProductsAvailable));
                      }

                      final filteredList =
                          productController.productList.where((product) {
                        return product.name
                            .toLowerCase()
                            .contains(searchQuery.value);
                      }).toList();

                      return Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: TTexts.uiTextSearchProducts,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (value) {
                              searchQuery.value = value.toLowerCase();
                            },
                          ),
                          const SizedBox(height: TSizes.v10),
                          Expanded(
                            child: filteredList.isEmpty
                                ? const Center(
                                    child: Text(
                                        TTexts.uiTextNoMatchingProductsFound))
                                : ListView.builder(
                                    itemCount: filteredList.length,
                                    itemBuilder: (_, i) {
                                      final product = filteredList[i];
                                      final isSelected = selectedProductIds
                                          .contains(product.id);
                                      return CheckboxListTile(
                                        value: isSelected,
                                        title: Text(product.name),
                                        subtitle:
                                            Text(product.description ?? ""),
                                        secondary: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            product.image ?? '',
                                            width: TSizes.v40,
                                            height: TSizes.v40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                    Icons.image_not_supported),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              selectedProductIds
                                                  .add(product.id);
                                            } else {
                                              selectedProductIds
                                                  .remove(product.id);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    }),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, <String>[]),
                      child: const Text(TTexts.skip),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, selectedProductIds.toList()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary),
                      child: const Text(TTexts.uiTextNext),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        <String>[];
  }

  /* void _confirmVisit(BuildContext context, String visitId, List<String> selectedProducts) async {
    bool confirmed = false;

    await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: "Confirm Visit",
      text: "Are you sure you want to mark this visit as confirmed?",
      confirmBtnText: "Yes",
      cancelBtnText: "Cancel",
      confirmBtnColor: TColors.primary,
      width: 300,
      onConfirmBtnTap: () {
        confirmed = true;
        Navigator.of(context, rootNavigator: true).pop();
      },
      onCancelBtnTap: () {
        confirmed = false;
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    if (!confirmed) return;

    try {
      var permission = await Permission.location.request();
      if (!permission.isGranted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Location permission is required.",
          confirmBtnColor: TColors.primary,
          width: 300,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await http.put(
        Uri.parse('${THttpHelper.baseUrl}/doctor-visits/$visitId/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userLatitude': position.latitude,
          'userLongitude': position.longitude,
          'notes': "",
          'productIds': selectedProducts,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final responseBody = json.decode(response.body);
          final visitResponse = VisitConfirmResponse.fromJson(responseBody);

          QuickAlert.show(
            context: context,
            type: visitResponse.status ? QuickAlertType.success : QuickAlertType.error,
            text: visitResponse.message,
            confirmBtnColor: TColors.primary,
            width: 300,
          );

          if (visitResponse.status) {
            // REFRESH LIST using current filter
            await _visitListController.fetchSalesList(
                filter: _selectedFilter,
                startDate: _selectedDateRange?.start,
                endDate: _selectedDateRange?.end
            );
          }
        } catch (e) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: "Error processing the response",
            confirmBtnColor: TColors.primary,
            width: 300,
          );
        }
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Failed to confirm the visit",
          confirmBtnColor: TColors.primary,
          width: 300,
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Unexpected error: $e",
        confirmBtnColor: TColors.primary,
        width: 300,
      );
    }
  }*/

  // 1. FLOW CONTROLLER
// 1. FLOW CONTROLLER
  // 1. FLOW CONTROLLER
// --- REPLACED FLOW CONTROLLER ---
  void _handleVisitConfirmationFlow(
    BuildContext context,
    VisitSalesLogModel doctorVisit,
  ) async {
    // ==================================================
    // AREA CHECK
    // ==================================================

    if (doctorVisit.doctor?.areaId == null ||
        doctorVisit.doctor!.areaId!.isEmpty) {
      await _showAssignAreaBottomSheet(
        context,
        doctorVisit,
      );

      await _visitListController.fetchSalesList(
        filter: _selectedFilter,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      return;
    }

    // ==================================================
    // GEO IMAGE CHECK
    // ==================================================

    final isOffline = await _isDoctorVisitOffline();
    final hasGeoImage = doctorVisit.doctor?.geoImageStatus == true ||
        (isOffline && await _hasOfflineDoctorGeoImage(doctorVisit));
    final isImageRequired = !hasGeoImage;

    if (isImageRequired) {
      final bool? success = await Get.to(
        () => GeoVerificationScreen(
          doctorId: doctorVisit.doctorId,
          doctorName: doctorVisit.doctor?.name ?? "VisitDoctor",
          saveOfflineImage: isOffline
              ? (image) => _saveDoctorGeoImageOffline(doctorVisit, image)
              : null,
        ),
      );

      if (success != true) {
        return;
      }
    }

    // ==================================================
    // PRODUCTS
    // ==================================================

    if (!mounted) return;

    List<String> selectedProducts = await _showProductSelectionDialog(
      context,
    );

    if (!mounted) return;

    _confirmVisit(
      context,
      doctorVisit,
      selectedProducts,
    );
  }

  Future<bool> _hasOfflineDoctorGeoImage(
    VisitSalesLogModel doctorVisit,
  ) async {
    final accountId = await authManager.getUserId();
    if (accountId == null || accountId.trim().isEmpty) return false;

    DoctorOfflineModule? module;
    try {
      module = await DoctorOfflineModule.acquire(accountId: accountId);
      final ids = <String>{
        doctorVisit.doctorId.trim(),
        doctorVisit.doctor?.id.trim() ?? '',
      }..removeWhere((id) => id.isEmpty);

      for (final doctor in module.controller.allDoctors) {
        final doctorIds = <String>{
          doctor.localId,
          doctor.serverId ?? '',
          doctor.clientGeneratedId ?? '',
        }..removeWhere((id) => id.isEmpty);
        if (!doctorIds.any(ids.contains)) continue;

        if (doctor.geoImageUrl?.trim().isNotEmpty == true) return true;
        final store = module.controller.creationStore;
        return store?.hasStoredImage(doctor.geoImageUploadId) ?? false;
      }
    } catch (error) {
      debugPrint('VisitDoctorScreen: Offline geo image lookup failed: $error');
    } finally {
      if (module != null) await module.dispose();
    }
    return false;
  }

  Future<bool> _saveDoctorGeoImageOffline(
    VisitSalesLogModel doctorVisit,
    File image,
  ) async {
    final accountId = await authManager.getUserId();
    if (accountId == null || accountId.trim().isEmpty) {
      Get.snackbar(
        'Authentication required',
        TTexts.uiTextSignInAgainBeforeSavingTheGeoImage,
        backgroundColor: TColors.materialRed,
        colorText: TColors.white,
      );
      return false;
    }

    DoctorOfflineModule? module;
    try {
      module = await DoctorOfflineModule.acquire(accountId: accountId);
      final ids = <String>{
        doctorVisit.doctorId.trim(),
        doctorVisit.doctor?.id.trim() ?? '',
      }..removeWhere((id) => id.isEmpty);

      Doctor? cachedDoctor;
      for (final doctor in module.controller.allDoctors) {
        final doctorIds = <String>{
          doctor.localId,
          doctor.serverId ?? '',
          doctor.clientGeneratedId ?? '',
        }..removeWhere((id) => id.isEmpty);
        if (doctorIds.any(ids.contains)) {
          cachedDoctor = doctor;
          break;
        }
      }

      final store = module.controller.creationStore;
      if (cachedDoctor == null || store == null) {
        Get.snackbar(
          'Doctor unavailable offline',
          TTexts.uiTextThisDoctorIsNotPresentInTheOffline,
          backgroundColor: TColors.materialRed,
          colorText: TColors.white,
        );
        return false;
      }

      // Reuse the existing encrypted doctor image outbox. Its normal sync
      // uploads the doctor first when necessary, then posts the image with
      // the resolved server doctor ID before schedules and confirmations.
      await store.queueImage(doctor: cachedDoctor, image: image);
      await module.controller.reloadCreations();
      return true;
    } catch (error, stackTrace) {
      debugPrint('VisitDoctorScreen: Offline geo image save failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      if (module != null) await module.dispose();
    }
  }

  Future<bool> _isDoctorVisitOffline() async {
    if (_visitListController.offlineMode) return true;
    try {
      final connectivity = await Connectivity().checkConnectivity();
      return connectivity.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  // ... [Keep other existing imports] ...

  Future<File?> _captureAndProcessImage(BuildContext context) async {
    // 1. Capture Image
    final result = await CameraLocationService.captureImageWithLocation();
    if (result == null) return null;

    // 2. Show Loader
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: TTexts.uiTextProcessing,
      text: TTexts.uiTextAddingWatermarkLogo,
      disableBackBtn: true,
    );

    try {
      final File originalFile = result.image;
      final bytes = await originalFile.readAsBytes();
      final img.Image? targetImage = img.decodeImage(bytes);

      if (targetImage != null) {
        // --- CONFIGURATION ---
        // TODO: REPLACE WITH YOUR EXACT LOGO PATH
        const String logoAssetPath = "assets/logos/logo.png";

        // 3. Prepare Data
        String dateText = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
        String latText = "Lat: ${result.latitude.toStringAsFixed(5)}";
        String lngText = "Lng: ${result.longitude.toStringAsFixed(5)}";

        // 4. Draw Black Background Bar (Bottom 15% of image)
        int barHeight = (targetImage.height * 0.15).toInt();
        int barY = targetImage.height - barHeight;

        img.fillRect(
          targetImage,
          x1: 0,
          y1: barY,
          x2: targetImage.width,
          y2: targetImage.height,
          color: img.ColorRgb8(0, 0, 0), // Black
        );

        // 5. Draw Logo (Try to load from assets)
        try {
          final ByteData assetData = await rootBundle.load(logoAssetPath);
          final Uint8List logoBytes = assetData.buffer.asUint8List();
          img.Image? logo = img.decodeImage(logoBytes);

          if (logo != null) {
            // Resize logo to fit inside the bar (padding 10px)
            int logoHeight = barHeight - 20;
            img.Image resizedLogo = img.copyResize(logo, height: logoHeight);

            // Draw Logo on the left side
            img.compositeImage(targetImage, resizedLogo,
                dstX: 20, dstY: barY + 10);
          }
        } catch (e) {
          print("Logo not found or could not be loaded: $e");
          // Proceed without logo if it fails
        }

        // 6. Draw Text (White color)
        // We use the simple bitmap font provided by the package
        int textX = 150; // Offset text to the right of the logo
        int textY = barY + 20;
        int lineHeight = 30;

        // Draw Date
        img.drawString(
          targetImage,
          "Date: $dateText",
          font: img.arial24,
          x: textX,
          y: textY,
          color: img.ColorRgb8(255, 255, 255), // White
        );

        // Draw Lat
        img.drawString(
          targetImage,
          latText,
          font: img.arial24,
          x: textX,
          y: textY + lineHeight,
          color: img.ColorRgb8(255, 255, 255),
        );

        // Draw Lng
        img.drawString(
          targetImage,
          lngText,
          font: img.arial24,
          x: textX,
          y: textY + (lineHeight * 2),
          color: img.ColorRgb8(255, 255, 255),
        );

        // 7. Save File
        final newImageBytes = img.encodeJpg(targetImage, quality: 90);
        final File watermarkedFile = File(originalFile.path)
          ..writeAsBytesSync(newImageBytes);

        return watermarkedFile;
      }
      return originalFile; // Fallback
    } catch (e) {
      print("Watermark Error: $e");
      return null;
    } finally {
      // 8. Close Loader
      Navigator.of(context, rootNavigator: true).pop();
    }
  } // 3. API CALL (MULTIPART)

// 3. FINAL CONFIRM VISIT (Simplified)
  void _confirmVisit(BuildContext context, VisitSalesLogModel doctorVisit,
      List<String> selectedProducts) async {
    bool confirmed = false;

    await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: TTexts.confirmVisit,
      text: TTexts.uiTextSubmitThisVisit,
      confirmBtnText: TTexts.yes,
      onConfirmBtnTap: () {
        confirmed = true;
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    if (!confirmed) return;

    QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: TTexts.uiTextSubmitting);

    try {
      debugPrint(
          "VisitConfirmationController: ======================================");
      debugPrint("VisitConfirmationController: Confirm Visit Started");
      debugPrint(
          "VisitConfirmationController: Visit ID = ${doctorVisit.doctorId}");
      debugPrint(
          "VisitConfirmationController: Selected Products = $selectedProducts");

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint(
          "VisitConfirmationController: Current Latitude = ${pos.latitude}");
      debugPrint(
          "VisitConfirmationController: Current Longitude = ${pos.longitude}");

      final uri = Uri.parse(
        '${THttpHelper.baseUrl}/doctor-visits/bulk-confirm',
      );

      debugPrint("VisitConfirmationController: API URL = $uri");

      final requestBody = {
        'userLatitude': pos.latitude,
        'userLongitude': pos.longitude,
        'notes': "",
        'productIds': selectedProducts,
      };

      debugPrint(
          "VisitConfirmationController: Request Body = ${jsonEncode(requestBody)}");

      final response = await VisitConfirmationService(
        // Reuse the screen's listener-backed outbox service so the newly
        // queued confirmation is uploaded by the same lifecycle-managed
        // worker and its client is disposed with the screen.
        syncTrigger: _uploadCoordinator.syncAll,
      ).confirmVisit(
        visitId: doctorVisit.id,
        doctorLatitude: doctorVisit.doctor!.latitude!,
        doctorLongitude: doctorVisit.doctor!.longitude!,
        position: pos,
        productIds: selectedProducts,
        localScheduleId: doctorVisit.localScheduleId,
        forceOffline: _visitListController.offlineMode,
      );

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      debugPrint(
          "VisitConfirmationController: Status Code = ${response.statusCode}");

      debugPrint("VisitConfirmationController: Response = ${response.body}");

      if (response.statusCode == 400) {
        final body = jsonDecode(response.body);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: TTexts.uiTextVisitConfirmationFailed,
          text: body["errors"]?[0]?["message"] ??
              body["message"] ??
              "Unable to confirm visit.",
        );

        return;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);

        debugPrint("VisitConfirmationController: Parsed Response = $body");

        if (body['status'] != false && body['success'] != false) {
          final bool isOffline = body['offline'] == true;
          final bool isQueued = body['queued'] == true;

          Get.snackbar(
            isQueued
                ? "Queued for Sync"
                : (isOffline ? "Saved Offline" : "Success"),
            body['message'] ??
                (isQueued
                    ? "Visit saved locally and queued for sync."
                    : (isOffline
                        ? "Visit saved offline."
                        : "Visit Confirmed!")),
            backgroundColor: TColors.success,
            colorText: TColors.white,
          );

          if (isQueued) {
            await _visitListController.refreshPendingVisits();
            await _visitListController.fetchSalesList(
              filter: _selectedFilter,
              startDate: _selectedDateRange?.start,
              endDate: _selectedDateRange?.end,
            );
          } else if (isOffline) {
            await _visitListController.refreshPendingVisits();
          } else {
            await _visitListController.fetchSalesList(
              filter: _selectedFilter,
              startDate: _selectedDateRange?.start,
              endDate: _selectedDateRange?.end,
            );
          }
        } else {
          debugPrint("VisitConfirmationController: API returned status=false");

          debugPrint(
              "VisitConfirmationController: Message = ${body['message']}");

          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: body['message'] ?? "Error",
          );
        }
      } else {
        debugPrint(
            "VisitConfirmationController: Server Error ${response.statusCode}");

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Server Error: ${response.statusCode}",
        );
      }
    } catch (e, stackTrace) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      debugPrint("VisitConfirmationController: Exception = $e");

      debugPrint("VisitConfirmationController: StackTrace = $stackTrace");

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: TTexts.uiTextUnableToSaveVisit,
        text: TTexts.uiTextVisitCouldNotBeSavedPleaseTryAgain,
      );
    } finally {
      debugPrint("VisitConfirmationController: Confirm Visit Finished");

      debugPrint(
          "VisitConfirmationController: ======================================");
    }
  }

  // 2. NEW: UPLOAD DOCTOR GEO IMAGE
  Future<bool> _uploadDoctorGeoImage(
      BuildContext context, String doctorId, File imageFile) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: TTexts.uiTextUploading,
      text: TTexts.uiTextPleaseWait,
    );

    try {
      String? token = await authManager.getAuthToken();

      if (token == null || token.isEmpty) {
        Navigator.of(context, rootNavigator: true).pop();
        Get.snackbar(
            "Error", TTexts.uiTextAuthenticationFailedPleaseLoginAgain);
        return false;
      }

      var uri = Uri.parse('${THttpHelper.baseUrl}/doctors/$doctorId/geo-image');
      var request = http.MultipartRequest('POST', uri);

      // 1. Authorization Header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // 2. Add File with Explicit ContentType
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      var multipartFile = http.MultipartFile(
        'geo_image',
        stream,
        length,
        filename: 'geo_image.jpg', // Explicit filename
        contentType: MediaType(
            'image', 'jpeg'), // Explicit Type (Fixes your server error)
      );

      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      Navigator.of(context, rootNavigator: true).pop(); // Close Loader

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", TTexts.uiTextPhotoUploaded,
            backgroundColor: TColors.primary, colorText: TColors.white);
        return true;
      } else {
        // Show server response for debugging
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Upload Failed: ${response.statusCode}\n${response.body}",
        );
        return false;
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      QuickAlert.show(
          context: context, type: QuickAlertType.error, text: "Error: $e");
      return false;
    }
  }

  Future<bool?> _showImagePreviewDialog(
      BuildContext context, String doctorId, File imageFile) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Force user to choose
      builder: (BuildContext ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content height
              children: [
                const Text(TTexts.uiTextPreview,
                    style: TextStyle(
                        fontSize: TSizes.v18, fontWeight: FontWeight.bold)),
                const SizedBox(height: TSizes.v10),

                // --- THE IMAGE PREVIEW ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    imageFile,
                    height:
                        TSizes.v250, // Fixed height for the "small box" feel
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: TSizes.v20),

                // --- BUTTONS ---
                Row(
                  children: [
                    // RETAKE BUTTON
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(
                              false); // Returns False -> Triggers Retake Loop
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TColors.materialRed,
                          side: const BorderSide(color: TColors.materialRed),
                        ),
                        child: const Text(TTexts.uiTextRetake),
                      ),
                    ),
                    const SizedBox(width: TSizes.v10),

                    // SUBMIT BUTTON
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Call your existing upload function
                          bool success = await _uploadDoctorGeoImage(
                              context, doctorId, imageFile);

                          if (success) {
                            Navigator.of(ctx).pop(
                                true); // Returns True -> Moves to Next Step
                          }
                          // If fail, dialog stays open so they can try again
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: TColors.white,
                        ),
                        child: const Text(TTexts.submit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAssignAreaBottomSheet(
    BuildContext context,
    VisitSalesLogModel doctorVisit,
  ) async {
    final allAreas = await _doctorListController.fetchAreas();

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
                      onTap: () async {
                        Get.back();

                        await _doctorListController.assignAreaToDoctor(
                          doctorId: doctorVisit.doctorId,
                          areaId: area["id"],
                        );

                        await _visitListController.fetchSalesList(
                          filter: _selectedFilter,
                          startDate: _selectedDateRange?.start,
                          endDate: _selectedDateRange?.end,
                        );

                        final updatedVisit =
                            _visitListController.salesList.firstWhere(
                          (e) => e.id == doctorVisit.id,
                        );

                        _handleVisitConfirmationFlow(
                          context,
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
                    doctorVisit.doctor!,
                    doctorVisit,
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
    VisitDoctor doctor,
    String pincode,
    List offices,
    VisitSalesLogModel doctorVisit,
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
                        doctorVisit,
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
    VisitDoctor doctor,
    Map office,
    String pincode,
    VisitSalesLogModel doctorVisit,
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
                              await _doctorListController.createNewArea(
                            name: areaController.text.trim(),
                            pincode: pincode,
                            postOffice: office['Name'],
                            headOfficeId: doctor.headOfficeId!,
                          );

                          if (createdAreaId == null) return;

// Assign Area
                          await _doctorListController.assignAreaToDoctor(
                            doctorId: doctor.id,
                            areaId: createdAreaId,
                          );

// CLOSE CREATE AREA DIALOG
                          Get.back();

// Give UI time to close dialog
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );

// Refresh list
                          await _visitListController.fetchSalesList(
                            filter: _selectedFilter,
                            startDate: _selectedDateRange?.start,
                            endDate: _selectedDateRange?.end,
                          );

// Find updated visit
                          final updatedVisit =
                              _visitListController.salesList.firstWhere(
                            (e) => e.id == doctorVisit.id,
                          );

// CONTINUE FLOW
                          Future.microtask(() {
                            _handleVisitConfirmationFlow(
                              context,
                              updatedVisit,
                            );
                          });
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

  void _showAddAreaDialog(
    VisitDoctor doctor,
    VisitSalesLogModel doctorVisit,
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
                      doctorVisit,
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
}
