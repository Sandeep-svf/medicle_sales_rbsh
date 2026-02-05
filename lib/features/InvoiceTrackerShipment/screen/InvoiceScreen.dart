// screens/invoice_screen.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

// --- PROJECT IMPORTS ---
// Replace these with your actual paths if they differ
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../../../utils/http/http_client.dart';
import '../controller/InvoiceController.dart';
import 'WebviewPage.dart';
// Note: Ensure your Invoice model is imported here if it's in a separate file
// import 'package:medicle_sales_rbsh/models/invoice_model.dart';

// ==============================================================================
// 1. T-COLORS & THEME DEFINITIONS
// ==============================================================================

class AppTheme {
  static const Color primary = TColors.primary;
  static const Color background = Color(0xFFF8FAFC); // Slightly lighter slate for better contrast
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGrey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  // Text Styles
  static TextStyle get header => const TextStyle(
      fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5);
  static TextStyle get subHeader => const TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70);
  static TextStyle get cardTitle => const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w700, color: textDark);
  static TextStyle get cardSubtitle => const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w500, color: textGrey);

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

class _InvoiceScreenState extends State<InvoiceScreen> with TickerProviderStateMixin {
  // --- Controllers & Services ---
  final InvoiceController _dataController = Get.put(InvoiceController(baseUrl: '', bearerToken: ''));
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
        "Tracking link is not available for this invoice yet.",
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[800],
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    // Navigate to WebView
    Get.to(() => WebViewPage(url: url, title: 'Track Shipment'), transition: Transition.cupertino);
  }

  // --- LOGIC: FILTERING ---
  List<dynamic> get _filteredInvoices {
    final query = _searchController.text.trim().toLowerCase();

    // Sort by Date Descending (Newest first)
    final List<dynamic> sortedList = List.from(_dataController.invoices);
    try {
      sortedList.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a.invoiceDate ?? '') ?? DateTime(2000);
        DateTime dateB = DateTime.tryParse(b.invoiceDate ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
    } catch (_) {}

    return sortedList.where((inv) {
      // 1. Search Query
      final party = (inv.partyName ?? inv.stockist?.firmName ?? '').toString().toLowerCase();
      final invoiceNum = (inv.invoiceNumber ?? '').toString().toLowerCase();
      final matchesQuery = query.isEmpty || party.contains(query) || invoiceNum.contains(query);

      // 2. Status
      final status = (inv.status ?? '').toString().toLowerCase();
      final matchesStatus = _statusFilter == 'All' || status.contains(_statusFilter.toLowerCase());

      // 3. Date Range
      bool matchesDate = true;
      if (_dateRange != null && inv.invoiceDate != null) {
        try {
          final date = DateTime.parse(inv.invoiceDate.toString());
          matchesDate = date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
              date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
        } catch (_) {}
      }

      return matchesQuery && matchesStatus && matchesDate;
    }).toList();
  }

  // --- LOGIC: DOWNLOAD ---
  Future<void> _handleDownload(String id, String name) async {
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
  }

  // --- LOGIC: QUICK VIEW ---
  void _showQuickView(dynamic invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
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
                expandedHeight: 320, // Increased slightly to accommodate the margin
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent, // Important: Keep transparent
                elevation: 0,
                flexibleSpace: _buildDashboardHeader(),
                actions: [
                  IconButton(
                      onPressed: () {},
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                      )
                  ),
                  const SizedBox(width: 16),
                ],
              ),

// B. Stats Dashboard (UPDATED)
              SliverToBoxAdapter(
                // Removed Transform.translate. The header's empty bottom space handles the overlap.
                child: Transform.translate(
                  offset: const Offset(0, -50), // Pull up into the transparent gap we created
                  child: Obx(() => _DashboardStatsGrid(invoices: _dataController.invoices.toList())),
                ),
              ),

// ... rest of the slivers



              // C. Sticky Search Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickySearchBarDelegate(
                  minHeight: 80,
                  maxHeight: 80,
                  child: _buildSearchBar(),
                ),
              ),

              // D. Content
              Obx(() {
                if (_dataController.loading.value) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
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
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        "Showing ${list.length} Invoices",
                        style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }),

              // E. List/Grid (UPDATED CARD)
              Obx(() {
                final list = _filteredInvoices;
                if (_dataController.loading.value || list.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
                  sliver: isTablet
                      ? _buildTabletGrid(list)
                      : _buildMobileList(list),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom Padding
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _dataController.fetchInvoices,
        backgroundColor: AppTheme.primary,
        elevation: 8,
        icon: const Icon(Icons.sync_rounded, color: Colors.white),
        label: const Text('Sync', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            margin: const EdgeInsets.only(bottom: 30), // Leave space for the card
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
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1))
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_outlined, color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        const Text("Sales Executive", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Invoice\nDashboard', style: AppTheme.header),
                  const SizedBox(height: 8),
                  Text(
                    'Track shipments & \nmanage accounts.',
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
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding, vertical: 10),
      color: AppTheme.background.withOpacity(0.95),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: TColors.primary.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded, color: TColors.primary),
                  hintText: 'Search Party, Inv #...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchController.clear()))
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showFilterSheet(),
            child: Container(
              height: 50, width: 50,
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: TColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.tune_rounded, color: Colors.white),
                  if (_statusFilter != 'All' || _dateRange != null)
                    Positioned(
                      top: 12, right: 12,
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: TColors.secondary, shape: BoxShape.circle)),
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
              onDownload: () => _handleDownload(inv.id, inv.invoiceImagePublicId ?? 'invoice.pdf'),
              // FIXED: Uses the dedicated logic handler
              onTrack: () => _handleTrack(inv.trackingLink),
              onTap: () => _showQuickView(inv),
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
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        // UPDATED: Increased from 280 to 360 to prevent bottom overflow
        // Content calculation: ~350px needed including padding
        mainAxisExtent: 360,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final inv = list[index];
          return _DetailedInvoiceCard(
            invoice: inv,
            onDownload: () => _handleDownload(inv.id, ''),
            onTrack: () => _handleTrack(inv.trackingLink),
            onTap: () => _showQuickView(inv),
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
      backgroundColor: Colors.transparent,
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
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 200,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20)],
            ),
            child: const Icon(Icons.search_off_rounded, size: 60, color: TColors.primary_shade200),
          ),
          const SizedBox(height: 20),
          Text("No Invoices Found", style: AppTheme.cardTitle.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text("Try adjusting your search or filters.", style: AppTheme.cardSubtitle),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _statusFilter = 'All';
                _dateRange = null;
              });
            },
            child: const Text("Clear All Filters", style: TextStyle(color: TColors.primary)),
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
          const Icon(Icons.cloud_off_rounded, size: 60, color: TColors.primary_shade300),
          const SizedBox(height: 16),
          const Text("Connection Failed", style: TextStyle(fontWeight: FontWeight.bold)),
          TextButton.icon(
            onPressed: _dataController.fetchInvoices,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          )
        ],
      ),
    );
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
                  child: Icon(Icons.cloud, color: Colors.white.withOpacity(0.1), size: 60),
                );
              },
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Positioned(
                  top: 80,
                  right: 20 + (width * 0.3 * controller.value),
                  child: Icon(Icons.cloud, color: Colors.white.withOpacity(0.05), size: 40),
                );
              },
            ),
            Positioned(
              right: 0, bottom: 60,
              width: width * 0.6,
              height: 2,
              child: Container(
                color: Colors.white.withOpacity(0.2),
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
                    opacity: rightPos > width * 0.5 ? 0.0 : 1.0 - controller.value,
                    child: Transform(
                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(5, 5))
                            ]
                        ),
                        child: const Icon(Icons.local_shipping_rounded, color: TColors.primary, size: 32),
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
    final delivered = invoices.where((i) => i.status.toString().toLowerCase().contains('delivered')).length;
    final cancelled = invoices.where((i) => i.status.toString().toLowerCase().contains('cancel')).length;
    final pending = total - delivered - cancelled;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: TColors.primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Total & Delivered
          Row(
            children: [
              _buildStatItem("Total Invoices", total, TColors.info, Icons.receipt_long_rounded),
              _buildDivider(),
              _buildStatItem("Delivered", delivered, TColors.success, Icons.task_alt_rounded),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          const SizedBox(height: 20),
          // Row 2: Pending & Cancelled
          Row(
            children: [
              _buildStatItem("Pending", pending, TColors.secondary, Icons.hourglass_top_rounded),
              _buildDivider(),
              _buildStatItem("Cancelled", cancelled, TColors.primary, Icons.cancel_presentation_rounded),
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
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textGrey
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.shade200,
    );
  }
}

// --- C. DETAILED INVOICE CARD (NEW & IMPROVED) ---
class _DetailedInvoiceCard extends StatelessWidget {
  final dynamic invoice;
  final VoidCallback onDownload;
  final VoidCallback onTrack;
  final VoidCallback onTap;

  const _DetailedInvoiceCard({
    required this.invoice,
    required this.onDownload,
    required this.onTrack,
    required this.onTap,
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
    final partyName = invoice.partyName ?? invoice.stockist?.firmName ?? 'Unknown Customer';
    final invoiceNum = invoice.invoiceNumber ?? 'N/A';
    final email = invoice.stockist?.emailAddress ?? 'No Email';
    final courier = invoice.courierCompanyName ?? 'Not Assigned';
    final awb = invoice.awbNumber ?? 'Pending';

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.05),
                  border: Border(bottom: BorderSide(color: statusColor.withOpacity(0.1))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(date),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textGrey),
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
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.store_mall_directory_rounded, color: AppTheme.textDark),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(partyName, style: AppTheme.cardTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('#$invoiceNum', style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          )
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
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Courier", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(courier, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 24, color: Colors.grey.shade300),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("AWB Number", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(awb, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
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
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        onPressed: onTrack,
                        icon: const Icon(Icons.map_outlined, size: 18, color: TColors.secondary),
                        label: const Text("Track"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        onPressed: onDownload,
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text("Download"),
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
}

// --- D. QUICK VIEW BOTTOM SHEET ---
class _QuickViewSheet extends StatelessWidget {
  final dynamic invoice;
  const _QuickViewSheet({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Invoice Details", style: AppTheme.header.copyWith(color: AppTheme.textDark, fontSize: 22)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          _detailRow("Party", invoice.partyName ?? invoice.stockist?.firmName ?? '-'),
          _detailRow("Number", "#${invoice.invoiceNumber}"),
          _detailRow("Date", invoice.invoiceDate ?? '-'),
          _detailRow("Status", invoice.status ?? '-'),
          _detailRow("Courier", invoice.courierCompanyName ?? '-'),
          _detailRow("AWB", invoice.awbNumber ?? 'Not Generated'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
              onPressed: () {
                Navigator.pop(context);
                // Trigger download or open logic
              },
              child: const Text("Open Full Invoice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
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
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.right)),
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

  const _AdvancedFilterSheet({required this.currentStatus, required this.currentDateRange, required this.onApply});

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
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Invoices', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                TextButton(
                  onPressed: () => setState(() { _status = 'All'; _range = null; }),
                  child: const Text('Reset', style: TextStyle(color: TColors.primary, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 24),

            const Text('SHIPMENT STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ['All', 'Delivered', 'Pending', 'Cancelled'].map((e) {
                final isSelected = _status == e;
                return ChoiceChip(
                  label: Text(e),
                  selected: isSelected,
                  selectedColor: TColors.primary,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                  onSelected: (_) => setState(() => _status = e),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const Text('DATE RANGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(primary: TColors.primary),
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
                  color: _range != null ? TColors.primary_shade50 : Colors.white,
                  border: Border.all(color: _range != null ? TColors.primary : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 20, color: _range != null ? TColors.primary : Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      _range == null
                          ? 'Select Date Range'
                          : '${DateFormat('MMM dd').format(_range!.start)} - ${DateFormat('MMM dd').format(_range!.end)}',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _range != null ? TColors.primary : Colors.grey.shade600
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    elevation: 5,
                    shadowColor: TColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                onPressed: () {
                  widget.onApply(_status, _range);
                  Navigator.pop(context);
                },
                child: const Text('Apply Results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
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

  const DownloadProgressSheet({super.key, required this.dio, required this.invoiceId, required this.fileName});

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
      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_${widget.fileName.isEmpty ? "invoice.pdf" : widget.fileName}';
      final savePath = '${dir.path}/$uniqueName';

      setState(() => _status = 'Generating Link...');
      final response = await widget.dio.get(
        '${THttpHelper.baseUrl}/invoice-tracking/${widget.invoiceId}/signed-url',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final url = response.data['url'];
        setState(() => _status = 'Downloading PDF...');

        await widget.dio.download(
            url,
            savePath,
            onReceiveProgress: (rec, total) {
              if (mounted && total != -1) {
                setState(() => _progress = rec / total);
              }
            }
        );

        setState(() { _status = 'Complete!'; _progress = 1.0; });
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
        setState(() { _status = 'Download Failed'; _failed = true; });
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _failed ? Colors.red.withOpacity(0.1) : TColors.primary_shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    _failed ? Icons.error_outline : Icons.cloud_download_rounded,
                    color: _failed ? Colors.red : TColors.primary
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_failed ? "Error" : "Downloading...", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(_status, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[100],
              color: _failed ? Colors.red : TColors.primary,
              minHeight: 8,
            ),
          ),
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
      height: 24,
      child: Stack(
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) => Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  (constraints.constrainWidth() / 8).floor(),
                      (index) => SizedBox(width: 4, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey.shade300))),
                ),
              ),
            ),
          ),
          Positioned(
            left: -10, top: 0, bottom: 0,
            child: CircleAvatar(backgroundColor: Colors.white, radius: 10), // Matched to card bg
          ),
          Positioned(
            right: -10, top: 0, bottom: 0,
            child: CircleAvatar(backgroundColor: Colors.white, radius: 10), // Matched to card bg
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
          top: 100, left: -50,
          child: Container(
            height: 250, width: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TColors.primary.withOpacity(0.03),
            ),
          ),
        ),
        Positioned(
          top: 400, right: -40,
          child: Container(
            height: 200, width: 200,
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