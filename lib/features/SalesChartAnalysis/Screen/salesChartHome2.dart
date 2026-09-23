import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:provider/provider.dart';
import '../../../utils/check_internet/network_monitor.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../../authentication/models/UserModel.dart';
import '../../dashboard/widgets/LiveClockWidget.dart';
import '../../ticket/controller/TicketController.dart';
import '../controller/DashboardController.dart';
import '../model/SalesChartDashboardModel.dart' as dash;
import '../services/WeatherService.dart';
import '../widgets/CompactWeatherWidget.dart';
import '../widgets/morning_action_center.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

// -----------------------------------------------------------------------------
// IMPORTS - YOUR DOMAIN
// -----------------------------------------------------------------------------
// =============================================================================
// PART 1: THEME & CONSTANTS
// =============================================================================

class AppTheme {
  static const Color primary = TColors.hex_FFC71D52;
  static const Color primaryLight = TColors.hex_FFF499B1;
  static const Color primaryDeep = TColors.hex_FF8A1035;
  static const Color primaryDark = TColors.hex_FF50041B;

  static const Color secondaryGold = TColors.hex_FFEFA100;
  static const Color secondaryTeal = TColors.hex_FF009688;
  static const Color secondaryBlue = TColors.hex_FF2196F3;
  static const Color secondaryOrange = TColors.hex_FFFF6D00;

  static const Color background = TColors.hex_FFF8F5F6;
  static const Color surface = TColors.white;

  static const Color textPrimary = TColors.hex_FF2D0E15;
  static const Color textSecondary = TColors.hex_FF8E8E8E;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextStyle get label => const TextStyle(
        fontFamily: 'Roboto',
        fontSize: TSizes.v11,
        fontWeight: FontWeight.w700,
        color: textSecondary,
        letterSpacing: 1.0,
      );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withOpacity(0.06),
          blurRadius: TSizes.v15,
          offset: const Offset(0, 6),
          spreadRadius: TSizes.v0,
        ),
      ];

  static List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: primary.withOpacity(0.2),
          blurRadius: TSizes.v20,
          offset: const Offset(0, 10),
        ),
      ];
}

// =============================================================================
// PART 2: MAIN SCREEN (RESPONSIVE FIX)
// =============================================================================

class SalesChartHomeScreen extends StatefulWidget {
  const SalesChartHomeScreen({Key? key}) : super(key: key);

  @override
  State<SalesChartHomeScreen> createState() => _SalesChartHomeScreenState();
}

class _SalesChartHomeScreenState extends State<SalesChartHomeScreen>
    with TickerProviderStateMixin {
  final DashboardController _dashboardController =
      Get.put(DashboardController());
  final ScrollController _scrollController = ScrollController();
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    Get.put(TicketController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());

    FirebaseAnalytics.instance.logEvent(name: 'sales_dashboard_open');
  }

  void logDashboardOpen() async {
    await FirebaseAnalytics.instance.logEvent(
      name:
          'sales_dashboard_open', // MUST match the event name in your screenshot exactly
      parameters: null, // Optional: add parameters if needed
    );
  }

  Future<void> _loadData() async {
    AuthManager authManager = AuthManager();
    final token = await authManager.getAuthToken();
    if (token != null) {
      await _dashboardController.fetchDashboardData(token);
      _entranceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Obx(() {
        if (_dashboardController.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        final data = _dashboardController.dashboardData.value?.data;
        if (data == null) return _ErrorView(onRetry: _loadData);

        // --- RESPONSIVE LAYOUT BUILDER ---
        return LayoutBuilder(builder: (context, constraints) {
          final bool isWideScreen = constraints.maxWidth > 800; // Tablet
          final bool isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;

          //  FIX 1: Reduce header height in landscape so you can see body content
          // Normal: 260, Landscape: 140 (Compact)
          final double headerHeight = isLandscape ? 140 : 260;

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _GlassWaveHeaderDelegate(
                  user: data.user,
                  expandedHeight: headerHeight,
                  topPadding: MediaQuery.of(context).padding.top,
                  isCompact: isLandscape, // Passes true in landscape
                ),
              ),

              // 2. Responsive Body
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      /// NEW SECTION
                      _StaggeredItem(
                        controller: _entranceController,
                        index: 0,
                        child: MorningActionCenter(
                          beat: data.todayBeatAssigned,
                          onHandshakeSubmitted: () =>
                              _dashboardController.fetchDashboardData(''),
                        ),
                      ),

                      const SizedBox(height: TSizes.v24),

                      /// Existing Revenue Cards
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: isLandscape ? 220 : 250,
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _StaggeredItem(
                                  controller: _entranceController,
                                  index: 1,
                                  child: _RevenueIntelligenceCard(
                                    targets: data.targets,
                                  ),
                                ),
                              ),
                              const SizedBox(width: TSizes.v12),
                              Expanded(
                                child: _StaggeredItem(
                                  controller: _entranceController,
                                  index: 2,
                                  child: _PerformancePaceCard(
                                    targets: data.targets,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: TSizes.v30),

                      if (isWideScreen)
                        _buildTabletLayout(data)
                      else
                        _buildMobileLayout(data),

                      const SizedBox(height: TSizes.v60),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.sync, color: TColors.white),
      ),
    );
  }

  // Mobile Layout: Vertical Stack
  Widget _buildMobileLayout(dynamic data) {
    return Column(
      children: [
        const _SectionDivider(label: TTexts.uiTextMISSIONCONTROL),
        const SizedBox(height: TSizes.v15),
        _StaggeredItem(
          controller: _entranceController,
          index: 1,
          child: _MissionControlStrips(visits: data.visits),
        ),
        const SizedBox(height: TSizes.v30),
        const _SectionDivider(label: TTexts.uiTextEXPENSEDNA),
        const SizedBox(height: TSizes.v15),
        _StaggeredItem(
          controller: _entranceController,
          index: 2,
          child: _ExpenseHeroTiles(expenses: data.expenses),
        ),
      ],
    );
  }

  // Tablet Layout: Two Columns (Side by Side)
  Widget _buildTabletLayout(dynamic data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              const _SectionDivider(label: TTexts.uiTextVISITCONTROL),
              const SizedBox(height: TSizes.v15),
              _StaggeredItem(
                controller: _entranceController,
                index: 1,
                child: _MissionControlStrips(visits: data.visits),
              ),
            ],
          ),
        ),
        const SizedBox(width: TSizes.v24),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const _SectionDivider(label: TTexts.uiTextEXPENSE),
              const SizedBox(height: TSizes.v15),
              _StaggeredItem(
                controller: _entranceController,
                index: 2,
                child: _ExpenseHeroTiles(expenses: data.expenses),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PART 3: HEADER (ADAPTIVE)
// =============================================================================

class _GlassWaveHeaderDelegate extends SliverPersistentHeaderDelegate {
  final dash.User? user;
  final double expandedHeight;
  final double topPadding;
  final bool isCompact;

  _GlassWaveHeaderDelegate({
    required this.user,
    required this.expandedHeight,
    required this.topPadding,
    this.isCompact = false,
  });

  String get _timeGreeting {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double availableScroll = maxExtent - minExtent;
    final double progress = availableScroll == 0
        ? 0
        : (shrinkOffset / availableScroll).clamp(0.0, 1.0);

    final isCollapsed = progress > 0.6;
    final safeTop = topPadding + 10;

    return SizedBox(
      height: expandedHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: math.max(
              minExtent,
              expandedHeight - shrinkOffset,
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(40)),
              child: CustomPaint(
                  painter: _WaveGradientPainter(color: AppTheme.primary)),
            ),
          ),

          // Content
          Positioned(
            top: safeTop,
            left: 24,
            right: 24,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar (Title + Clock)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isCollapsed ? 1.0 : 0.0,
                      child: const Text(TTexts.uiTextDashboard,
                          style: TextStyle(
                              color: TColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: TSizes.v18)),
                    ),
                    _GlassBadge(
                        child: Row(children: [
                      const LiveClockWidget(),
                      const SizedBox(width: TSizes.v8),
                      _StatusDot()
                    ])),
                  ],
                ),

                // 2. Expanded Content (Greeting + Weather)
                if (progress < 0.5) ...[
                  SizedBox(height: isCompact ? 8 : 24),
                  Opacity(
                    opacity: (1 - progress * 2.5).clamp(0.0, 1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left Side: Greeting & Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_timeGreeting,
                                  style: TextStyle(
                                      color: TColors.white.withOpacity(0.9),
                                      fontSize: TSizes.v16)),
                              Text(
                                user?.name ?? "User",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: TColors.white,
                                    fontSize: TSizes.v28,
                                    fontWeight: FontWeight.w900,
                                    height: TSizes.v1_1),
                              ),
                              if (!isCompact) ...[
                                const SizedBox(height: TSizes.v4),
                                const Text(
                                    TTexts.uiTextYourFieldMetricsAreSynced,
                                    style: TextStyle(
                                        color: TColors.white54,
                                        fontSize: TSizes.v12)),
                              ],
                            ],
                          ),
                        ),

                        // Right Side: Weather Widget
                        //  UPDATED: Removed the 'if (!isCompact)' check.
                        // Now it shows in Landscape mode too.
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4, left: 8),
                          child: CompactWeatherWidget(),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;
  @override
  double get minExtent => kToolbarHeight + topPadding + 20;
  @override
  bool shouldRebuild(covariant _GlassWaveHeaderDelegate old) =>
      old.user != user || old.expandedHeight != expandedHeight;
}

// =============================================================================
// PART 4: DATA INTELLIGENCE CARDS (FIXED OVERFLOW)
// =============================================================================

// Helper for currency formatting
final _currencyFormat =
    NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 1);

class _RevenueIntelligenceCard extends StatelessWidget {
  final dash.Targets? targets;
  const _RevenueIntelligenceCard({required this.targets});

  @override
  Widget build(BuildContext context) {
    final double monthlyTarget = (targets?.monthlyTarget ?? 1).toDouble();
    final double achieved = (targets?.achieved ?? 0).toDouble();
    double percent =
        (monthlyTarget == 0) ? 0 : (achieved / monthlyTarget).clamp(0.0, 1.0);

    // --- Intelligence Calculations ---
    final now = DateTime.now();
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int daysPassed = now.day;

    // Projected: (Average per day so far) * Total days in month
    final double dailyAverage = achieved / (daysPassed == 0 ? 1 : daysPassed);
    final double projected = dailyAverage * totalDaysInMonth;
    final double remaining = math.max(0, monthlyTarget - achieved);

    // Variance checks
    final double expectedPace = (monthlyTarget / totalDaysInMonth) * daysPassed;
    final double variance = achieved - expectedPace;
    final bool isBehind = variance < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.monetization_on_outlined,
                      size: TSizes.v14, color: AppTheme.textSecondary),
                  const SizedBox(width: TSizes.v4),
                  Text(TTexts.uiTextREVENUE, style: AppTheme.label),
                ],
              ),
              // Show explicit Target here
              Text("Target: ${_currencyFormat.format(monthlyTarget)}",
                  style: const TextStyle(
                      fontSize: TSizes.v10,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const Spacer(),

          Row(
            children: [
              // Left side: Main Stats
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(TTexts.uiTextAchieved,
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: TSizes.v11)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _currencyFormat.format(achieved),
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: TSizes.v24, // Made slightly bigger
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: TSizes.v4),
                    // New: Remaining Amount
                    Text(
                      "Remaining: ${_currencyFormat.format(remaining)}",
                      style: TextStyle(
                          fontSize: TSizes.v11,
                          color: AppTheme.textSecondary.withOpacity(0.8),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // Right Side: Radial Indicator
              SizedBox(
                height: TSizes.v70,
                width: TSizes.v70,
                child: CustomPaint(
                  painter: _SimpleRadialPainter(
                      percent: percent, color: AppTheme.primary),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${(percent * 100).toInt()}%",
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: TSizes.v14)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Enhanced Footer: Variance + Projection
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
                color: AppTheme.background, // Cleaner background
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Variance Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: isBehind
                          ? AppTheme.primary.withOpacity(0.1)
                          : TColors.materialGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      Icon(isBehind ? Icons.trending_down : Icons.trending_up,
                          size: TSizes.v10,
                          color: isBehind
                              ? AppTheme.primary
                              : TColors.materialGreen),
                      const SizedBox(width: TSizes.v4),
                      Text(
                        isBehind
                            ? _currencyFormat.format(variance.abs())
                            : "+${_currencyFormat.format(variance)}",
                        style: TextStyle(
                            fontSize: TSizes.v10,
                            fontWeight: FontWeight.bold,
                            color: isBehind
                                ? AppTheme.primary
                                : TColors.materialGreen),
                      ),
                    ],
                  ),
                ),

                // Projection Text
                Flexible(
                  child: Text(
                    "Proj: ${_currencyFormat.format(projected)}",
                    style: const TextStyle(
                        fontSize: TSizes.v10,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _PerformancePaceCard extends StatelessWidget {
  final dash.Targets? targets;
  const _PerformancePaceCard({this.targets});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    final int daysLeft = totalDays - now.day;
    final double timePercent = now.day / totalDays;

    final double monthly = (targets?.monthlyTarget ?? 1).toDouble();
    final double achieved = (targets?.achieved ?? 0).toDouble();
    final double remaining = math.max(0, monthly - achieved);

    // Key Intelligence: Required Daily Run Rate
    // If daysLeft is 0, avoid division by zero
    final double requiredDaily = daysLeft > 0 ? (remaining / daysLeft) : 0;

    final double salesPercent =
        (monthly == 0) ? 0 : (achieved / monthly).clamp(0.0, 1.0);
    final bool isOnTrack = salesPercent >= timePercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed_rounded,
                      size: TSizes.v14, color: AppTheme.textSecondary),
                  const SizedBox(width: TSizes.v4),
                  Text(TTexts.uiTextPACE, style: AppTheme.label),
                ],
              ),
              // Show Time Info
              Text("$daysLeft Days Left",
                  style: const TextStyle(
                      fontSize: TSizes.v10,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600)),
            ],
          ),

          const Spacer(),

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: TSizes.v60,
                  width: TSizes.v60,
                  child: CustomPaint(
                    painter: _DualRadialPainter(
                      innerPercent: salesPercent,
                      outerPercent: timePercent,
                      primary: AppTheme.primary,
                    ),
                    child: Center(
                      child: Icon(
                        isOnTrack
                            ? Icons.thumb_up_alt_rounded
                            : Icons.bolt_rounded,
                        color: isOnTrack
                            ? TColors.materialGreen
                            : AppTheme.primary,
                        size: TSizes.v20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.v12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isOnTrack ? "On Track" : "Boost Required",
                        style: TextStyle(
                            color: isOnTrack
                                ? TColors.materialGreen
                                : AppTheme.primary,
                            fontSize: TSizes.v14,
                            fontWeight: FontWeight.bold)),
                    Text(
                      isOnTrack
                          ? "Maintain daily avg."
                          : "Increase daily visits.",
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: TSizes.v10),
                    ),
                  ],
                )
              ],
            ),
          ),

          const Spacer(),

          // Actionable Footer: Required Daily Run Rate
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: isOnTrack
                    ? TColors.materialGreen.withOpacity(0.05)
                    : AppTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(TTexts.uiTextREQUIREDDAY,
                    style: TextStyle(
                        fontSize: TSizes.v8,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5)),
                const SizedBox(height: TSizes.v2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_currencyFormat.format(requiredDaily),
                        style: TextStyle(
                            fontSize: TSizes.v16,
                            fontWeight: FontWeight.w800,
                            color: isOnTrack
                                ? TColors.materialGreen700
                                : AppTheme.primary)),
                    Text(isOnTrack ? "You are safe" : "To hit target",
                        style: TextStyle(
                            fontSize: TSizes.v10,
                            color: isOnTrack
                                ? TColors.materialGreen
                                : AppTheme.primary.withOpacity(0.8)))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PART 5: MISSION CONTROL (UNCHANGED LOGIC)
// =============================================================================

class _MissionControlStrips extends StatelessWidget {
  final dash.Visits? visits;
  const _MissionControlStrips({this.visits});

  @override
  Widget build(BuildContext context) {
    if (visits == null) return const SizedBox();

    return Column(
      children: [
        _MissionStrip(
          title: TTexts.uiTextDoctorVisits,
          confirmed: visits?.doctor?.confirmed ?? 0,
          total: visits?.doctor?.total ?? 0,
          color: TColors.primary,
          icon: Icons.medical_services,
        ),
        const SizedBox(height: TSizes.v12),
        _MissionStrip(
          title: TTexts.uiTextChemistVisits,
          confirmed: visits?.chemist?.confirmed ?? 0,
          total: visits?.chemist?.total ?? 0,
          color: TColors.primary,
          icon: Icons.science,
        ),
        const SizedBox(height: TSizes.v12),
        _MissionStrip(
          title: TTexts.uiTextStockistVisits,
          confirmed: visits?.stockist?.confirmed ?? 0,
          total: visits?.stockist?.total ?? 0,
          color: TColors.primary,
          icon: Icons.store,
        ),
        const SizedBox(height: TSizes.v12),
        _TotalActivityStrip(
          total: visits?.total ?? 0,
          scheduled: visits?.scheduled ?? 0,
        ),
      ],
    );
  }
}

class _MissionStrip extends StatelessWidget {
  final String title;
  final int confirmed;
  final int total;
  final Color color;
  final IconData icon;

  const _MissionStrip({
    required this.title,
    required this.confirmed,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    double progress = total == 0 ? 0 : confirmed / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: TSizes.v20),
          ),
          const SizedBox(width: TSizes.v16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: TSizes.v14,
                            color: AppTheme.textPrimary)),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: "$confirmed",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontSize: TSizes.v16)),
                        TextSpan(
                            text: "/$total",
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: TSizes.v12)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.v8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.background,
                    color: color,
                    minHeight: TSizes.v6,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _TotalActivityStrip extends StatelessWidget {
  final int total;
  final int scheduled;
  const _TotalActivityStrip({required this.total, required this.scheduled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.heroShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: TColors.white24,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.analytics_outlined,
                    color: TColors.white, size: TSizes.v20),
              ),
              const SizedBox(width: TSizes.v16),
              const Text(TTexts.uiTextTotalFieldActivity,
                  style: TextStyle(
                      color: TColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: TSizes.v14)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$total",
                  style: const TextStyle(
                      color: TColors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: TSizes.v20)),
              Text("Target: $scheduled",
                  style: const TextStyle(
                      color: TColors.white70, fontSize: TSizes.v10)),
            ],
          )
        ],
      ),
    );
  }
}

// =============================================================================
// PART 6: EXPENSE HERO TILES
// =============================================================================

class _ExpenseHeroTiles extends StatelessWidget {
  final dash.Expenses? expenses;
  const _ExpenseHeroTiles({this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses == null) return const SizedBox();
    return Column(
      children: [
        _ExpenseTile(
            label: TTexts.uiTextApproved,
            count: expenses!.approved,
            amount: expenses!.approvedAmount,
            color: TColors.materialGreen,
            icon: Icons.check_circle_outline),
        const SizedBox(height: TSizes.v12),
        _ExpenseTile(
            label: TTexts.pending,
            count: expenses!.pending,
            amount: expenses!.pendingAmount,
            color: TColors.hex_FFFBC02D,
            icon: Icons.access_time),
        const SizedBox(height: TSizes.v12),
        _ExpenseTile(
            label: TTexts.uiTextRejected,
            count: expenses!.rejected,
            amount: expenses!.rejectedAmount,
            color: AppTheme.primary,
            icon: Icons.error_outline),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final String label;
  final int count;
  final int amount;
  final Color color;
  final IconData icon;

  const _ExpenseTile(
      {required this.label,
      required this.count,
      required this.amount,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
        border: Border(left: BorderSide(color: color, width: TSizes.v4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: TSizes.v20),
          ),
          const SizedBox(width: TSizes.v16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: TSizes.v13,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold)),
              Text("$count Claims",
                  style: const TextStyle(
                      fontSize: TSizes.v11, color: AppTheme.textSecondary)),
            ],
          ),
          const Spacer(),
          Text("₹${NumberFormat.compact().format(amount)}",
              style: const TextStyle(
                  fontSize: TSizes.v18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

// =============================================================================
// PART 7: HELPERS & PAINTERS
// =============================================================================

class _SimpleRadialPainter extends CustomPainter {
  final double percent;
  final Color color;
  _SimpleRadialPainter({required this.percent, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    paint.color = color.withOpacity(0.1);
    canvas.drawCircle(center, size.width / 2, paint);
    paint.color = color;
    canvas.drawArc(Rect.fromCircle(center: center, radius: size.width / 2),
        -math.pi / 2, 2 * math.pi * percent, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _DualRadialPainter extends CustomPainter {
  final double innerPercent;
  final double outerPercent;
  final Color primary;
  _DualRadialPainter(
      {required this.innerPercent,
      required this.outerPercent,
      required this.primary});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    // Outer (Time)
    final bgP = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6
      ..color = TColors.materialGrey200;
    canvas.drawCircle(center, radius, bgP);
    final timeP = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6
      ..color = TColors.materialGrey400;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, 2 * math.pi * outerPercent, false, timeP);
    // Inner (Sales)
    final inBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6
      ..color = primary.withOpacity(0.1);
    canvas.drawCircle(center, radius - 10, inBg);
    final inP = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6
      ..color = primary;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 10),
        -math.pi / 2, 2 * math.pi * innerPercent, false, inP);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _WaveGradientPainter extends CustomPainter {
  final Color color;
  _WaveGradientPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.7, size.width, size.height * 0.9);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: TSizes.v4,
            height: TSizes.v16,
            decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: TSizes.v8),
        Text(label,
            style: const TextStyle(
                fontSize: TSizes.v12,
                fontWeight: FontWeight.w900,
                color: AppTheme.textSecondary,
                letterSpacing: 1.5)),
        const SizedBox(width: TSizes.v8),
        Expanded(
            child:
                Divider(color: TColors.materialGrey200, thickness: TSizes.v1)),
      ],
    );
  }
}

class _AnimatedMoney extends StatefulWidget {
  final double amount;
  final TextStyle style;
  const _AnimatedMoney({required this.amount, required this.style});
  @override
  State<_AnimatedMoney> createState() => _AnimatedMoneyState();
}

class _AnimatedMoneyState extends State<_AnimatedMoney>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _anim = Tween<double>(begin: 0, end: widget.amount)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Text(
          NumberFormat.currency(symbol: '₹ ', decimalDigits: 0, locale: "en_IN")
              .format(_anim.value),
          style: widget.style),
    );
  }
}

class _StaggeredItem extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;
  const _StaggeredItem(
      {required this.controller, required this.index, required this.child});
  @override
  Widget build(BuildContext context) {
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic));
    return AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Transform.translate(
            offset: Offset(0, 30 * (1 - curve.value)),
            child: Opacity(opacity: curve.value, child: child)));
  }
}

class _GlassBadge extends StatelessWidget {
  final Widget child;
  const _GlassBadge({required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: TColors.white.withOpacity(0.2),
            child: child),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final monitor = NetworkMonitor();
    return ValueListenableBuilder<bool>(
      valueListenable: monitor.isOnline,
      builder: (_, isOnline, __) => Container(
          width: TSizes.v8,
          height: TSizes.v8,
          decoration: BoxDecoration(
              color:
                  isOnline ? TColors.materialGreenAccent : TColors.materialRed,
              shape: BoxShape.circle)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
      child: TextButton(
          onPressed: onRetry, child: const Text(TTexts.uiTextRetryConnection)));
}

/*class SalesChartHomeScreen extends StatefulWidget {
  @override
  _SalesChartHomeScreenState createState() => _SalesChartHomeScreenState();
}

class _SalesChartHomeScreenState extends State<SalesChartHomeScreen> {
  late DashboardController _dashboardController;
  AuthManager authManager = AuthManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Access the controller and user data via Provider
    _dashboardController = Provider.of<DashboardController>(context);

    // Check if the data is still loading
    if (_dashboardController.isLoading) {
      return Scaffold(
        backgroundColor: TColors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If data has been fetched, use it
    final dashboardData = _dashboardController.dashboardData?.data;

    if (dashboardData == null) {
      return Scaffold(
        backgroundColor: TColors.white,
        body: Center(child: Text("No data available")),
      );
    }

    final user = dashboardData.user!;
    final period = dashboardData.period!;
    final visits = dashboardData.visits!;
    final sales = dashboardData.sales!;
    final expenses = dashboardData.expenses!;
    final targets = dashboardData.targets!;
    final summary = dashboardData.summary!;

    return Scaffold(
      backgroundColor: TColors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.white,
                border: Border.all(color: TColors.materialRed, width: 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: TColors.materialRed.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<UserModel?>(
                    future: authManager.getUserData(), // your function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data?.user == null) {
                        return const Text("No user data found");
                      }

                      final user = snapshot.data!.user!; // safe to use now

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TColors.white,
                          border: Border.all(color: TColors.materialRed, width: 1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: TColors.materialRed.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          // Left: Welcome + Name + Email
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "👋 Welcome",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: TColors.materialRed800,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              user.name, // ✅ from SharedPreferences
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: TColors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email, // ✅ from SharedPreferences
                              style: TextStyle(
                                fontSize: 14,
                                color: TColors.materialGrey700,
                              ),
                            ),
                          ],
                        ),

                        // Right: Date + Time
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                            Text(
                            DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: TColors.black87,
                        ),
                      ),

                      ],
                      ),
                      ],
                      ),
                      );
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: TColors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            // Visits Summary
            Row(
              children: [
                _animatedProgressCard("Doctor Visits", visits.doctor!.confirmed ?? 0, visits.doctor!.total ?? 0),
                _animatedProgressCard("Chemist Visits", visits.chemist!.confirmed ?? 0, visits.chemist!.total ?? 0),
                _animatedProgressCard("Stockist Visits", visits.stockist!.confirmed ?? 0, visits.stockist!.total ?? 0),
              ],
            ),
            SizedBox(height: 24),
            _monthlyTargetSummary(targets),
            SizedBox(height: 24),
            _todayAppointmentsSummary(visits), // Pass the visits data to the widget
            SizedBox(height: 24),
            _sectionTitle("Expense Summary"),
            _todaySummary(expenses),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _animatedProgressCard(String title, int done, int total) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.all(6),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              CircularProgressIndicator(
                value: done / total,
                color: TColors.materialRed,
                strokeWidth: 6,
                backgroundColor: TColors.materialRed.withOpacity(0.2),
              ),
              SizedBox(height: 8),
              Text('$done / $total'),
              Text('${total - done} Remaining'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _todaySummary(dash.Expenses expenses) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.materialRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TColors.materialRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusCircle("Pending", expenses.pending ?? 0, TColors.materialOrange),
              _statusCircle("Approved", expenses.approved ?? 0, TColors.materialGreen),
              _statusCircle("Rejected", expenses.rejected ?? 0, TColors.materialRed),
            ],
          ),
          SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Total Expenses", "₹ ${(expenses.total ?? 0) * 500}"),
        ],
      ),
    );
  }

  Widget _monthlyTargetSummary(dash.Targets targets) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.materialRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TColors.materialRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Monthly Sales Targets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusCircle("Target", targets.monthlyTarget ?? 0, TColors.materialDeepPurple),
              _statusCircle("Achieved", targets.achieved ?? 0, TColors.materialGreen),
              _statusCircle("Left", targets.remaining ?? 0, TColors.materialOrange),
            ],
          ),
          SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Target Amount", "₹ ${targets.monthlyTarget}"),
          SizedBox(height: 8),
          _summaryItem("Achieved Amount", "₹ ${targets.achieved}"),
          SizedBox(height: 8),
          _summaryItem("Remaining", "₹ ${targets.remaining}"),
        ],
      ),
    );
  }

  Widget _statusCircle(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _summaryItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Today Appointments Summary widget to show the appointment counts
  Widget _todayAppointmentsSummary(dash.Visits visits) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.materialRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TColors.materialRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Scheduled Appointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _appointmentIconCircle("Doctors", visits.doctor?.total ?? 0, TColors.materialBlueAccent),
              _appointmentIconCircle("Chemists", visits.chemist?.total ?? 0, TColors.materialIndigo),
              _appointmentIconCircle("Stockists", visits.stockist?.total ?? 0, TColors.materialTeal),
            ],
          ),
          const SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Total Scheduled Today", "${visits.total ?? 0}"),
        ],
      ),
    );
  }

  // Icon circle for each appointment category (Doctors, Chemists, Stockists)
  Widget _appointmentIconCircle(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.calendar_today, color: color),
        ),
        const SizedBox(height: 6),
        Text("$count $label", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}*/

/*class SalesChartHomeScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<SalesChartHomeScreen> with TickerProviderStateMixin {
  final Color primaryColor = TColors.hex_FFC71D52;

  late AnimationController doctorController;
  late AnimationController chemistController;
  late AnimationController stockistController;

  late Animation<double> doctorAnimation;
  late Animation<double> chemistAnimation;
  late Animation<double> stockistAnimation;

  int doctorDone = 4, doctorTotal = 7;
  int chemistDone = 5, chemistTotal = 8;
  int stockistDone = 2, stockistTotal = 5;

  int pending = 3, approved = 6, rejected = 1;
  late final userData;

  AuthManager authManager = AuthManager();

  @override
  void initState() {
    super.initState();

  //  fetchUserRole();

    doctorController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    chemistController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    stockistController = AnimationController(vsync: this, duration: Duration(seconds: 1));

    doctorAnimation = Tween<double>(begin: 0, end: doctorDone / doctorTotal).animate(doctorController);
    chemistAnimation = Tween<double>(begin: 0, end: chemistDone / chemistTotal).animate(chemistController);
    stockistAnimation = Tween<double>(begin: 0, end: stockistDone / stockistTotal).animate(stockistController);

    Timer(Duration(milliseconds: 300), () {
      doctorController.forward();
      chemistController.forward();
      stockistController.forward();
    });



  }

  Future<void> fetchUserRole() async {
    AuthManager authManager = AuthManager();


    final user = await authManager.getUserData();
    setState(() {
      userData = user;
    });

    print("user data $userData");
    print("user data ${userData..user!.name}");
  }

  @override
  void dispose() {
    doctorController.dispose();
    chemistController.dispose();
    stockistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<UserModel?>(
              future: authManager.getUserData(), // your function
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data?.user == null) {
                  return const Text("No user data found");
                }

                final user = snapshot.data!.user!; // safe to use now

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TColors.white,
                    border: Border.all(color: TColors.materialRed, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: TColors.materialRed.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Welcome + Name + Email
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "👋 Welcome",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: TColors.materialRed800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user.name, // ✅ from SharedPreferences
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email, // ✅ from SharedPreferences
                            style: TextStyle(
                              fontSize: 14,
                              color: TColors.materialGrey700,
                            ),
                          ),
                        ],
                      ),

                      // Right: Date + Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TColors.black87,
                            ),
                          ),
                          */ /* Text(
                DateFormat('hh:mm a').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TColors.materialRed600,
                ),
              ),*/ /*
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 15),

        //_sectionTitle("Today's Appointments"),
            Row(
              children: [
                _animatedProgressCard("Doctor Visits", doctorDone, doctorTotal, doctorAnimation),
                _animatedProgressCard("Chemist Visits", chemistDone, chemistTotal, chemistAnimation),
                _animatedProgressCard("Stockist Visits", stockistDone, stockistTotal, stockistAnimation),
              ],
            ),
            SizedBox(height: 24),
            _monthlyTargetSummary(),
            SizedBox(height: 24),
            _todayAppointmentsSummary(),
            SizedBox(height: 24),
            const SizedBox(height: 24),
            _sectionTitle("Expense Summary of July"),
            _todaySummary(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _animatedProgressCard(String title, int done, int total, Animation<double> animation) {
    return Expanded(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Card(
            margin: EdgeInsets.all(6),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  CircularProgressIndicator(
                    value: animation.value,
                    color: primaryColor,
                    strokeWidth: 6,
                    backgroundColor: primaryColor.withOpacity(0.2),
                  ),
                  SizedBox(height: 8),
                  Text('$done / $total'),
                  Text('${total - done} Remaining'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _todaySummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusCircle("Pending", pending, TColors.materialOrange),
              _statusCircle("Approved", approved, TColors.materialGreen),
              _statusCircle("Rejected", rejected, TColors.materialRed),
            ],
          ),
          SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Total Expenses of July T.A.", "₹ ${(pending + approved + rejected) * 500}"),
          SizedBox(height: 8),
          _summaryItem("Total Expenses of July D.A.", "₹ ${pending * 500}"),
        ],
      ),
    );
  }

  Widget _todayAppointmentsSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Scheduled Appointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _appointmentIconCircle("Doctors", doctorTotal, TColors.materialBlueAccent),
              _appointmentIconCircle("Chemists", chemistTotal, TColors.materialIndigo),
              _appointmentIconCircle("Stockists", stockistTotal, TColors.materialTeal),
            ],
          ),
          const SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Total Scheduled Today", "${doctorTotal + chemistTotal + stockistTotal}"),
        ],
      ),
    );
  }

  Widget _monthlyTargetSummary() {
    final int target = 89870;
    final int achieved = 65000;
    final int remaining = target - achieved;
    final String assignedBy = "Gluckcare";

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Monthely Sales Targets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusCircle("Target", target ~/ 1000, TColors.materialDeepPurple),
              _statusCircle("Achieved", achieved ~/ 1000, TColors.materialGreen),
              _statusCircle("Left", remaining ~/ 1000, TColors.materialOrange),
            ],
          ),
          const SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Target Amount", "₹ $target"),
          const SizedBox(height: 8),
          _summaryItem("Achieved Amount", "₹ $achieved"),
          const SizedBox(height: 8),
          _summaryItem("Remaining", "₹ $remaining"),
          const SizedBox(height: 8),
          _summaryItem("Assigned By", assignedBy),
        ],
      ),
    );
  }



  Widget _appointmentIconCircle(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.calendar_today, color: color),
        ),
        const SizedBox(height: 6),
        Text("$count $label", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }


  Widget _statusCircle(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _summaryItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}*/
