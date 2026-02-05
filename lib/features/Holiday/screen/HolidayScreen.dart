import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart'; // Using GetX
import 'package:intl/intl.dart';

// =============================================================================
// SECTION 1: IMPORTS
// =============================================================================
import '../../../utils/constants/colors.dart'; // Keep your imports

import '../controller/HolidayController.dart';
import '../models/Holiday.dart';

// =============================================================================
// SECTION 2: THEME & CONSTANTS (PREMIUM DESIGN SYSTEM)
// =============================================================================

class AppTheme {
  // --- Colors ---
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color divider = Color(0xFFE2E8F0); // Slate 200

  // --- Dimensions ---
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double cardRadius = 24.0;
  static const double buttonRadius = 16.0;

  // --- Shadows (Glows & Depth) ---
  static List<BoxShadow> get shadowLow => [
    BoxShadow(
      color: const Color(0xFF64748B).withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: const Color(0xFF64748B).withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowHigh => [
    BoxShadow(
      color: const Color(0xFF64748B).withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.35),
      blurRadius: 20,
      spreadRadius: -2,
      offset: const Offset(0, 8),
    ),
  ];

  // --- Text Styles ---
  static TextStyle get h1 => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: -1.0,
    height: 1.1,
  );

  static TextStyle get h2 => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get h3 => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );

  static TextStyle get label => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );
}

// =============================================================================
// SECTION 3: MAIN SCREEN SCAFFOLD (GETX CONVERTED)
// =============================================================================

enum ViewMode { timeline, calendar }

class HolidayTimelineScreen extends StatefulWidget {
  const HolidayTimelineScreen({super.key});

  @override
  State<HolidayTimelineScreen> createState() => _HolidayTimelineScreenState();
}

class _HolidayTimelineScreenState extends State<HolidayTimelineScreen> {
  // 1. Inject Controller
  final HolidayController controller = Get.put(HolidayController());

  // 2. Local Reactive State
  final Rx<ViewMode> viewMode = ViewMode.timeline.obs;
  final Rx<DateTime> calendarFocusDate = DateTime(2026, 1, 1).obs;
  final RxString searchQuery = "".obs;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- Computed Properties (Replacing Computed Providers) ---

  List<Holiday> get filteredHolidays {
    final query = searchQuery.value.toLowerCase();
    // Use controller.holidays (RxList)
    final list = controller.holidays.where((h) {
      return h.title.toLowerCase().contains(query) ||
          h.description.toLowerCase().contains(query);
    }).toList();
    // Sort by Date
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Holiday? get nextHoliday {
    final now = DateTime.now();
    try {
      return filteredHolidays.firstWhere((h) =>
          h.date.isAfter(now.subtract(const Duration(days: 1)))
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, int> get holidayStats {
    final list = filteredHolidays;
    return {
      'Total': list.length,
      'National': list.where((h) => h.type == HolidayType.National).length,
      'Religious': list.where((h) => h.type == HolidayType.Religious).length,
      'Optional': list.where((h) => h.type == HolidayType.Optional).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: RefreshIndicator(
            color: TColors.primary,
            backgroundColor: Colors.white,
            edgeOffset: 120,
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              // Call method on controller
              await controller.fetchHolidays();
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // 1. Premium App Bar with Search
                _SliverHolidayAppBar(
                  onSearchChanged: (val) => searchQuery.value = val,
                ),

                // 2. Stats Dashboard (Wrapped in Obx for reactivity)
                SliverToBoxAdapter(
                  child: Obx(() => _StatisticsSection(stats: holidayStats)),
                ),

                // 3. Next Holiday Countdown (Hero)
                SliverToBoxAdapter(
                  child: Obx(() => _NextHolidayHero(holiday: nextHoliday)),
                ),

                // 4. View Mode Switcher & Filter Chips
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyControlBarDelegate(
                    controller: controller,
                    viewMode: viewMode,
                  ),
                ),

                // 5. Main Content Area (Reactive State Handling)
                Obx(() {
                  // Loading State
                  if (controller.isLoading.value) {
                    return SliverToBoxAdapter(child: _buildShimmerLoading());
                  }

                  // Error State
                  if (controller.errorMessage.value.isNotEmpty) {
                    return SliverFillRemaining(
                      child: _ErrorStateWidget(
                        error: controller.errorMessage.value,
                        onRetry: () => controller.fetchHolidays(),
                      ),
                    );
                  }

                  // Empty State
                  if (filteredHolidays.isEmpty) {
                    return const SliverFillRemaining(child: _EmptyStateWidget());
                  }

                  // Data State
                  return SliverPadding(
                    padding: const EdgeInsets.only(bottom: 100),
                    sliver: viewMode.value == ViewMode.timeline
                        ? _TimelineView(holidays: filteredHolidays)
                        : _CalendarView(
                      holidays: filteredHolidays,
                      focusDate: calendarFocusDate,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Get.snackbar(
            "Upcoming",
            "Add Custom Holiday feature coming soon!",
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            backgroundColor: TColors.primary,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingL, vertical: 20),
      child: Column(
        children: List.generate(4, (index) => const _ShimmerTicket()),
      ),
    );
  }
}

// =============================================================================
// SECTION 5: APP BAR & SEARCH
// =============================================================================

class _SliverHolidayAppBar extends StatelessWidget {
  final Function(String) onSearchChanged;
  const _SliverHolidayAppBar({required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.background,
      elevation: 0,
      // Custom Back Button
      leading: Center(
        child: _GlassIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Get.back(),
        ),
      ),
      // Actions
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Center(
            child: _GlassIconButton(
              icon: Icons.calendar_month_outlined,
              onTap: () {
                HapticFeedback.selectionClick();
              },
            ),
          ),
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppTheme.background,
              ],
            ),
          ),
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        centerTitle: false,
        title: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1.0,
                child: const Text(
                  "Holidays 2026",
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20
                  ),
                ),
              );
            }
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: _SearchBar(onChanged: onSearchChanged),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final Function(String) onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowLow,
        border: Border.all(color: AppTheme.divider),
      ),
      child: TextField(
        onChanged: onChanged,
        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: "Search holidays...",
          hintStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
          prefixIcon: const Icon(Icons.search_rounded, color: TColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
          boxShadow: AppTheme.shadowLow,
        ),
        child: Icon(icon, size: 20, color: AppTheme.textPrimary),
      ),
    );
  }
}

// =============================================================================
// SECTION 6: STATISTICS & HERO COUNTDOWN
// =============================================================================

class _StatisticsSection extends StatelessWidget {
  final Map<String, int> stats;
  const _StatisticsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
      child: Row(
        children: [
          _StatCard(
            label: "Total Events",
            count: stats['Total'] ?? 0,
            color: TColors.primary,
            icon: Icons.event_available_rounded,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: "National",
            count: stats['National'] ?? 0,
            color: Colors.blueAccent,
            icon: Icons.flag_rounded,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: "Religious",
            count: stats['Religious'] ?? 0,
            color: Colors.purpleAccent,
            icon: Icons.temple_buddhist_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowLow,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString().padLeft(2, '0'),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              Text(
                label,
                style: AppTheme.label.copyWith(color: AppTheme.textTertiary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextHolidayHero extends StatelessWidget {
  final Holiday? holiday;
  const _NextHolidayHero({this.holiday});

  @override
  Widget build(BuildContext context) {
    if (holiday == null) return const SizedBox.shrink();

    final daysLeft = holiday!.date.difference(DateTime.now()).inDays;
    final String timeText = daysLeft == 0 ? "Today" : (daysLeft == 1 ? "Tomorrow" : "In $daysLeft Days");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [TColors.primary, TColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: AppTheme.glow(TColors.primary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text("UP NEXT", style: AppTheme.label.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                const Icon(Icons.notifications_active_outlined, color: Colors.white70),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              holiday!.title,
              style: AppTheme.h1.copyWith(color: Colors.white, fontSize: 24),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d').format(holiday!.date),
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                timeText,
                style: TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION 7: STICKY CONTROL BAR (Chips & Toggle)
// =============================================================================

class _StickyControlBarDelegate extends SliverPersistentHeaderDelegate {
  final HolidayController controller;
  final Rx<ViewMode> viewMode;

  _StickyControlBarDelegate({required this.controller, required this.viewMode});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppTheme.background.withOpacity(0.85),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // View Toggle
                    Obx(() => _ViewModeToggle(
                      current: viewMode.value,
                      onChanged: (m) => viewMode.value = m,
                    )),

                    Container(
                      height: 24,
                      width: 1,
                      color: AppTheme.divider,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),

                    // Filter Chips (Using Controller logic)
                    Obx(() {
                      final selected = controller.selectedType.value;
                      return Row(
                        children: [
                          _FilterChip(
                            label: "All",
                            isSelected: selected == null,
                            onTap: () => controller.setType(null),
                          ),
                          ...HolidayType.values
                              .where((e) => e != HolidayType.Unknown)
                              .map((type) => _FilterChip(
                            label: type.name,
                            isSelected: selected == type,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              controller.setType(selected == type ? null : type);
                            },
                          )),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant _StickyControlBarDelegate old) => true;
}

class _ViewModeToggle extends StatelessWidget {
  final ViewMode current;
  final Function(ViewMode) onChanged;

  const _ViewModeToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          _IconToggle(
            icon: Icons.list_alt_rounded,
            isSelected: current == ViewMode.timeline,
            onTap: () => onChanged(ViewMode.timeline),
          ),
          _IconToggle(
            icon: Icons.calendar_month_rounded,
            isSelected: current == ViewMode.calendar,
            onTap: () => onChanged(ViewMode.calendar),
          ),
        ],
      ),
    );
  }
}

class _IconToggle extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconToggle({required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? TColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : AppTheme.textTertiary,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? TColors.textPrimary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppTheme.divider,
            ),
            boxShadow: isSelected ? AppTheme.shadowMedium : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION 8: TIMELINE VIEW & COMPONENTS
// =============================================================================

class _TimelineView extends StatelessWidget {
  final List<Holiday> holidays;
  const _TimelineView({required this.holidays});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final holiday = holidays[index];
          final isLast = index == holidays.length - 1;
          final isFirst = index == 0;

          // Header Logic: Show Month if it changes
          bool showMonthHeader = false;
          if (index == 0) {
            showMonthHeader = true;
          } else {
            final prevDate = holidays[index - 1].date;
            if (prevDate.month != holiday.date.month || prevDate.year != holiday.date.year) {
              showMonthHeader = true;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showMonthHeader) _TimelineMonthHeader(date: holiday.date),
              _TimelineItem(
                holiday: holiday,
                isFirst: isFirst,
                isLast: isLast,
                index: index,
              ),
            ],
          );
        },
        childCount: holidays.length,
      ),
    );
  }
}

class _TimelineMonthHeader extends StatelessWidget {
  final DateTime date;
  const _TimelineMonthHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('MMMM yyyy').format(date).toUpperCase(),
              style: AppTheme.label.copyWith(color: TColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Container(height: 1, color: AppTheme.divider)),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Holiday holiday;
  final bool isFirst;
  final bool isLast;
  final int index;

  const _TimelineItem({
    required this.holiday,
    required this.isFirst,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status color/state
    final bool isPassed = holiday.date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index % 5) * 100), // Staggered
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Date Column
            SizedBox(
              width: 80,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd').format(holiday.date),
                      style: AppTheme.h1.copyWith(
                          fontSize: 24,
                          color: isPassed ? AppTheme.textTertiary : holiday.color
                      ),
                    ),
                    Text(
                      DateFormat('EEE').format(holiday.date).toUpperCase(),
                      style: AppTheme.label.copyWith(
                          color: AppTheme.textSecondary
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Timeline Line
            SizedBox(
              width: 24,
              child: CustomPaint(
                painter: _TimelinePainter(
                  color: AppTheme.divider,
                  dotColor: isPassed ? AppTheme.textTertiary : holiday.color,
                  isFirst: isFirst,
                  isLast: isLast,
                  isGlow: !isPassed,
                ),
              ),
            ),

            // Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 24, 24),
                child: _TicketHolidayCard(holiday: holiday, isPassed: isPassed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION 9: TICKET CARD DESIGN
// =============================================================================

class _TicketHolidayCard extends StatelessWidget {
  final Holiday holiday;
  final bool isPassed;

  const _TicketHolidayCard({required this.holiday, required this.isPassed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Show Bottom Sheet Details using Get
        Get.bottomSheet(
          _HolidayDetailModal(holiday: holiday),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: isPassed ? AppTheme.shadowLow : AppTheme.shadowMedium,
          border: Border.all(color: AppTheme.divider),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Color Strip Header
              Container(
                height: 6,
                color: isPassed ? AppTheme.textTertiary : holiday.color,
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge & Type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CategoryBadge(
                            type: holiday.type,
                            color: isPassed ? AppTheme.textTertiary : holiday.color
                        ),
                        if (holiday.isOptional)
                          const Tooltip(
                            message: "Optional",
                            child: Icon(Icons.info_outline, size: 18, color: Colors.orange),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      holiday.title,
                      style: AppTheme.h3.copyWith(
                        color: isPassed ? AppTheme.textTertiary : AppTheme.textPrimary,
                        decoration: isPassed ? TextDecoration.lineThrough : null,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description Truncated
                    if (holiday.description.isNotEmpty)
                      Text(
                        holiday.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                      ),

                    const SizedBox(height: 16),

                    // Footer: Tap to view text
                    Row(
                      children: [
                        Text(
                            "Tap to view details",
                            style: AppTheme.label.copyWith(color: AppTheme.textTertiary)
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.textTertiary),
                      ],
                    )
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

// =============================================================================
// SECTION 10: CALENDAR VIEW (With RED BLUR)
// =============================================================================

class _CalendarView extends StatelessWidget {
  final List<Holiday> holidays;
  final Rx<DateTime> focusDate; // Passed as Rx from parent

  const _CalendarView({required this.holidays, required this.focusDate});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final focusedDate = focusDate.value;
        // Logic
        final daysInMonth = DateUtils.getDaysInMonth(focusedDate.year, focusedDate.month);
        final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
        final int emptySlots = firstDayOfMonth.weekday - 1;
        final int totalSlots = emptySlots + daysInMonth;

        return Column(
          children: [
            // Header
            _CalendarMonthNavigator(
              focusedDate: focusedDate,
              onChanged: (d) => focusDate.value = d,
            ),

            // Days Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                    .map((e) => Expanded(
                  child: Center(child: Text(e, style: AppTheme.label.copyWith(color: AppTheme.textSecondary))),
                ))
                    .toList(),
              ),
            ),

            // Grid
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: totalSlots,
              itemBuilder: (context, index) {
                if (index < emptySlots) return const SizedBox();

                final int dayNum = index - emptySlots + 1;
                final date = DateTime(focusedDate.year, focusedDate.month, dayNum);

                final dayHolidays = holidays.where((h) =>
                h.date.year == date.year && h.date.month == date.month && h.date.day == date.day
                ).toList();

                return _CalendarCell(date: date, holidays: dayHolidays);
              },
            ),

            const SizedBox(height: 32),

            // List below
            _MonthlyList(
                holidays: holidays.where((h) => h.date.year == focusedDate.year && h.date.month == focusedDate.month).toList()
            ),
          ],
        );
      }),
    );
  }
}

class _CalendarMonthNavigator extends StatelessWidget {
  final DateTime focusedDate;
  final Function(DateTime) onChanged;

  const _CalendarMonthNavigator({required this.focusedDate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassIconButton(icon: Icons.chevron_left, onTap: () => onChanged(DateTime(focusedDate.year, focusedDate.month - 1))),
          Text(DateFormat('MMMM yyyy').format(focusedDate), style: AppTheme.h2),
          _GlassIconButton(icon: Icons.chevron_right, onTap: () => onChanged(DateTime(focusedDate.year, focusedDate.month + 1))),
        ],
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final DateTime date;
  final List<Holiday> holidays;

  const _CalendarCell({required this.date, required this.holidays});

  @override
  Widget build(BuildContext context) {
    final bool isToday = DateUtils.isSameDay(date, DateTime.now());
    final bool hasEvents = holidays.isNotEmpty;
    final bool isPassed = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    // The "Red Blur" Logic requested
    final Color baseColor = hasEvents ? holidays.first.color : Colors.transparent;

    return GestureDetector(
      onTap: hasEvents ? () {
        Get.bottomSheet(
          _HolidayDetailModal(holiday: holidays.first),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        );
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          // BACKGROUND COLOR LOGIC
          color: hasEvents
              ? baseColor.withOpacity(isPassed ? 0.1 : 0.15) // Light tint
              : (isToday ? TColors.primary.withOpacity(0.05) : Colors.white),

          // BORDER LOGIC
          border: isToday
              ? Border.all(color: TColors.primary, width: 2)
              : (hasEvents ? Border.all(color: baseColor.withOpacity(0.3)) : null),

          // SHADOW LOGIC (THE BLUR)
          boxShadow: (hasEvents && !isPassed)
              ? [
            BoxShadow(
              color: baseColor.withOpacity(0.4), // The Glow color
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${date.day}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: hasEvents
                    ? baseColor.withOpacity(isPassed ? 0.6 : 1.0)
                    : (isToday ? TColors.primary : AppTheme.textSecondary),
              ),
            ),

            if (hasEvents) ...[
              const SizedBox(height: 4),
              Text(
                holidays.first.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: baseColor.withOpacity(isPassed ? 0.6 : 1.0),
                ),
              ),
            ],
          ],
        ),

      ),
    );
  }
}

class _MonthlyList extends StatelessWidget {
  final List<Holiday> holidays;
  const _MonthlyList({required this.holidays});

  @override
  Widget build(BuildContext context) {
    if (holidays.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 40, color: AppTheme.divider),
            const SizedBox(height: 10),
            Text("No events", style: AppTheme.bodySmall),
          ],
        ),
      );
    }

    return Column(
      children: holidays.map((h) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: _TicketHolidayCard(holiday: h, isPassed: h.date.isBefore(DateTime.now())),
      )).toList(),
    );
  }
}


// =============================================================================
// SECTION 11: DETAIL MODAL (BOTTOM SHEET)
// =============================================================================

class _HolidayDetailModal extends StatelessWidget {
  final Holiday holiday;
  const _HolidayDetailModal({required this.holiday});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 32),

          // Header
          Row(
            children: [
              _CategoryBadge(type: holiday.type, color: holiday.color),
              const Spacer(),
              Text(
                DateFormat('MMMM d, yyyy').format(holiday.date),
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(holiday.title, style: AppTheme.h1),
          const SizedBox(height: 16),

          Text(
            holiday.description.isEmpty ? "No detailed description provided for this holiday." : holiday.description,
            style: AppTheme.bodyLarge,
          ),

          const SizedBox(height: 40),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded),
                  label: const Text("Share"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.background,
                    foregroundColor: AppTheme.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text("Add to Calendar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: TColors.primary.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION 12: UTILITY WIDGETS
// =============================================================================

class _CategoryBadge extends StatelessWidget {
  final HolidayType type;
  final Color color;
  const _CategoryBadge({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: AppTheme.label.copyWith(color: color),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final Color color;
  final Color dotColor;
  final bool isFirst;
  final bool isLast;
  final bool isGlow;

  _TimelinePainter({required this.color, required this.dotColor, required this.isFirst, required this.isLast, this.isGlow = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    final paintDot = Paint()..color = dotColor..style = PaintingStyle.fill;
    final paintGlow = Paint()..color = dotColor.withOpacity(0.3)..style = PaintingStyle.fill;
    final paintWhite = Paint()..color = Colors.white..style = PaintingStyle.fill;

    double centerX = size.width / 2;
    double dotY = 32.0;

    if (!isFirst) canvas.drawLine(Offset(centerX, 0), Offset(centerX, dotY), paintLine);
    if (!isLast) canvas.drawLine(Offset(centerX, dotY), Offset(centerX, size.height), paintLine);

    // Glow
    if (isGlow) canvas.drawCircle(Offset(centerX, dotY), 12, paintGlow);
    // Dot Outer
    canvas.drawCircle(Offset(centerX, dotY), 6, paintDot);
    // Dot Inner
    canvas.drawCircle(Offset(centerX, dotY), 2.5, paintWhite);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 80, color: AppTheme.divider),
          const SizedBox(height: 16),
          Text("No Holidays Found", style: AppTheme.h2.copyWith(color: AppTheme.textTertiary)),
          const SizedBox(height: 8),
          Text("Try changing your search or filter.", style: AppTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorStateWidget({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.cloud_off_rounded, size: 60, color: Colors.red.shade300),
      const SizedBox(height: 16),
      Text("Something went wrong", style: AppTheme.h3),
      const SizedBox(height: 24),
      ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, foregroundColor: Colors.white),
          child: const Text("Retry Connection")
      )
    ]));
  }
}

class _ShimmerTicket extends StatefulWidget {
  const _ShimmerTicket();
  @override
  State<_ShimmerTicket> createState() => _ShimmerTicketState();
}

class _ShimmerTicketState extends State<_ShimmerTicket> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
      ),
    );
  }
}