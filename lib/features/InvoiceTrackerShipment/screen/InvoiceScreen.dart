import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/features/InvoiceTrackerShipment/screen/send_email_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../../../utils/http/http_client.dart';
import '../controller/InvoiceController.dart';
import 'PdfViewerPage.dart';
import 'WebviewPage.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

// --- PROJECT IMPORTS ---
// Replace these with your actual paths if they differ

// ==============================================================================
// 1. T-COLORS & THEME DEFINITIONS
// ==============================================================================

class AppTheme {
  static const Color primary = TColors.primary;
  static const Color background =
      TColors.hex_FFF8FAFC; // Slightly lighter slate for better contrast
  static const Color surface = TColors.white;
  static const Color textDark = TColors.hex_FF0F172A;
  static const Color textGrey = TColors.hex_FF64748B;
  static const Color border = TColors.hex_FFE2E8F0;

  // Text Styles
  static TextStyle get header => const TextStyle(
      fontSize: TSizes.v26,
      fontWeight: FontWeight.w800,
      color: TColors.white,
      letterSpacing: -0.5);
  static TextStyle get subHeader => const TextStyle(
      fontSize: TSizes.v14,
      fontWeight: FontWeight.w500,
      color: TColors.white70);
  static TextStyle get cardTitle => const TextStyle(
      fontSize: TSizes.v16, fontWeight: FontWeight.w700, color: textDark);
  static TextStyle get cardSubtitle => const TextStyle(
      fontSize: TSizes.v13, fontWeight: FontWeight.w500, color: textGrey);

  static const double pagePadding = 20.0;
  static const double borderRadius = 20.0;
}

// ==============================================================================
// 2. MAIN INVOICE SCREEN
// ==============================================================================

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with TickerProviderStateMixin {
  // --- Controllers & Services ---
  final InvoiceController _dataController =
      Get.put(InvoiceController(baseUrl: '', bearerToken: ''));
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Dio _dio = Dio();

  // --- Animation Controllers ---
  late AnimationController _headerAnimController;
  late Animation<double> _fadeAnimation;
  late AnimationController _truckAnimController;

  // --- State Variables ---
  DateTimeRange? _dateRange;
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchInitialData();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _dataController.loadMoreInvoices();
    }
  }

  void _setupAnimations() {
    // 1. Header Fade In
    _headerAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(
        parent: _headerAnimController, curve: Curves.easeOutCubic);
    _headerAnimController.forward();

    // 2. Truck Animation (Looping)
    _truckAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  void _fetchInitialData() {
    Future.delayed(Duration.zero, () {
      if (!Get.isRegistered<InvoiceController>()) {
        Get.put(InvoiceController(baseUrl: '', bearerToken: ''));
      }
      _dataController.fetchInvoices();
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _truckAnimController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIC: TRACKING (FIXED) ---
  void _handleTrack(String? url) {
    if (url == null || url.trim().isEmpty) {
      Get.snackbar(
        "Tracking Unavailable",
        TTexts.uiTextTrackingLinkIsNotAvailableForThisInvoice,
        backgroundColor: TColors.materialOrange.withOpacity(0.1),
        colorText: TColors.materialOrange800,
        icon: const Icon(Icons.warning_amber_rounded,
            color: TColors.materialOrange),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    // Navigate to WebView
    Get.to(() => WebViewPage(url: url, title: TTexts.uiTextTrackShipment),
        transition: Transition.cupertino);
  }

  // --- LOGIC: FILTERING ---
  List<dynamic> get _filteredInvoices {
    final query = _searchController.text.trim().toLowerCase();

    // Sort by Date Descending (Newest first)
    final List<dynamic> sortedList = List.from(_dataController.invoices);
    try {
      sortedList.sort((a, b) {
        DateTime dateA =
            DateTime.tryParse(a.invoiceDate ?? '') ?? DateTime(2000);
        DateTime dateB =
            DateTime.tryParse(b.invoiceDate ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
    } catch (_) {}

    return sortedList.where((inv) {
      // 1. Search Query
      final party = (inv.partyName ?? inv.stockist?.firmName ?? '')
          .toString()
          .toLowerCase();
      final invoiceNum = (inv.invoiceNumber ?? '').toString().toLowerCase();
      final matchesQuery =
          query.isEmpty || party.contains(query) || invoiceNum.contains(query);

      // 2. Status
      final status = (inv.status ?? '').toString().toLowerCase();
      final matchesStatus = _statusFilter == 'All' ||
          status.contains(_statusFilter.toLowerCase());

      // 3. Date Range
      bool matchesDate = true;
      if (_dateRange != null && inv.invoiceDate != null) {
        try {
          final date = DateTime.parse(inv.invoiceDate.toString());
          matchesDate = date.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1))) &&
              date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
        } catch (_) {}
      }

      return matchesQuery && matchesStatus && matchesDate;
    }).toList();
  }

  // --- LOGIC: DOWNLOAD ---
  /*Future<void> _handleDownload(String id, String name) async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      // Add more specific permission logic for Android 13+ if needed (Photos/Videos)
    }

    Get.bottomSheet(
      DownloadProgressSheet(dio: _dio, invoiceId: id, fileName: name),
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))
      ),
    );
  }*/

  Future<void> _handleView(
    String invoiceId,
    String fileName,
  ) async {
    try {
      final auth = AuthManager();
      final token = await auth.getAuthToken();

      final response = await _dio.get(
        '${THttpHelper.baseUrl}/invoice-tracking/$invoiceId/signed-url',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final pdfUrl = response.data['url'];

        Get.to(
          () => PdfViewerPage(
            pdfUrl: pdfUrl,
            fileName: fileName.isEmpty ? "invoice.pdf" : fileName,
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  // --- LOGIC: QUICK VIEW ---
  void _showQuickView(dynamic invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.transparent,
      builder: (_) => _QuickViewSheet(invoice: invoice),
    );
  }

  // ==============================================================================
  // 3. UI BUILDER
  // ==============================================================================

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: TSizes.v0,
        backgroundColor: TColors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: TSizes.v0,
      ),
      body: Stack(
        children: [
          // Background Decor
          const _BackgroundBlobs(),

          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // A. Header with Truck Animation
              // ... inside CustomScrollView slivers:

// A. Header (Unchanged call)
              SliverAppBar(
                expandedHeight:
                    320, // Increased slightly to accommodate the margin
                floating: false,
                pinned: true,
                backgroundColor:
                    TColors.transparent, // Important: Keep transparent
                elevation: TSizes.v0,
                flexibleSpace: _buildDashboardHeader(),
                actions: [
                  IconButton(
                      onPressed: () {},
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: TColors.white24, shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_none_rounded,
                            color: TColors.white),
                      )),
                  const SizedBox(width: TSizes.v16),
                ],
              ),

// B. Stats Dashboard (UPDATED)
              SliverToBoxAdapter(
                // Removed Transform.translate. The header's empty bottom space handles the overlap.
                child: Transform.translate(
                  offset: const Offset(
                      0, -50), // Pull up into the transparent gap we created
                  child: Obx(() => _DashboardStatsGrid(
                      invoices: _dataController.invoices.toList())),
                ),
              ),

// ... rest of the slivers

              // C. Sticky Search Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickySearchBarDelegate(
                  minHeight: TSizes.v80,
                  maxHeight: TSizes.v80,
                  child: _buildSearchBar(),
                ),
              ),

              // D. Content
              Obx(() {
                if (_dataController.loading.value) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.pagePadding),
                    sliver: _buildShimmerLoading(isTablet),
                  );
                }

                if (_dataController.error.isNotEmpty) {
                  return SliverFillRemaining(child: _buildErrorState());
                }

                final list = _filteredInvoices;
                if (list.isEmpty) {
                  return SliverFillRemaining(child: _buildEmptyState());
                }

                // Show Results Count
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.pagePadding),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        "Showing ${list.length} Invoices",
                        style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }),

              // E. List/Grid (UPDATED CARD)
              Obx(() {
                final list = _filteredInvoices;
                if (_dataController.loading.value || list.isEmpty)
                  return const SliverToBoxAdapter(child: SizedBox());

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.pagePadding),
                  sliver: isTablet
                      ? _buildTabletGrid(list)
                      : _buildMobileList(list),
                );
              }),

              /* const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom Padding

              Obx(() {
                final list = _filteredInvoices;

                if (_dataController.loading.value || list.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.pagePadding,
                  ),
                  sliver: isTablet
                      ? _buildTabletGrid(list)
                      : _buildMobileList(list),
                );
              }),*/

// ADD THIS BLOCK HERE
              SliverToBoxAdapter(
                child: Obx(() {
                  if (!_dataController.isLoadingMore.value) {
                    return const SizedBox();
                  }

                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: TSizes.v100),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _dataController.fetchInvoices,
        backgroundColor: AppTheme.primary,
        elevation: TSizes.v8,
        icon: const Icon(Icons.sync_rounded, color: TColors.white),
        label: const Text(TTexts.uiTextSync,
            style:
                TextStyle(color: TColors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- HEADER WIDGETS ---

  Widget _buildDashboardHeader() {
    return FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      background: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The Blue Background (With bottom margin to create overlap space)
          Container(
            margin:
                const EdgeInsets.only(bottom: 30), // Leave space for the card
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [TColors.primary_shade900, TColors.primary_shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),

          // 2. The Truck Animation (Inside the blue area)
          Positioned(
            top: 0, left: 0, right: 0, bottom: 30, // Match margin above
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: _DeliveryTruckAnimation(controller: _truckAnimController),
            ),
          ),

          // 3. Text Content
          Positioned(
            left: 24,
            bottom: 80, // Adjusted for the new margin
            right: 150,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: TColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: TColors.white.withOpacity(0.1))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_outlined,
                            color: TColors.white, size: TSizes.v14),
                        const SizedBox(width: TSizes.v5),
                        const Text(TTexts.uiTextSalesExecutive,
                            style: TextStyle(
                                color: TColors.white,
                                fontSize: TSizes.v10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.v12),
                  Text(TTexts.uiTextInvoiceDashboard, style: AppTheme.header),
                  const SizedBox(height: TSizes.v8),
                  Text(
                    TTexts.uiTextTrackShipmentsManageAccounts,
                    style: AppTheme.subHeader,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.pagePadding, vertical: 10),
      color: AppTheme.background.withOpacity(0.95),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: TSizes.v50,
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: TColors.primary.withOpacity(0.08),
                      blurRadius: TSizes.v15,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: TColors.primary),
                  hintText: TTexts.uiTextSearchPartyInv,
                  hintStyle: TextStyle(
                      color: TColors.materialGrey400,
                      fontWeight: FontWeight.normal),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: TSizes.v18),
                          onPressed: () =>
                              setState(() => _searchController.clear()))
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: TSizes.v12),
          GestureDetector(
            onTap: () => _showFilterSheet(),
            child: Container(
              height: TSizes.v50,
              width: TSizes.v50,
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: TColors.primary.withOpacity(0.3),
                      blurRadius: TSizes.v10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.tune_rounded, color: TColors.white),
                  if (_statusFilter != 'All' || _dateRange != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                          width: TSizes.v8,
                          height: TSizes.v8,
                          decoration: const BoxDecoration(
                              color: TColors.secondary,
                              shape: BoxShape.circle)),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTENT BUILDERS ---

  Widget _buildMobileList(List<dynamic> list) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final inv = list[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _DetailedInvoiceCard(
              invoice: inv,
              onDownload: () => _handleView(
                  inv.id, inv.invoiceImagePublicId ?? 'invoice.pdf'),
              // FIXED: Uses the dedicated logic handler
              onTrack: () => _handleTrack(inv.trackingLink),
              onTap: () => _showQuickView(inv),
              onMail: () => _handleMail(inv),
            ),
          );
        },
        childCount: list.length,
      ),
    );
  }

  Widget _buildTabletGrid(List<dynamic> list) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        mainAxisSpacing: TSizes.v20,
        crossAxisSpacing: TSizes.v20,
        // UPDATED: Increased from 280 to 360 to prevent bottom overflow
        // Content calculation: ~350px needed including padding
        mainAxisExtent: 600,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final inv = list[index];
          return _DetailedInvoiceCard(
            invoice: inv,
            onDownload: () => _handleView(inv.id, ''),
            onTrack: () => _handleTrack(inv.trackingLink),
            onTap: () => _showQuickView(inv),
            onMail: () => _handleMail(inv),
          );
        },
        childCount: list.length,
      ),
    );
  }

  // --- FILTER MODAL ---
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.transparent,
      builder: (ctx) => _AdvancedFilterSheet(
        currentStatus: _statusFilter,
        currentDateRange: _dateRange,
        onApply: (status, range) {
          setState(() {
            _statusFilter = status;
            _dateRange = range;
          });
        },
      ),
    );
  }

  // --- STATE WIDGETS ---

  Widget _buildShimmerLoading(bool isTablet) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: TColors.materialGrey300,
            highlightColor: TColors.materialGrey100,
            child: Container(
              height: TSizes.v200,
              decoration: BoxDecoration(
                  color: TColors.white,
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        childCount: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: TColors.materialGrey.withOpacity(0.1),
                    blurRadius: TSizes.v20)
              ],
            ),
            child: const Icon(Icons.search_off_rounded,
                size: TSizes.v60, color: TColors.primary_shade200),
          ),
          const SizedBox(height: TSizes.v20),
          Text(TTexts.uiTextNoInvoicesFound,
              style: AppTheme.cardTitle.copyWith(fontSize: TSizes.v18)),
          const SizedBox(height: TSizes.v8),
          Text(TTexts.uiTextTryAdjustingYourSearchOrFilters,
              style: AppTheme.cardSubtitle),
          const SizedBox(height: TSizes.v20),
          TextButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _statusFilter = 'All';
                _dateRange = null;
              });
            },
            child: const Text(TTexts.uiTextClearAllFilters,
                style: TextStyle(color: TColors.primary)),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: TSizes.v60, color: TColors.primary_shade300),
          const SizedBox(height: TSizes.v16),
          const Text(TTexts.uiTextConnectionFailed,
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextButton.icon(
            onPressed: _dataController.fetchInvoices,
            icon: const Icon(Icons.refresh),
            label: const Text(TTexts.uiTextRetry),
          )
        ],
      ),
    );
  }

  Future<void> _handleMail(dynamic invoice) async {
    final email = invoice.stockist?.emailAddress;

    if (email == null || email.trim().isEmpty || email == "N/A") {
      Get.snackbar(
        "Email Missing",
        TTexts.uiTextNoEmailProvidedForThisStockist,
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      await _dataController.sendInvoiceEmail(
        invoice.id,
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        "Success",
        TTexts.uiTextInvoiceEmailSentSuccessfully,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// ==============================================================================
// 4. ANIMATION & VISUAL COMPONENTS
// ==============================================================================

// --- A. DELIVERY TRUCK ANIMATION (UNCHANGED) ---
class _DeliveryTruckAnimation extends StatelessWidget {
  final AnimationController controller;
  const _DeliveryTruckAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Positioned(
                  top: 40,
                  right: -50 + (width * 0.5 * controller.value),
                  child: Icon(Icons.cloud,
                      color: TColors.white.withOpacity(0.1), size: TSizes.v60),
                );
              },
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Positioned(
                  top: 80,
                  right: 20 + (width * 0.3 * controller.value),
                  child: Icon(Icons.cloud,
                      color: TColors.white.withOpacity(0.05), size: TSizes.v40),
                );
              },
            ),
            Positioned(
              right: 0,
              bottom: 60,
              width: width * 0.6,
              height: TSizes.v2,
              child: Container(
                color: TColors.white.withOpacity(0.2),
              ),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                double rightPos = -50 + (controller.value * (width * 0.8));
                return Positioned(
                  bottom: 60,
                  right: rightPos,
                  child: Opacity(
                    opacity:
                        rightPos > width * 0.5 ? 0.0 : 1.0 - controller.value,
                    child: Transform(
                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: TColors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: TColors.pureBlack.withOpacity(0.1),
                                  blurRadius: TSizes.v10,
                                  offset: const Offset(5, 5))
                            ]),
                        child: const Icon(Icons.local_shipping_rounded,
                            color: TColors.primary, size: TSizes.v32),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// --- B. DASHBOARD STATS GRID (NEW & IMPROVED) ---
class _DashboardStatsGrid extends StatelessWidget {
  final List<dynamic> invoices;
  const _DashboardStatsGrid({required this.invoices});

  @override
  Widget build(BuildContext context) {
    final total = invoices.length;
    final delivered = invoices
        .where((i) => i.status.toString().toLowerCase().contains('delivered'))
        .length;
    final cancelled = invoices
        .where((i) => i.status.toString().toLowerCase().contains('cancel'))
        .length;
    final pending = total - delivered - cancelled;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: TColors.primary.withOpacity(0.08),
              blurRadius: TSizes.v20,
              offset: const Offset(0, 10)),
          BoxShadow(
              color: TColors.pureBlack.withOpacity(0.02),
              blurRadius: TSizes.v5,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Total & Delivered
          Row(
            children: [
              _buildStatItem("Total Invoices", total, TColors.info,
                  Icons.receipt_long_rounded),
              _buildDivider(),
              _buildStatItem("Delivered", delivered, TColors.success,
                  Icons.task_alt_rounded),
            ],
          ),
          const SizedBox(height: TSizes.v20),
          Divider(
              height: TSizes.v1,
              thickness: TSizes.v1,
              color: TColors.materialGrey100),
          const SizedBox(height: TSizes.v20),
          // Row 2: Pending & Cancelled
          Row(
            children: [
              _buildStatItem("Pending", pending, TColors.secondary,
                  Icons.hourglass_top_rounded),
              _buildDivider(),
              _buildStatItem("Cancelled", cancelled, TColors.primary,
                  Icons.cancel_presentation_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: TSizes.v22),
          ),
          const SizedBox(width: TSizes.v12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: TSizes.v20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: TSizes.v11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textGrey),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: TSizes.v40,
      width: TSizes.v1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: TColors.materialGrey200,
    );
  }
}

// --- C. DETAILED INVOICE CARD (NEW & IMPROVED) ---
class _DetailedInvoiceCard extends StatelessWidget {
  final dynamic invoice;
  final VoidCallback onDownload;
  final VoidCallback onTrack;
  final VoidCallback onTap;
  final VoidCallback onMail;

  const _DetailedInvoiceCard({
    required this.invoice,
    required this.onDownload,
    required this.onTrack,
    required this.onTap,
    required this.onMail,
  });

  // ... (Keep _getStatusColor method same as before) ...
  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('deliver')) return TColors.success;
    if (status.contains('cancel')) return TColors.primary;
    if (status.contains('ship')) return TColors.info;
    return TColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    // ... (Keep variable extraction logic same as before) ...
    final status = (invoice.status ?? 'Pending').toString();
    final statusColor = _getStatusColor(status);
    final partyName =
        invoice.partyName ?? invoice.stockist?.firmName ?? 'Unknown Customer';
    final invoiceNum = invoice.invoiceNumber ?? 'N/A';
    final email = invoice.stockist?.emailAddress ?? 'No Email';
    final courier = invoice.courierCompanyName ?? 'Not Assigned';
    final awb = invoice.awbNumber ?? 'Pending';

    final forwarding =
        invoice.forwardingNotes != null && invoice.forwardingNotes.isNotEmpty
            ? invoice.forwardingNotes.first
            : null;

    final cases = forwarding?.cases?.toString() ?? "-";

    final weight = forwarding?.weight?.toString() ?? "-";

    DateTime date;
    try {
      date = DateTime.parse(invoice.invoiceDate ?? DateTime.now().toString());
    } catch (_) {
      date = DateTime.now();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: TColors.pureBlack.withOpacity(0.04),
                blurRadius: TSizes.v15,
                offset: const Offset(0, 8)),
          ],
          border: Border.all(color: AppTheme.border),
        ),
        // ADDED: ClipRRect ensures child elements don't bleed out of rounded corners
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            // ADDED: Min size ensures it takes minimum required space
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- 1. HEADER ---
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.05),
                  border: Border(
                      bottom: BorderSide(color: statusColor.withOpacity(0.1))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle,
                              size: TSizes.v8, color: statusColor),
                          const SizedBox(width: TSizes.v6),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                                fontSize: TSizes.v11,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(date),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: TSizes.v13,
                          color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),

              // --- 2. MAIN BODY ---
              Padding(
                // REDUCED vertical padding slightly from 16 to 14 to save space
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: TSizes.v44,
                      height: TSizes.v44,
                      decoration: BoxDecoration(
                        color: TColors.hex_FFF1F5F9,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.store_mall_directory_rounded,
                          color: AppTheme.textDark),
                    ),
                    const SizedBox(width: TSizes.v14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partyName,
                            style: const TextStyle(
                              fontSize: TSizes.v17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: TSizes.v4),
                          Text(
                            invoiceNum,
                            style: TextStyle(
                              color: TColors.materialGrey600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: TSizes.v12),
                          _infoTile(
                            Icons.email_outlined,
                            invoice.stockist?.emailAddress ?? "N/A",
                          ),
                          const SizedBox(height: TSizes.v6),
                          _infoTile(
                            Icons.phone_outlined,
                            invoice.stockist?.mobileNumber ?? "N/A",
                          ),
                          const SizedBox(height: TSizes.v6),
                          _infoTile(
                            Icons.location_on_outlined,
                            invoice.stockist?.registeredOfficeAddress ?? "N/A",
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- 3. LOGISTICS ---
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TColors.hex_FFF8FAFC,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TColors.materialGrey200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _detailBox(
                              "Courier",
                              courier,
                              Icons.local_shipping,
                            ),
                          ),
                          const SizedBox(width: TSizes.v10),
                          Expanded(
                            child: _detailBox(
                              "AWB",
                              awb,
                              Icons.confirmation_number_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.v10),
                      Row(
                        children: [
                          Expanded(
                            child: _detailBox(
                              "Cases",
                              cases,
                              Icons.inventory_2_outlined,
                            ),
                          ),
                          const SizedBox(width: TSizes.v10),
                          Expanded(
                            child: _detailBox(
                              "Weight",
                              weight,
                              Icons.scale_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const _TicketSeparator(),

              // --- 4. BUTTONS ---
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textDark,
                            side: BorderSide(color: TColors.materialGrey300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: onTrack,
                        icon: const Icon(Icons.map_outlined,
                            size: TSizes.v18, color: TColors.secondary),
                        label: const Text(TTexts.uiTextTrack),
                      ),
                    ),
                    const SizedBox(width: TSizes.v12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textDark,
                            side: BorderSide(color: TColors.materialGrey300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: onMail,
                        icon: const Icon(Icons.mail,
                            size: TSizes.v18, color: TColors.secondary),
                        label: const Text(TTexts.uiTextMail),
                      ),
                    ),
                    const SizedBox(width: TSizes.v12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: TColors.white,
                            elevation: TSizes.v0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: onDownload,
                        icon: const Icon(Icons.visibility_outlined,
                            size: TSizes.v18),
                        label: const Text(TTexts.uiTextView),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String value, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: TColors.materialGrey100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: TSizes.v14,
            color: TColors.primary,
          ),
        ),
        const SizedBox(width: TSizes.v8),
        Expanded(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: TSizes.v12,
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailBox(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.hex_FFF8FAFC,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TColors.materialGrey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: TSizes.v18,
            color: TColors.primary,
          ),
          const SizedBox(height: TSizes.v8),
          Text(
            label,
            style: const TextStyle(
              fontSize: TSizes.v11,
              color: TColors.materialGrey,
            ),
          ),
          const SizedBox(height: TSizes.v2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --- D. QUICK VIEW BOTTOM SHEET ---
class _QuickViewSheet extends StatelessWidget {
  final dynamic invoice;
  const _QuickViewSheet({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: TSizes.v40,
                height: TSizes.v4,
                decoration: BoxDecoration(
                    color: TColors.materialGrey300,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: TSizes.v24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TTexts.uiTextInvoiceDetails,
                  style: AppTheme.header.copyWith(
                      color: AppTheme.textDark, fontSize: TSizes.v22)),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          const SizedBox(height: TSizes.v10),
          _detailRow(
              "Party", invoice.partyName ?? invoice.stockist?.firmName ?? '-'),
          _detailRow("Number", "#${invoice.invoiceNumber}"),
          _detailRow("Date", invoice.invoiceDate ?? '-'),
          _detailRow("Status", invoice.status ?? '-'),
          _detailRow("Courier", invoice.courierCompanyName ?? '-'),
          _detailRow("AWB", invoice.awbNumber ?? 'Not Generated'),
          const SizedBox(height: TSizes.v20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              onPressed: () {
                Navigator.pop(context);
                // Trigger download or open logic
              },
              child: const Text(TTexts.uiTextOpenFullInvoice,
                  style: TextStyle(
                      color: TColors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: TSizes.v20),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: TColors.materialGrey, fontSize: TSizes.v14)),
          Flexible(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: TSizes.v16),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

// --- E. FILTER SHEET ---
class _AdvancedFilterSheet extends StatefulWidget {
  final String currentStatus;
  final DateTimeRange? currentDateRange;
  final Function(String, DateTimeRange?) onApply;

  const _AdvancedFilterSheet(
      {required this.currentStatus,
      required this.currentDateRange,
      required this.onApply});

  @override
  State<_AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<_AdvancedFilterSheet> {
  late String _status;
  DateTimeRange? _range;

  @override
  void initState() {
    _status = widget.currentStatus;
    _range = widget.currentDateRange;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        decoration: const BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: TSizes.v50,
                    height: TSizes.v5,
                    decoration: BoxDecoration(
                        color: TColors.materialGrey200,
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: TSizes.v24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(TTexts.uiTextFilterInvoices,
                    style: TextStyle(
                        fontSize: TSizes.v22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark)),
                TextButton(
                  onPressed: () => setState(() {
                    _status = 'All';
                    _range = null;
                  }),
                  child: const Text(TTexts.uiTextReset,
                      style: TextStyle(
                          color: TColors.primary, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: TSizes.v24),
            const Text(TTexts.uiTextSHIPMENTSTATUS,
                style: TextStyle(
                    fontSize: TSizes.v12,
                    fontWeight: FontWeight.w700,
                    color: TColors.materialGrey,
                    letterSpacing: 1)),
            const SizedBox(height: TSizes.v12),
            Wrap(
              spacing: TSizes.v12,
              runSpacing: TSizes.v12,
              children: ['All', 'Delivered', 'Pending', 'Cancelled'].map((e) {
                final isSelected = _status == e;
                return ChoiceChip(
                  label: Text(e),
                  selected: isSelected,
                  selectedColor: TColors.primary,
                  backgroundColor: TColors.materialGrey100,
                  labelStyle: TextStyle(
                      color: isSelected ? TColors.white : TColors.black87,
                      fontWeight: FontWeight.w600),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide.none),
                  onSelected: (_) => setState(() => _status = e),
                );
              }).toList(),
            ),
            const SizedBox(height: TSizes.v24),
            const Text(TTexts.uiTextDATERANGE,
                style: TextStyle(
                    fontSize: TSizes.v12,
                    fontWeight: FontWeight.w700,
                    color: TColors.materialGrey,
                    letterSpacing: 1)),
            const SizedBox(height: TSizes.v12),
            InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme:
                            ColorScheme.light(primary: TColors.primary),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => _range = picked);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      _range != null ? TColors.primary_shade50 : TColors.white,
                  border: Border.all(
                      color: _range != null
                          ? TColors.primary
                          : TColors.materialGrey300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: TSizes.v20,
                        color: _range != null
                            ? TColors.primary
                            : TColors.materialGrey),
                    const SizedBox(width: TSizes.v12),
                    Text(
                      _range == null
                          ? 'Select Date Range'
                          : '${DateFormat('MMM dd').format(_range!.start)} - ${DateFormat('MMM dd').format(_range!.end)}',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _range != null
                              ? TColors.primary
                              : TColors.materialGrey600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TSizes.v40),
            SizedBox(
              width: double.infinity,
              height: TSizes.v56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    elevation: TSizes.v5,
                    shadowColor: TColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  widget.onApply(_status, _range);
                  Navigator.pop(context);
                },
                child: const Text(TTexts.uiTextApplyResults,
                    style: TextStyle(
                        fontSize: TSizes.v16,
                        fontWeight: FontWeight.bold,
                        color: TColors.white)),
              ),
            ),
            const SizedBox(height: TSizes.v20),
          ],
        ),
      ),
    );
  }
}

// --- F. DOWNLOAD SHEET ---
class DownloadProgressSheet extends StatefulWidget {
  final Dio dio;
  final String invoiceId;
  final String fileName;

  const DownloadProgressSheet(
      {super.key,
      required this.dio,
      required this.invoiceId,
      required this.fileName});

  @override
  State<DownloadProgressSheet> createState() => _DownloadProgressSheetState();
}

class _DownloadProgressSheetState extends State<DownloadProgressSheet> {
  double _progress = 0.0;
  String _status = 'Initializing...';
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      final auth = AuthManager();
      final token = await auth.getAuthToken();
      final dir = await getApplicationDocumentsDirectory();
      // Ensure unique name to prevent overwrite issues during testing
      final uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}_${widget.fileName.isEmpty ? "invoice.pdf" : widget.fileName}';
      final savePath = '${dir.path}/$uniqueName';

      setState(() => _status = 'Generating Link...');
      final response = await widget.dio.get(
        '${THttpHelper.baseUrl}/invoice-tracking/${widget.invoiceId}/signed-url',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final url = response.data['url'];
        setState(() => _status = 'Downloading PDF...');

        await widget.dio.download(url, savePath,
            onReceiveProgress: (rec, total) {
          if (mounted && total != -1) {
            setState(() => _progress = rec / total);
          }
        });

        setState(() {
          _status = 'Complete!';
          _progress = 1.0;
        });
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
          OpenFilex.open(savePath);
        }
      } else {
        throw Exception("Server returned error");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Download Failed';
          _failed = true;
        });
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _failed
                      ? TColors.materialRed.withOpacity(0.1)
                      : TColors.primary_shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    _failed
                        ? Icons.error_outline
                        : Icons.cloud_download_rounded,
                    color: _failed ? TColors.materialRed : TColors.primary),
              ),
              const SizedBox(width: TSizes.v16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_failed ? "Error" : "Downloading...",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: TSizes.v16)),
                  Text(_status,
                      style: const TextStyle(
                          color: TColors.materialGrey, fontSize: TSizes.v12)),
                ],
              )
            ],
          ),
          const SizedBox(height: TSizes.v24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: TColors.materialGrey100,
              color: _failed ? TColors.materialRed : TColors.primary,
              minHeight: TSizes.v8,
            ),
          ),
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(TTexts.uiTextClose)),
            )
        ],
      ),
    );
  }
}

// ==============================================================================
// 5. HELPER CLASSES
// ==============================================================================

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickySearchBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_StickySearchBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _TicketSeparator extends StatelessWidget {
  const _TicketSeparator();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TSizes.v24,
      child: Stack(
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) => Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  (constraints.constrainWidth() / 8).floor(),
                  (index) => SizedBox(
                      width: TSizes.v4,
                      height: TSizes.v1,
                      child: DecoratedBox(
                          decoration:
                              BoxDecoration(color: TColors.materialGrey300))),
                ),
              ),
            ),
          ),
          Positioned(
            left: -10, top: 0, bottom: 0,
            child: CircleAvatar(
                backgroundColor: TColors.white,
                radius: TSizes.v10), // Matched to card bg
          ),
          Positioned(
            right: -10, top: 0, bottom: 0,
            child: CircleAvatar(
                backgroundColor: TColors.white,
                radius: TSizes.v10), // Matched to card bg
          ),
        ],
      ),
    );
  }
}

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: -50,
          child: Container(
            height: TSizes.v250,
            width: TSizes.v250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TColors.primary.withOpacity(0.03),
            ),
          ),
        ),
        Positioned(
          top: 400,
          right: -40,
          child: Container(
            height: TSizes.v200,
            width: TSizes.v200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TColors.secondary.withOpacity(0.03),
            ),
          ),
        ),
      ],
    );
  }
}
