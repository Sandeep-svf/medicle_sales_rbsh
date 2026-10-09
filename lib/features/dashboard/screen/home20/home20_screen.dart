import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/http/http_client.dart';
import '../../../../utils/http/api_ui_feedback.dart';
import '../../../expenses/screens/expense20/expense20_screen.dart';
import '../../../Tour & Plans/TeritoryModule/screen/map_beat_management/map_beat_management_screen.dart';
import '../../../visit/Doctor/screens/ScheduleVisit.dart';
import '../../../addProduct/screens/addProduct.dart';
import '../../../MarketingMaterials/Screens/MarketingMaterials.dart';
import '../../../report/screens/report.dart';
import 'home20_widgets.dart';

/// A separate presentation of the dashboard API; no existing controllers mutate.
class Home20Screen extends StatefulWidget {
  const Home20Screen(
      {super.key,
      this.loadDashboard,
      this.showHeader = true,
      this.onUserLoaded});
  final bool showHeader;
  final ValueChanged<Map<String, dynamic>>? onUserLoaded;
  static const menuTitle = 'Home 2.0';
  final Future<Map<String, dynamic>> Function()? loadDashboard;

  @override
  State<Home20Screen> createState() => _Home20ScreenState();
}

class _Home20ScreenState extends State<Home20Screen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  int _productTab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await (widget.loadDashboard?.call() ??
          THttpHelper.authGet('dashboard/user'));
      if (response['success'] == false || response['data'] is! Map) {
        throw Exception(
            response['message'] ?? 'Dashboard data is unavailable.');
      }
      if (!mounted) return;
      setState(() {
        _data = object(response['data']);
        _loading = false;
      });
      widget.onUserLoaded?.call(_section('user'));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = ApiUiFeedback.message(error);
        _loading = false;
      });
    }
  }

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  Map<String, dynamic> _section(String key) => object(_data?[key]);
  String _money(dynamic value) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
          .format(number(value));
  Widget _demoList(
          String title, IconData icon, List<(String, String, String)> rows) =>
      Home20Card(
          title: title,
          icon: icon,
          sample: true,
          child: Column(children: [
            for (final row in rows)
              Home20ListRow(
                  title: row.$1, subtitle: row.$2, trailing: row.$3, icon: icon)
          ]));

  @override
  Widget build(BuildContext context) {
    if (_loading && _data == null) {
      return const ColoredBox(
          color: TColors.primaryBackground,
          child: Center(child: CircularProgressIndicator()));
    }
    if (_data == null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 48, color: TColors.textSecondary),
                const SizedBox(height: 12),
                const Text('Unable to load Home 2.0'),
                const SizedBox(height: 8),
                Text(_error ?? 'Please try again.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.white),
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again')),
              ])));
    }
    final user = _section('user');
    final period = _section('period');
    final target = _section('targets');
    final expenses = _section('expenses');
    final visits = _section('visits');
    final beat = _section('todayBeatAssigned');
    final collab = _section('todayCollaboration');
    final doctor = object(visits['doctor']);
    final chemist = object(visits['chemist']);
    final stockist = object(visits['stockist']);
    final targetSample = target.isEmpty;
    final visitSample = visits.isEmpty;
    final expenseSample = expenses.isEmpty;
    final monthly = targetSample ? 25000 : number(target['monthlyTarget']);
    final achieved = targetSample ? 8869 : number(target['achieved']);
    final remaining = targetSample ? 16131 : number(target['remaining']);
    final percentage =
        targetSample ? 35.0 : number(target['achievementPercentage']);
    final name = (user['name'] ?? 'Welcome').toString();
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final periodName =
        '${period['monthName'] ?? DateFormat.MMMM().format(DateTime.now())} ${period['year'] ?? DateTime.now().year}';
    final targetPeriod = target['targetPeriod']?.toString() ?? periodName;
    final initials = name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join();
    return ColoredBox(
        color: TColors.primaryBackground,
        child: RefreshIndicator(
          onRefresh: _load,
          child: LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1050;
            final tablet = constraints.maxWidth >= 650;
            return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(tablet ? 12 : 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showHeader)
                        Home20Header(
                            title: '$greeting, $name',
                            subtitle:
                                '${user['role'] ?? 'Sales'} · $periodName',
                            controls: Row(
                                key: const ValueKey('home20-header-controls'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Home20Clock(),
                                  const SizedBox(width: 8),
                                  Tooltip(
                                      message: 'User profile',
                                      child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          onTap: () => showDialog<void>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                      title: Text(name),
                                                      content: Text(
                                                          '${user['role'] ?? 'Sales'}'
                                                          '${user['department'] == null ? '' : '\n${user['department']}'}'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                'Close'))
                                                      ])),
                                          child: CircleAvatar(
                                              backgroundColor: TColors.cardPink,
                                              child: Text(initials,
                                                  style: const TextStyle(
                                                      color:
                                                          TColors.primary))))),
                                ])),
                      if (widget.showHeader) const SizedBox(height: 12),
                      if (_loading) const LinearProgressIndicator(),
                      if (_error != null)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text('Showing last loaded data. $_error',
                                style: const TextStyle(color: TColors.error))),
                      Home20Grid(
                          columns: wide
                              ? 4
                              : tablet
                                  ? 2
                                  : 1,
                          children: [
                            Home20Metric(
                                title: 'Monthly target',
                                value: _money(monthly),
                                subtitle: targetPeriod,
                                icon: Icons.track_changes,
                                color: TColors.info,
                                sample: targetSample),
                            Home20Metric(
                                title: 'Achieved',
                                value: _money(achieved),
                                subtitle:
                                    '${percentage.toStringAsFixed(0)}% of target',
                                icon: Icons.bar_chart_rounded,
                                color: TColors.success,
                                sample: targetSample),
                            Home20Metric(
                                title: 'Remaining',
                                value: _money(remaining),
                                subtitle: 'Target balance',
                                icon: Icons.timelapse_rounded,
                                color: TColors.error,
                                sample: targetSample),
                            Home20Metric(
                                title: 'Expense claims',
                                value:
                                    '${expenseSample ? 4 : integer(expenses['total'])}',
                                subtitle:
                                    '${expenseSample ? 2 : integer(expenses['pending'])} pending',
                                icon: Icons.receipt_long_outlined,
                                color: TColors.primary,
                                sample: expenseSample),
                          ]),
                      const SizedBox(height: 8),
                      Home20Grid(
                          columns: wide
                              ? 3
                              : tablet
                                  ? 2
                                  : 1,
                          children: [
                            Home20Card(
                                title: 'Target progress',
                                icon: Icons.track_changes,
                                sample: targetSample,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(children: [
                                        Expanded(
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: LinearProgressIndicator(
                                                    value: (percentage / 100)
                                                        .clamp(0, 1),
                                                    minHeight: 18,
                                                    color: TColors.primary,
                                                    backgroundColor: TColors
                                                        .borderSecondary))),
                                        const SizedBox(width: 12),
                                        Text(
                                            '${percentage.toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                                color: TColors.primary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold))
                                      ]),
                                      const SizedBox(height: 24),
                                      Home20Grid(columns: 3, gap: 8, children: [
                                        _smallValue(
                                            'Achieved', _money(achieved)),
                                        _smallValue(
                                            'Remaining', _money(remaining)),
                                        _smallValue('Target', _money(monthly))
                                      ]),
                                      const SizedBox(height: 16),
                                      Text(
                                          target['displayMessage']
                                                  ?.toString() ??
                                              targetPeriod,
                                          style: const TextStyle(
                                              color: TColors.textSecondary,
                                              fontSize: 12)),
                                    ])),
                            const Home20Card(
                                title: 'Monthly performance',
                                icon: Icons.calendar_month_outlined,
                                sample: true,
                                child: Home20Performance()),
                            Home20Card(
                                title: 'My area',
                                icon: Icons.location_on_outlined,
                                action: 'Open map',
                                onAction: () =>
                                    _open(const MapBeatManagementScreen()),
                                sample: beat.isEmpty,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Home20ListRow(
                                          title:
                                              beat['beat_name']?.toString() ??
                                                  'Samastipur (HQ)',
                                          subtitle: beat.isEmpty
                                              ? 'Sample assigned territory'
                                              : '${beat['day_type'] ?? 'Work day'} · ${beat['status'] ?? 'Assigned'}',
                                          icon: Icons.location_on_outlined),
                                      Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            Chip(
                                                label: Text(
                                                    '${beat.isEmpty ? 12 : integer(beat['doctors_count'])} doctors')),
                                            Chip(
                                                label: Text(
                                                    '${beat.isEmpty ? 5 : integer(beat['chemists_count'])} chemists')),
                                            Chip(
                                                label: Text(
                                                    '${beat.isEmpty ? 2 : integer(beat['stockists_count'])} stockists')),
                                          ]),
                                    ])),
                          ]),
                      const SizedBox(height: 8),
                      Home20Grid(
                          columns: wide
                              ? 3
                              : tablet
                                  ? 2
                                  : 1,
                          children: [
                            Home20Card(
                                title: "Today's plan",
                                icon: Icons.event_note_outlined,
                                action: 'Visits',
                                onAction: () => _open(ScheduleVisit()),
                                sample: visitSample,
                                child: Column(children: [
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    Home20Ring(
                                        value: visitSample
                                            ? 0.6
                                            : (number(visits['total']) == 0
                                                ? 0
                                                : number(visits['confirmed']) /
                                                    number(visits['total'])),
                                        label: visitSample
                                            ? '6 / 10'
                                            : '${integer(visits['confirmed'])} / ${integer(visits['total'])}'),
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          _smallValue(
                                              'Doctor visits',
                                              visitSample
                                                  ? '6 completed'
                                                  : '${integer(doctor['confirmed'])} confirmed'),
                                          const SizedBox(height: 14),
                                          _smallValue(
                                              'Chemist visits',
                                              visitSample
                                                  ? '3 completed'
                                                  : '${integer(chemist['confirmed'])} confirmed'),
                                        ])),
                                  ]),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                              backgroundColor: TColors.primary,
                                              foregroundColor: TColors.white),
                                          onPressed: () =>
                                              _open(ScheduleVisit()),
                                          icon: const Icon(Icons.add),
                                          label: const Text('Open visits'))),
                                ])),
                            _demoList('Upcoming schedule',
                                Icons.schedule_outlined, const [
                              (
                                'Dr. S. Kumar',
                                'Child specialist · Samastipur City',
                                '10:00 AM'
                              ),
                              (
                                'City Care Pharma',
                                'Chemist · Second visit',
                                '11:30 AM'
                              ),
                              (
                                'Dr. Neha Singh',
                                'General physician · Samastipur',
                                '01:00 PM'
                              ),
                            ]),
                            _demoList('Recent invoices',
                                Icons.description_outlined, const [
                              (
                                'GSK/2026-27/006',
                                'Singh Medical Hall',
                                '₹5,400'
                              ),
                              ('GSK/2026-27/005', 'Santosh Medical', '₹3,900'),
                              ('GSK/2026-27/004', 'Life Care Stores', '₹6,125'),
                            ]),
                          ]),
                      const SizedBox(height: 8),
                      Home20Grid(
                          columns: wide
                              ? 3
                              : tablet
                                  ? 2
                                  : 1,
                          children: [
                            _products(compact: true),
                            Home20Card(
                                title: 'Important updates',
                                icon: Icons.campaign_outlined,
                                sample: collab.isEmpty,
                                child: collab.isEmpty
                                    ? const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                            Home20ListRow(
                                                title: 'New product focus',
                                                subtitle:
                                                    'Explore your product portfolio.',
                                                icon: Icons
                                                    .notifications_outlined,
                                                trailing: 'Sample'),
                                            Home20ListRow(
                                                title: 'Field readiness',
                                                subtitle:
                                                    'Review your plan before starting visits.',
                                                icon: Icons
                                                    .event_available_outlined),
                                            Home20ListRow(
                                                title: 'Expense reminder',
                                                subtitle:
                                                    'Review the TA and DA eligibility policy.',
                                                icon: Icons.receipt_outlined),
                                          ])
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                            Home20ListRow(
                                                title: collab[
                                                            'hasCollaboration'] ==
                                                        true
                                                    ? 'Joint work planned'
                                                    : 'No collaboration today',
                                                subtitle: collab['beat_name']
                                                        ?.toString() ??
                                                    'Today’s collaboration',
                                                icon: Icons.groups_outlined,
                                                trailing: collab[
                                                        'collaboration_status']
                                                    ?.toString()),
                                            Home20ListRow(
                                                title:
                                                    '${integer(collab['total_collaborators'])} collaborators',
                                                subtitle:
                                                    'Handshake: ${collab['handshake_status'] ?? 'None'}',
                                                icon: Icons.handshake_outlined),
                                          ])),
                            _quickActions(),
                          ]),
                      const SizedBox(height: 8),
                      Home20Grid(columns: tablet ? 2 : 1, children: [
                        const Home20BannerSlider(),
                        Home20Card(
                            title: "Today's summary",
                            icon: Icons.bar_chart_rounded,
                            sample: visitSample,
                            child: Home20Grid(columns: 2, gap: 12, children: [
                              _summaryTile(
                                  'Doctor visits',
                                  visitSample
                                      ? '6 / 10'
                                      : '${integer(doctor['confirmed'])} / ${integer(doctor['total'])}',
                                  Icons.person_outline,
                                  TColors.info),
                              _summaryTile(
                                  'Chemist visits',
                                  visitSample
                                      ? '3 / 5'
                                      : '${integer(chemist['confirmed'])} / ${integer(chemist['total'])}',
                                  Icons.storefront_outlined,
                                  TColors.success),
                              _summaryTile(
                                  'Stockist visits',
                                  visitSample
                                      ? '1 / 2'
                                      : '${integer(stockist['confirmed'])} / ${integer(stockist['total'])}',
                                  Icons.inventory_2_outlined,
                                  TColors.primary),
                              _summaryTile(
                                  'Approved visits',
                                  visitSample
                                      ? '9'
                                      : '${integer(visits['approved'])}',
                                  Icons.verified_outlined,
                                  TColors.secondary),
                            ])),
                      ]),
                      const SizedBox(height: 8),
                      Home20Grid(
                          columns: wide
                              ? 3
                              : tablet
                                  ? 2
                                  : 1,
                          children: [
                            _demoList('Recent doctor visits',
                                Icons.person_outline, const [
                              (
                                'Dr. S. Kumar',
                                'Child specialist · Samastipur',
                                'Done'
                              ),
                              ('Dr. Neha Singh', 'General physician', 'Done'),
                              ('Dr. R. Tripathi', 'ENT specialist', 'Pending'),
                            ]),
                            _demoList('Recent chemist visits',
                                Icons.storefront_outlined, const [
                              ('City Care Pharma', 'Samastipur City', 'Done'),
                              ('Life Care Stores', 'Samastipur', 'Done'),
                              (
                                'New Bharat Medical',
                                'Samastipur Rural',
                                'Pending'
                              ),
                            ]),
                            Home20Card(
                                title: 'Expense claims',
                                icon: Icons.receipt_long_outlined,
                                sample: expenseSample,
                                action: 'View all',
                                onAction: () => _open(const Expense20Screen()),
                                child: Column(children: [
                                  Home20ListRow(
                                      title: 'Pending',
                                      subtitle:
                                          '${expenseSample ? 2 : integer(expenses['pending'])} claims',
                                      trailing: _money(expenseSample
                                          ? 770
                                          : expenses['pendingAmount']),
                                      icon: Icons.hourglass_empty),
                                  Home20ListRow(
                                      title: 'Approved',
                                      subtitle:
                                          '${expenseSample ? 2 : integer(expenses['approved'])} claims',
                                      trailing: _money(expenseSample
                                          ? 1100
                                          : expenses['approvedAmount']),
                                      icon: Icons.check_circle_outline),
                                  Home20ListRow(
                                      title: 'Rejected',
                                      subtitle:
                                          '${expenseSample ? 0 : integer(expenses['rejected'])} claims',
                                      trailing: _money(expenseSample
                                          ? 0
                                          : expenses['rejectedAmount']),
                                      icon: Icons.cancel_outlined),
                                ])),
                          ]),
                      const SizedBox(height: 8),
                      Home20Grid(columns: tablet ? 2 : 1, children: [
                        _products(compact: false),
                        Home20Card(
                            title: 'My territory',
                            icon: Icons.map_outlined,
                            sample: true,
                            action: 'Open live map',
                            onAction: () =>
                                _open(const MapBeatManagementScreen()),
                            child: const Home20TerritoryPreview()),
                      ]),
                    ]));
          }),
        ));
  }

  Widget _smallValue(String label, String value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
                fontSize: 16)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: TColors.textSecondary, fontSize: 12)),
      ]);

  Widget _summaryTile(String title, String value, IconData icon, Color color) =>
      Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: TColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: TColors.textPrimary))
          ]));

  Widget _quickActions() => Home20Card(
      title: 'Quick actions',
      icon: Icons.bolt_outlined,
      child: Home20Grid(columns: 3, gap: 8, children: [
        _action('Visits', Icons.medical_services_outlined, TColors.info,
            () => _open(ScheduleVisit())),
        _action('Territory', Icons.map_outlined, TColors.success,
            () => _open(const MapBeatManagementScreen())),
        _action('Expenses', Icons.receipt_long_outlined, TColors.primary,
            () => _open(const Expense20Screen())),
        _action('Products', Icons.inventory_2_outlined, TColors.secondary,
            () => _open(const AddproductScreen())),
        _action('Reports', Icons.bar_chart_rounded, TColors.warning,
            () => _open(const ReportScreen())),
        _action('Resources', Icons.menu_book_outlined, TColors.info,
            () => _open(const MarketingmaterialsScreen())),
      ]));

  Widget _action(
          String title, IconData icon, Color color, VoidCallback onTap) =>
      Material(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                  child: Column(children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 8),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 11, color: TColors.textPrimary))
                  ]))));

  Widget _products({required bool compact}) {
    const products = [
      ('Gluxotuss Syp', 'Core product', 42.0),
      ('Gluxofer XT Plus', 'Focus product', 35.0),
      ('Aziglux Syp', 'New launch', 30.0),
      ('Cefglux Dry Syrup', 'Secondary', 55.0)
    ];
    return Home20Card(
        title: compact ? 'Top products' : 'Product focus',
        icon: Icons.inventory_2_outlined,
        sample: true,
        action: 'Catalog',
        onAction: () => _open(const AddproductScreen()),
        child: Column(children: [
          if (!compact)
            Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(right: i == 2 ? 0 : 6),
                            child: ChoiceChip(
                                showCheckmark: false,
                                padding: EdgeInsets.zero,
                                label: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                        [
                                          'Primary',
                                          'Secondary',
                                          'New launch'
                                        ][i],
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 11),
                                        overflow: TextOverflow.ellipsis)),
                                selected: _productTab == i,
                                onSelected: (_) =>
                                    setState(() => _productTab = i)))),
                ])),
          for (final product in (compact || _productTab == 0
              ? products.take(compact ? 2 : 4)
              : _productTab == 1
                  ? products.skip(3)
                  : products.skip(2).take(1)))
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Container(
                      width: compact ? 58 : 76,
                      height: compact ? 68 : 102,
                      decoration: BoxDecoration(
                          color: TColors.cardPinkLight,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Image.asset('assets/images/home20_product.png',
                              fit: BoxFit.contain,
                              semanticLabel: 'Sample pharmaceutical product',
                              errorBuilder: (_, error, stack) => const Icon(
                                  Icons.medication_liquid,
                                  color: TColors.primary,
                                  size: 34)))),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(product.$1,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: TColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(product.$2,
                            style: const TextStyle(
                                fontSize: 12, color: TColors.textSecondary)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                            value: product.$3 / 100,
                            minHeight: 6,
                            color: TColors.primary,
                            backgroundColor: TColors.borderSecondary),
                      ])),
                  const SizedBox(width: 12),
                  Text('${product.$3.toInt()}%',
                      style: const TextStyle(
                          color: TColors.success, fontWeight: FontWeight.bold)),
                ])),
        ]));
  }
}

Map<String, dynamic> object(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};
double number(dynamic value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;
int integer(dynamic value) => number(value).toInt();
