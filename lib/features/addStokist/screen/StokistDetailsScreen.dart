import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/features/addStokist/model/Stokist.dart';

import '../../../utils/constants/colors.dart';
// new code

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
// Ensure this import points to your new Model file
import '../model/Stokist.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure this is in pubspec.yaml
import '../model/Stokist.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure this is in pubspec.yaml
import '../model/Stokist.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../model/Stokist.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../model/Stokist.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Add intl to pubspec.yaml for date formatting
import '../model/Stokist.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../model/Stokist.dart';

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../model/Stokist.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../model/Stokist.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart'; // Add to pubspec.yaml
import 'package:intl/intl.dart'; // Add to pubspec.yaml
import '../model/Stokist.dart';

// ==============================================================================
// 1. MAIN SCREEN ORCHESTRATOR
// ==============================================================================

class StokistDetailScreen extends StatefulWidget {
  final Stockist stokist;

  const StokistDetailScreen({Key? key, required this.stokist}) : super(key: key);

  @override
  State<StokistDetailScreen> createState() => _StokistDetailScreenState();
}

class _StokistDetailScreenState extends State<StokistDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _entryAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryAnimationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryAnimationController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _entryAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;

            final bool isTabletWidth = width > 700;
            final bool isLandscape = width > height;

            if (isLandscape) {
              // LANDSCAPE MODE (Split View)
              return _LandscapeSplitLayout(
                stokist: widget.stokist,
                tabController: _tabController,
                entranceAnim: _fadeAnimation,
                isCompactHeight: height < 500,
              );
            } else {
              // PORTRAIT MODE (Parallax Header)
              return _PortraitParallaxLayout(
                stokist: widget.stokist,
                tabController: _tabController,
                isTablet: isTabletWidth,
                entranceAnim: _fadeAnimation,
                slideAnim: _slideAnimation,
              );
            }
          },
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fadeAnimation,
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // Placeholder for Edit
          },
          backgroundColor: TColors.primary,
          child: const Icon(Icons.edit_outlined, color: Colors.white),
        ),
      ),
    );
  }
}

// ==============================================================================
// 2. LAYOUT STRATEGIES
// ==============================================================================

class _PortraitParallaxLayout extends StatelessWidget {
  final Stockist stokist;
  final TabController tabController;
  final bool isTablet;
  final Animation<double> entranceAnim;
  final Animation<Offset> slideAnim;

  const _PortraitParallaxLayout({
    required this.stokist,
    required this.tabController,
    required this.isTablet,
    required this.entranceAnim,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context) {
    // Compact Header Height
    final double headerHeight = isTablet ? 300.0 : 260.0;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: headerHeight,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: TColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _ParallaxHeaderBackground(
                stokist: stokist,
                isCompact: false,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _GlassmorphicTabBar(
                controller: tabController,
                isLightMode: false,
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: tabController,
        children: [
          // IMPORTANT: showTopSummary: true ensures stats appear in Portrait
          _OverviewTab(
            stokist: stokist,
            fadeAnim: entranceAnim,
            slideAnim: slideAnim,
            showTopSummary: true,
            isWideLayout: isTablet,
          ),
          _DocumentsTab(
            stokist: stokist,
            fadeAnim: entranceAnim,
            isWideLayout: isTablet,
          ),
          _FinancialsTab(
            stokist: stokist,
            fadeAnim: entranceAnim,
            isWideLayout: isTablet,
          ),
          _LocationTab(stokist: stokist),
        ],
      ),
    );
  }
}

class _LandscapeSplitLayout extends StatelessWidget {
  final Stockist stokist;
  final TabController tabController;
  final Animation<double> entranceAnim;
  final bool isCompactHeight;

  const _LandscapeSplitLayout({
    required this.stokist,
    required this.tabController,
    required this.entranceAnim,
    required this.isCompactHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double sidebarWidth = isCompactHeight ? 280 : 350;

    return SafeArea(
      left: true, right: true, bottom: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Fixes White Screen
        children: [
          SizedBox(
            width: sidebarWidth,
            child: Material(
              color: Colors.white,
              elevation: 4,
              child: Column(
                children: [
                  SizedBox(
                    height: isCompactHeight ? 140 : 240,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: TColors.primary),
                        Positioned(
                          top: 10, left: 10,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Center(
                          child: _ParallaxHeaderContent(
                            stokist: stokist,
                            isCompact: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _QuickActionsGrid(stokist: stokist),
                          const Divider(height: 30),
                          _SidebarStatTile(
                            label: "Experience",
                            value: "${stokist.yearsInBusiness ?? 0} Yrs",
                            icon: Icons.history_edu,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _SidebarStatTile(
                            label: "Sales Reps",
                            value: "${stokist.numberOfSalesRepresentatives ?? 0}",
                            icon: Icons.groups,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: _GlassmorphicTabBar(
                    controller: tabController,
                    isLightMode: true,
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF0F2F5),
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        _OverviewTab(
                          stokist: stokist,
                          fadeAnim: entranceAnim,
                          slideAnim: const AlwaysStoppedAnimation(Offset.zero),
                          showTopSummary: false, // Hidden here because it's in sidebar
                          isWideLayout: true,
                        ),
                        _DocumentsTab(stokist: stokist, fadeAnim: entranceAnim, isWideLayout: true),
                        _FinancialsTab(stokist: stokist, fadeAnim: entranceAnim, isWideLayout: true),
                        _LocationTab(stokist: stokist),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 3. TAB IMPLEMENTATIONS
// ==============================================================================

class _OverviewTab extends StatelessWidget {
  final Stockist stokist;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final bool showTopSummary;
  final bool isWideLayout;

  const _OverviewTab({
    required this.stokist,
    required this.fadeAnim,
    required this.slideAnim,
    required this.showTopSummary,
    required this.isWideLayout,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Safe handling of the list (Fixes the Null subtype error)
    // We default to an empty list [] if the data is null
    final List<String> distributorships = stokist.currentPharmaDistributorships ?? [];

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // TOP SUMMARY SECTION (Portrait Only)
            if (showTopSummary) ...[
              _QuickActionsGrid(stokist: stokist),
              const SizedBox(height: 24),
              Row(
                children: [
                  _ExpandedStatCard(
                    label: "Years Exp",
                    value: "${stokist.yearsInBusiness}",
                    icon: Icons.history,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _ExpandedStatCard(
                    label: "Sales Reps",
                    value: "${stokist.numberOfSalesRepresentatives ?? 0}",
                    icon: Icons.people_outline,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _ExpandedStatCard(
                    label: "Storage",
                    value: "${stokist.storageFacilitySize ?? 0}",
                    unit: "sqft",
                    icon: Icons.warehouse_outlined,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],

            // 1. INFRASTRUCTURE
            _SectionHeader(title: "INFRASTRUCTURE", icon: Icons.domain),
            const SizedBox(height: 12),
            Row(
              children: [
                _FacilityStatusCard(
                  label: "Warehouse",
                  isActive: stokist.warehouseFacility == true,
                  activeIcon: Icons.check_circle,
                  inactiveIcon: Icons.cancel,
                ),
                const SizedBox(width: 12),
                _FacilityStatusCard(
                  label: "Cold Storage",
                  isActive: stokist.coldStorageAvailable == true,
                  activeIcon: Icons.ac_unit,
                  inactiveIcon: Icons.ac_unit,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 2. COMPANY PROFILE
            _SectionHeader(title: "COMPANY PROFILE", icon: Icons.business),
            const SizedBox(height: 12),
            _NeumorphicCard(
              children: [
                _DetailRow(label: "Registered Name", value: stokist.registeredBusinessName),
                _DetailRow(label: "Head Office", value: stokist.headOffice?.name),
                _DetailRow(label: "Business Type", value: stokist.natureOfBusiness),
                const Divider(height: 24),
                _DetailRow(label: "GST Number", value: stokist.gstNumber, isCopyable: true),
                _DetailRow(label: "PAN Number", value: stokist.panNumber, isCopyable: true),
                _DetailRow(label: "Drug License", value: stokist.drugLicenseNumber, isCopyable: true),
              ],
            ),
            const SizedBox(height: 30),

            // 3. CONTACT INFO
            _SectionHeader(title: "CONTACT INFO", icon: Icons.contact_phone),
            const SizedBox(height: 12),
            _NeumorphicCard(
              children: [
                _DetailRow(label: "Contact Person", value: stokist.contactPerson, isBold: true),
                _DetailRow(label: "Designation", value: stokist.designation),
                const Divider(height: 24),
                _DetailRow(label: "Mobile", value: stokist.mobileNumber, isLink: true,
                    onTap: () => _UrlLauncher.launchPhone(stokist.mobileNumber)),
                _DetailRow(label: "Email", value: stokist.emailAddress, isLink: true,
                    onTap: () => _UrlLauncher.launchEmail(stokist.emailAddress)),
                _DetailRow(label: "Address", value: stokist.registeredOfficeAddress, maxLines: 3),
              ],
            ),
            const SizedBox(height: 30),

            // 4. DISTRIBUTORSHIPS (Fixed Logic)
            if (distributorships.isNotEmpty) ...[
              _SectionHeader(title: "DISTRIBUTORSHIPS", icon: Icons.local_shipping),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: distributorships.map((d) => _ModernChip(label: d)).toList(),
              ),
              const SizedBox(height: 30),
            ],

            _BuildFooter(stokist: stokist),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  final Stockist stokist;
  final Animation<double> fadeAnim;
  final bool isWideLayout;

  const _DocumentsTab({required this.stokist, required this.fadeAnim, required this.isWideLayout});

  @override
  Widget build(BuildContext context) {
    final docs = [
      {'title': 'Geo Location Image', 'url': stokist.geoImageUrl}, // Added this
      {'title': 'GST Certificate', 'url': stokist.gstCertificateUrl},
      {'title': 'Drug License', 'url': stokist.drugLicenseUrl},
      {'title': 'PAN Card', 'url': stokist.panCardUrl},
      {'title': 'Cancelled Cheque', 'url': stokist.cancelledChequeUrl},
      {'title': 'Business Profile', 'url': stokist.businessProfileUrl},
    ].where((d) => d['url'] != null && d['url']!.isNotEmpty).toList();

    if (docs.isEmpty) {
      return const _EmptyStateWidget(
        icon: Icons.folder_off_outlined,
        title: "No Documents",
        subtitle: "No verification documents uploaded.",
      );
    }

    int crossAxisCount = isWideLayout ? 4 : 2;

    return FadeTransition(
      opacity: fadeAnim,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          return _DocumentThumbnailCard(
            title: docs[index]['title']!,
            url: docs[index]['url']!,
          );
        },
      ),
    );
  }
}

class _FinancialsTab extends StatelessWidget {
  final Stockist stokist;
  final Animation<double> fadeAnim;
  final bool isWideLayout;

  const _FinancialsTab({
    required this.stokist,
    required this.fadeAnim,
    required this.isWideLayout
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 1. BANKING DETAILS SECTION
          _SectionHeader(title: "BANKING DETAILS", icon: Icons.account_balance_wallet),
          const SizedBox(height: 16),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              // New Premium Bank Card
              child: _ManagedBankInfoCard(details: stokist.bankDetails),
            ),
          ),

          const SizedBox(height: 40),

          // 2. TURNOVER HISTORY SECTION
          _SectionHeader(title: "ANNUAL TURNOVER", icon: Icons.bar_chart),
          const SizedBox(height: 20),

          if (stokist.annualTurnover != null && stokist.annualTurnover!.isNotEmpty) ...[
            // New Animated Chart Widget
            SizedBox(
              height: 280, // Increased height for labels
              child: _AnimatedTurnoverChart(
                data: stokist.annualTurnover!,
              ),
            ),
            const SizedBox(height: 30),

            // Text List Summary
            ...stokist.annualTurnover!.map((t) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: _TurnoverListItem(year: t.year, amount: t.amount),
              ),
            )).toList(),
          ] else
            const _EmptyStateWidget(
              icon: Icons.show_chart,
              title: "No Financial Data",
              subtitle: "Turnover history is unavailable.",
              isSmall: true,
            ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

// --- NEW PREMIUM BANK CARD ---
class _ManagedBankInfoCard extends StatelessWidget {
  final BankDetails? details;

  const _ManagedBankInfoCard({this.details});

  @override
  Widget build(BuildContext context) {
    if (details == null) {
      return const _EmptyStateWidget(
        icon: Icons.account_balance_outlined,
        title: "No Banking Record",
        subtitle: "Bank details not yet added",
        isSmall: true,
      );
    }

    final rawAcct = details!.accountNumber ?? "";
    final maskedAcct = _maskAccount(rawAcct);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            TColors.primary.withOpacity(0.95),
            TColors.primary.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          Row(
            children: [
              Icon(Icons.account_balance, color: Colors.white.withOpacity(0.9), size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Banking Information",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Managed & secured by Gluckscare",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _StatusChip(),
            ],
          ),

          const SizedBox(height: 28),

          // --- ACCOUNT NUMBER ---
          Text(
            "ACCOUNT NUMBER",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 9,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                maskedAcct,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              _CopyButton(value: rawAcct),
            ],
          ),

          const SizedBox(height: 26),

          // --- BANK META DATA ---
          Row(
            children: [
              Expanded(
                child: _MetaItem(
                  label: "BANK",
                  value: details!.bankName,
                ),
              ),
              Expanded(
                child: _MetaItem(
                  label: "BRANCH",
                  value: details!.branch,
                ),
              ),
              Expanded(
                child: _MetaItem(
                  label: "IFSC",
                  value: details!.ifscCode,
                  alignRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  String _maskAccount(String acc) {
    if (acc.length <= 4) return acc;
    return "•••• •••• ${acc.substring(acc.length - 4)}";
  }
}

class _StatusChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Icon(Icons.verified, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            "Verified",
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}


class _MetaItem extends StatelessWidget {
  final String label;
  final String? value;
  final bool alignRight;

  const _MetaItem({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 9,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value ?? "-",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String value;

  const _CopyButton({required this.value});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Account number copied"),
            backgroundColor: TColors.primary,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.copy, size: 14, color: Colors.white),
      ),
    );
  }
}



// Helper Widget for neat columns
class _CardDetailItem extends StatelessWidget {
  final String label;
  final String? value;
  final bool isRightAlign;

  const _CardDetailItem({
    required this.label,
    required this.value,
    this.isRightAlign = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isRightAlign ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value ?? "-",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// --- NEW ANIMATED CHART WIDGET ---
class _AnimatedTurnoverChart extends StatefulWidget {
  final List<AnnualTurnover> data;
  const _AnimatedTurnoverChart({required this.data});

  @override
  State<_AnimatedTurnoverChart> createState() => _AnimatedTurnoverChartState();
}

class _AnimatedTurnoverChartState extends State<_AnimatedTurnoverChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    // Elastic curve gives it a nice "bounce" effect when growing
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _TurnoverChartPainter(
            data: widget.data,
            animationValue: _animation.value,
            barColor: TColors.primary, // Make sure TColors is imported
          ),
        );
      },
    );
  }
}

// --- NEW CHART PAINTER LOGIC ---
class _TurnoverChartPainter extends CustomPainter {
  final List<AnnualTurnover> data;
  final double animationValue;
  final Color barColor;

  _TurnoverChartPainter({
    required this.data,
    required this.animationValue,
    required this.barColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Layout config
    const double bottomPadding = 30.0; // Space for Years
    const double topPadding = 20.0;    // Space for Amount Labels
    final double chartHeight = size.height - bottomPadding - topPadding;
    final double w = size.width;

    // Grid Paint
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw Grid Lines
    for (int i = 0; i <= 4; i++) {
      double y = topPadding + chartHeight - (chartHeight * (i / 4));
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Calculate Max Value
    int max = data.map((e) => e.amount ?? 0).reduce(math.max);
    if (max == 0) max = 1;
    double maxVal = max * 1.2; // Add 20% headroom

    // Bar Layout
    double groupWidth = w / data.length;
    double barWidth = groupWidth * 0.4; // Bar takes 40% of slot
    double spacing = groupWidth * 0.3;  // Spacing

    final Paint barPaint = Paint();

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      double amount = (item.amount ?? 0).toDouble();

      // Calculate Bar Height based on animation
      double h = (amount / maxVal) * chartHeight * animationValue;

      // Calculate Position
      double left = (i * groupWidth) + (groupWidth - barWidth) / 2;
      double top = topPadding + chartHeight - h;

      Rect barRect = Rect.fromLTWH(left, top, barWidth, h);

      // Draw Gradient Bar
      if (h > 0) {
        barPaint.shader = ui.Gradient.linear(
          barRect.bottomCenter,
          barRect.topCenter,
          [barColor.withOpacity(0.4), barColor],
        );

        canvas.drawRRect(
            RRect.fromRectAndCorners(
                barRect,
                topLeft: const Radius.circular(6),
                topRight: const Radius.circular(6)
            ),
            barPaint
        );
      }

      // Draw Text Labels (Only show when animation is near end)
      if (animationValue > 0.6) {
        // 1. Year Label (Bottom)
        _drawText(
            canvas,
            item.year.toString(),
            Offset(left + barWidth/2, size.height - 15),
            const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold)
        );

        // 2. Amount Label (Top of Bar)
        String formattedAmount = _formatCompact(amount);
        _drawText(
            canvas,
            formattedAmount,
            Offset(left + barWidth/2, top - 12),
            TextStyle(color: barColor, fontSize: 10, fontWeight: FontWeight.bold)
        );
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset center, TextStyle style) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  // Format helper: 1500000 -> 15L or 1.5M depending on preference
  String _formatCompact(double value) {
    if (value >= 10000000) return "₹${(value / 10000000).toStringAsFixed(1)}Cr";
    if (value >= 100000) return "₹${(value / 100000).toStringAsFixed(1)}L";
    if (value >= 1000) return "₹${(value / 1000).toStringAsFixed(0)}k";
    return "₹${value.toInt()}";
  }

  @override
  bool shouldRepaint(covariant _TurnoverChartPainter old) => old.animationValue != animationValue;
}

class _LocationTab extends StatelessWidget {
  final Stockist stokist;
  const _LocationTab({required this.stokist});

  @override
  Widget build(BuildContext context) {
    final double? lat = double.tryParse(stokist.latitude ?? "");
    final double? lng = double.tryParse(stokist.longitude ?? "");

    if (lat == null || lng == null) {
      return const _EmptyStateWidget(icon: Icons.location_off, title: "Location Missing", subtitle: "Coordinates not available.");
    }

    final LatLng position = LatLng(lat, lng);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 15),
          markers: { Marker(markerId: const MarkerId('s'), position: position, infoWindow: InfoWindow(title: stokist.firmName)) },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          bottom: 30, left: 20, right: 20,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [Icon(Icons.location_on, color: Colors.redAccent), SizedBox(width: 8), Text("REGISTERED OFFICE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))]),
                  const SizedBox(height: 10),
                  Text(stokist.registeredOfficeAddress ?? "Unknown", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () => _UrlLauncher.launchMap(stokist.latitude, stokist.longitude),
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text("NAVIGATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==============================================================================
// 4. COMPONENTS & UTILITIES
// ==============================================================================

class _ParallaxHeaderBackground extends StatelessWidget {
  final Stockist stokist;
  final bool isCompact;

  const _ParallaxHeaderBackground({
    required this.stokist,
    required this.isCompact
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. BANNER IMAGE (Asset)
        // Make sure to add this image to your pubspec.yaml assets section
        Image.asset(
          "assets/logos/cover.png", // <--- REPLACE THIS WITH YOUR ASSET PATH
          fit: BoxFit.fitWidth,
          width: double.infinity, // Fills full X-axis
          height: 119,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to solid color if image is missing
            return Container(color: TColors.primary);
          },
        ),

        // 2. DARK OVERLAY
        // This ensures the white text remains readable over any image
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3), // Lighter at top
                Colors.black.withOpacity(0.7), // Darker at bottom
              ],
            ),
          ),
        ),

        // 3. CONTENT
        // We pass disableBackground: true so it doesn't draw its own gradient
        SafeArea(
          child: Center(
            child: _ParallaxHeaderContent(
              stokist: stokist,
              isCompact: isCompact,
              disableBackground: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _ParallaxHeaderContent extends StatelessWidget {
  final Stockist stokist;
  final bool isCompact;
  final bool disableBackground;

  const _ParallaxHeaderContent({required this.stokist, required this.isCompact, this.disableBackground = false});

  @override
  Widget build(BuildContext context) {
    String init = (stokist.firmName ?? "S").trim();
    if(init.isNotEmpty) init = init[0].toUpperCase();

    double r = isCompact ? 30 : 40;
    double fontSize = isCompact ? 18 : 22;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white30, width: 2)),
          child: CircleAvatar(
            radius: r, backgroundColor: Colors.white,
            child: Text(init, style: TextStyle(fontSize: r * 0.6, fontWeight: FontWeight.w900, color: TColors.primary)),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
              stokist.firmName ?? "Unknown",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
          child: Text(
              (stokist.natureOfBusiness ?? "DISTRIBUTOR").toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );

    if (!disableBackground) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [TColors.primary, TColors.primary.withBlue(140)]))),
          Positioned(top: -90, right: -60, child: CircleAvatar(radius: 120, backgroundColor: Colors.white.withOpacity(0.04))),
          Positioned(bottom: 10, left: -40, child: CircleAvatar(radius: 90, backgroundColor: Colors.white.withOpacity(0.04))),
          SafeArea(child: Center(child: content)),
        ],
      );
    }
    return content;
  }
}

class _GlassmorphicTabBar extends StatelessWidget {
  final TabController controller;
  final bool isLightMode;
  const _GlassmorphicTabBar({required this.controller, required this.isLightMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLightMode ? Colors.white : TColors.primary,
        border: isLightMode ? const Border(bottom: BorderSide(color: Colors.black12)) : null,
      ),
      child: TabBar(
        controller: controller,
        labelColor: isLightMode ? TColors.primary : Colors.white,
        unselectedLabelColor: isLightMode ? Colors.grey : Colors.white60,
        indicatorColor: isLightMode ? TColors.primary : Colors.white,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
        tabs: const [Tab(text: "OVERVIEW"), Tab(text: "DOCS"), Tab(text: "FINANCE"), Tab(text: "MAP")],
      ),
    );
  }
}

class _GlassTabBar extends StatelessWidget {
  // Legacy Alias
  final TabController tabController;
  final bool isColored;
  const _GlassTabBar({required this.tabController, this.isColored = false});
  @override
  Widget build(BuildContext context) {
    return _GlassmorphicTabBar(controller: tabController, isLightMode: isColored);
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final Stockist stokist;
  const _QuickActionsGrid({required this.stokist});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionBubble(icon: Icons.call, label: "Call", color: Colors.green, onTap: () => _UrlLauncher.launchPhone(stokist.mobileNumber)),
        _ActionBubble(icon: Icons.email, label: "Email", color: Colors.orange, onTap: () => _UrlLauncher.launchEmail(stokist.emailAddress)),
        _ActionBubble(icon: Icons.near_me, label: "Navigate", color: Colors.blue, onTap: () => _UrlLauncher.launchMap(stokist.latitude, stokist.longitude)),
      ],
    );
  }
}

class _ActionBubble extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionBubble({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        ]),
      ),
    );
  }
}

class _ExpandedStatCard extends StatelessWidget {
  final String label, value; final String? unit; final IconData icon; final Color color;
  const _ExpandedStatCard({required this.label, required this.value, this.unit, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18), maxLines: 1),
              if(unit!=null) Text(unit!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _FacilityStatusCard extends StatelessWidget {
  final String label; final bool isActive; final IconData activeIcon; final IconData inactiveIcon;
  const _FacilityStatusCard({required this.label, required this.isActive, required this.activeIcon, required this.inactiveIcon});
  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.grey;
    return Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isActive ? color.withOpacity(0.3) : Colors.grey.shade200)), child: Row(children: [Icon(isActive ? activeIcon : inactiveIcon, color: color, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(isActive ? "Available" : "No", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color))]))])));
  }
}

class _NeumorphicCard extends StatelessWidget {
  final List<Widget> children;
  const _NeumorphicCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))]), child: Column(children: children));
  }
}

class _DetailCard extends StatelessWidget {
  // Alias
  final List<Widget> children;
  const _DetailCard({required this.children});
  @override
  Widget build(BuildContext context) => _NeumorphicCard(children: children);
}

class _DetailRow extends StatelessWidget {
  final String label; final String? value; final bool isBold, isLink, isCopyable; final int maxLines; final VoidCallback? onTap;
  const _DetailRow({required this.label, this.value, this.isBold=false, this.isLink=false, this.isCopyable=false, this.maxLines=1, this.onTap});
  @override
  Widget build(BuildContext context) {
    if(value==null || value!.isEmpty) return const SizedBox.shrink();
    Widget content = Text(value!, textAlign: TextAlign.right, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: isBold?FontWeight.bold:FontWeight.normal, color: isLink?Colors.blue:Colors.black87, fontSize: 13, decoration: isLink?TextDecoration.underline:null));
    if(onTap!=null) content = GestureDetector(onTap: onTap, child: content);
    else if(isCopyable) content = GestureDetector(onTap: () { Clipboard.setData(ClipboardData(text: value!)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard!"), duration: Duration(milliseconds: 600))); }, child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: content), const SizedBox(width: 6), Icon(Icons.copy, size: 12, color: Colors.grey[400])]));
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: maxLines>1?CrossAxisAlignment.start:CrossAxisAlignment.center, children: [Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)), const SizedBox(width: 12), Expanded(child: Align(alignment: Alignment.centerRight, child: content))]));
  }
}

class _InfoRow extends StatelessWidget {
  // Alias
  final String label; final String? value; final bool isBold, isLink, isCopyable; final int maxLines; final VoidCallback? onTap;
  const _InfoRow({required this.label, this.value, this.isBold=false, this.isLink=false, this.isCopyable=false, this.maxLines=1, this.onTap});
  @override
  Widget build(BuildContext context) => _DetailRow(label: label, value: value, isBold: isBold, isLink: isLink, isCopyable: isCopyable, maxLines: maxLines, onTap: onTap);
}

class _SectionHeader extends StatelessWidget {
  final String title; final IconData icon;
  const _SectionHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: 18, color: TColors.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 1.0))]);
  }
}

class _SectionTitle extends StatelessWidget {
  // Alias
  final String title; final IconData icon;
  const _SectionTitle({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => _SectionHeader(title: title, icon: icon);
}

class _ModernChip extends StatelessWidget {
  final String label;
  const _ModernChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]), child: Text(label, style: TextStyle(color: Colors.grey[800], fontSize: 12, fontWeight: FontWeight.w600)));
  }
}

class _TagChip extends StatelessWidget {
  // Alias
  final String label; final bool isSecondary;
  const _TagChip({required this.label, this.isSecondary=false});
  @override
  Widget build(BuildContext context) => _ModernChip(label: label);
}

class _SidebarStatTile extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _SidebarStatTile({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)), child: Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 6), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1), Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))]));
  }
}

class _PremiumBankCard extends StatelessWidget {
  final BankDetails? details;
  const _PremiumBankCard({this.details});
  @override
  Widget build(BuildContext context) {
    if(details==null) return const _EmptyStateWidget(icon: Icons.credit_card_off, title: "No Bank Details", subtitle: "Missing info");
    return Container(
      height: 200, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.grey.shade900, const Color(0xFF2C3E50)]), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Icon(Icons.account_balance, color: Colors.white60), Text("DEBIT", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold))]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(details?.bankName?.toUpperCase() ?? "BANK NAME", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text((details?.accountNumber??"0000").replaceAllMapped(RegExp(r".{4}"), (m)=>"${m.group(0)} "), style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'monospace'))]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_BankLabel(label: "IFSC", value: details?.ifscCode), _BankLabel(label: "BRANCH", value: details?.branch, alignRight: true)])
      ]),
    );
  }
}

class _DigitalBankCard extends StatelessWidget {
  // Alias
  final BankDetails? details;
  const _DigitalBankCard({this.details});
  @override
  Widget build(BuildContext context) => _PremiumBankCard(details: details);
}

class _BankLabel extends StatelessWidget {
  final String label; final String? value; final bool alignRight;
  const _BankLabel({required this.label, this.value, this.alignRight = false});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)), Text(value ?? "-", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]);
  }
}

class _DocumentThumbnailCard extends StatelessWidget {
  final String title, url;
  const _DocumentThumbnailCard({required this.title, required this.url});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _FullScreenViewer(url: url, title: title))), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Hero(tag: url, child: Image.network(url, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Center(child: Icon(Icons.broken_image, color: Colors.grey)))))), Padding(padding: const EdgeInsets.all(12), child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1))])));
  }
}

class _DocumentThumbnail extends StatelessWidget {
  // Alias
  final String title, url;
  const _DocumentThumbnail({required this.title, required this.url});
  @override
  Widget build(BuildContext context) => _DocumentThumbnailCard(title: title, url: url);
}

class _DocumentCard extends StatelessWidget {
  // Alias
  final String title, url;
  const _DocumentCard({required this.title, required this.url});
  @override
  Widget build(BuildContext context) => _DocumentThumbnailCard(title: title, url: url);
}

class _TurnoverListItem extends StatelessWidget {
  final int? year, amount;
  const _TurnoverListItem({this.year, this.amount});
  @override
  Widget build(BuildContext context) {
    if(amount==null) return const SizedBox.shrink();
    String fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount);
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("FY $year", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)), Text(fmt, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900))]));
  }
}

class _TurnoverItem extends StatelessWidget {
  // Alias
  final int? year, amount;
  const _TurnoverItem({this.year, this.amount});
  @override
  Widget build(BuildContext context) => _TurnoverListItem(year: year, amount: amount);
}

class _TurnoverRow extends StatelessWidget {
  // Alias
  final int? year, amount;
  const _TurnoverRow({this.year, this.amount});
  @override
  Widget build(BuildContext context) => _TurnoverListItem(year: year, amount: amount);
}

class _BuildFooter extends StatelessWidget {
  final Stockist stokist;
  const _BuildFooter({required this.stokist});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            // Fix: Pass the DateTime object directly, don't cast to String
            "Created: ${_formatDate(stokist.createdAt)}",
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            "ID: ${stokist.id}",
            style: TextStyle(color: Colors.grey[300], fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return "N/A";
    try {
      // If it's already a DateTime object (which it is in your model)
      if (date is DateTime) {
        return DateFormat('dd MMM yyyy').format(date);
      }
      // If it happens to be a String, parse it
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date.toString()));
    } catch (e) {
      return "N/A";
    }
  }
}

class _SystemFooter extends StatelessWidget {
  // Alias
  final Stockist stokist;
  const _SystemFooter({required this.stokist});
  @override
  Widget build(BuildContext context) => _BuildFooter(stokist: stokist);
}

class _EmptyStateWidget extends StatelessWidget {
  final IconData icon; final String title, subtitle; final bool isSmall;
  const _EmptyStateWidget({required this.icon, required this.title, required this.subtitle, this.isSmall=false});
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: isSmall?40:60, color: Colors.grey[300]), const SizedBox(height: 16), Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12))])));
  }
}

class _EmptyState extends StatelessWidget {
  // Alias
  final IconData icon; final String title, subtitle; final bool isSmall;
  const _EmptyState({required this.icon, required this.title, required this.subtitle, this.isSmall=false});
  @override
  Widget build(BuildContext context) => _EmptyStateWidget(icon: icon, title: title, subtitle: subtitle, isSmall: isSmall);
}

class _FullScreenViewer extends StatelessWidget {
  final String url, title;
  const _FullScreenViewer({required this.url, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black, title: Text(title, style: const TextStyle(color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)), body: Center(child: Hero(tag: url, child: InteractiveViewer(child: Image.network(url)))));
  }
}

class _SimpleBarChartPainter extends CustomPainter {
  final List<AnnualTurnover> data; final Color barColor;
  _SimpleBarChartPainter({required this.data, required this.barColor});
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()..color = barColor.withOpacity(0.8)..style = PaintingStyle.fill;
    final grid = Paint()..color = Colors.grey.withOpacity(0.2)..strokeWidth = 1;
    int max = data.map((e)=>e.amount??0).reduce(math.max); if(max==0) max=1;
    double w = (size.width/data.length)*0.5; double sp = (size.width/data.length)*0.5;
    for(int i=0; i<data.length; i++) {
      double h = (data[i].amount??0)/max*size.height;
      double l = (sp/2)+(i*(w+sp));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(l, size.height-h, w, h), const Radius.circular(4)), paint);
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), grid);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _BarChartPainter extends CustomPainter {
  // Alias
  final List<AnnualTurnover> data; final Color barColor;
  _BarChartPainter({required this.data, required this.barColor});
  @override
  void paint(Canvas c, Size s) => _SimpleBarChartPainter(data: data, barColor: barColor).paint(c, s);
  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _InfoCardSmall extends StatelessWidget {
  // Alias for _FeatureCard to avoid confusion
  final String label, value; final IconData icon; final Color color;
  const _InfoCardSmall({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return _FeatureCard(label: label, value: value, isActive: true, activeIcon: icon, inactiveIcon: icon);
  }
}

class _FeatureCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isActive;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const _FeatureCard({
    required this.label,
    required this.value,
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.grey;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isActive ? color.withOpacity(0.3) : Colors.grey.shade200
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                    color: color.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)
                )
            ]
        ),
        child: Row(
          children: [
            Icon(
                isActive ? activeIcon : inactiveIcon,
                color: color,
                size: 20
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      label,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: color
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// COPY THIS NEW CLASS TO THE BOTTOM OF YOUR FILE
class _BankAccountCard extends StatelessWidget {
  final BankDetails? details;

  const _BankAccountCard({this.details});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text("Account number copied!"),
          ],
        ),
        backgroundColor: TColors.primary, // Updated to use your primary color
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
      ),
    );
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (details == null) {
      return const _EmptyStateWidget(
        icon: Icons.account_balance,
        title: "No Banking Info",
        subtitle: "Bank details not provided",
        isSmall: true,
      );
    }

    final String rawAcct = details?.accountNumber ?? "0000";
    final String formattedAcct = rawAcct.replaceAllMapped(
        RegExp(r".{4}"), (match) => "${match.group(0)} ");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // USE YOUR CUSTOM COLORS HERE
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TColors.primary,
            TColors.primary_shadow_light, // Make sure 'secondary' exists in your TColors class
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.4), // Matching shadow
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("BANK NAME", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600)),
                    Text(details?.bankName?.toUpperCase() ?? "UNKNOWN", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text("ACCOUNT NUMBER", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(formattedAcct, style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'monospace', fontWeight: FontWeight.bold))),
              IconButton(
                onPressed: () => _copyToClipboard(context, rawAcct),
                icon: const Icon(Icons.copy_all, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
              )
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BankDetailColumn(label: "IFSC CODE", value: details?.ifscCode),
              _BankDetailColumn(label: "BRANCH", value: details?.branch, isRight: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _BankDetailColumn extends StatelessWidget {
  final String label;
  final String? value;
  final bool isRight;
  const _BankDetailColumn({required this.label, required this.value, this.isRight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value?.toUpperCase() ?? "-", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _UrlLauncher {
  static Future<void> launchPhone(String? n) async { if(n!=null) await launchUrl(Uri(scheme: 'tel', path: n)); }
  static Future<void> launchEmail(String? e) async { if(e!=null) await launchUrl(Uri(scheme: 'mailto', path: e)); }
  static Future<void> launchUrlStr(String? u) async { if(u!=null) await launchUrl(Uri.parse(u.startsWith('http')?u:'https://$u')); }
  static Future<void> launchMap(String? lat, String? lng) async { if(lat!=null && lng!=null) { final u = Uri.parse("google.navigation:q=$lat,$lng"); if(await canLaunchUrl(u)) await launchUrl(u); }}
}
// old code
/*class StokistDetailScreen extends StatelessWidget {
  final Stockist stokist;


  const StokistDetailScreen({Key? key, required this.stokist}) : super(key: key);

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: TColors.primary,
      ),
    ),
  );

  Widget _infoRow(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value?.isNotEmpty == true ? value! : "-",
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    ),
  );

  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double latitude =  28.6139;
    final double longitude =  77.2090;

    return Scaffold(
      appBar: AppBar(
        title: Text(stokist.firmName ?? 'Stockist Details'),
        backgroundColor: TColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard("Basic Info", [
              _infoRow("Firm Name", stokist.firmName),
              _infoRow("Registered Name", stokist.registeredBusinessName),
              _infoRow("Nature of Business", stokist.natureOfBusiness),
              _infoRow("GST Number", stokist.gstNumber),
              _infoRow("PAN Number", stokist.panNumber),
              _infoRow("Drug License", stokist.drugLicenseNumber),
              _infoRow("Years in Business", stokist.yearsInBusiness?.toString()),
            ]),
            _sectionCard("Contact Info", [
              _infoRow("Contact Person", stokist.contactPerson),
              _infoRow("Designation", stokist.designation),
              _infoRow("Mobile", stokist.mobileNumber),
              _infoRow("Email", stokist.emailAddress),
              _infoRow("Website", stokist.website),
              _infoRow("Address", stokist.registeredOfficeAddress),
            ]),
            _sectionCard("Business Scope", [
              _infoRow("Areas of Operation",
                  stokist.areasOfOperation?.join(", ") ?? "-"),
              _infoRow("Distributorships",
                  stokist.currentPharmaDistributorships?.join(", ") ?? "-"),
            ]),
            _sectionCard("Facilities", [
              _infoRow("Warehouse Facility",
                  stokist.warehouseFacility == true ? "Yes" : "No"),
              _infoRow("Cold Storage",
                  stokist.coldStorageAvailable == true ? "Yes" : "No"),
              _infoRow("Storage Size",
                  stokist.storageFacilitySize?.toString() ?? "-"),
              _infoRow("Sales Reps",
                  stokist.numberOfSalesRepresentatives?.toString() ?? "-"),
            ]),
            *//*_sectionCard("Bank Details", [
              _infoRow("Bank Name", stokist.bankDetails?.bankName),
              _infoRow("Branch", stokist.bankDetails?.branch),
              _infoRow("Account No.", stokist.bankDetails?.accountNumber),
              _infoRow("IFSC", stokist.bankDetails?.ifscCode),
            ]),*//*
            if (stokist.annualTurnover != null &&
                stokist.annualTurnover!.isNotEmpty)
              _sectionCard("Annual Turnover", [
                ...stokist.annualTurnover!.map((t) => _infoRow(
                    "Year ${t.year}",
                    "₹ ${t.amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",")}"))
              ]),

            // 📍 MAP
            _sectionTitle("Location"),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("stokist_location"),
                      position: LatLng(latitude, longitude),
                      infoWindow: InfoWindow(
                          title: stokist.firmName ?? "Stockist Location"),
                    )
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
