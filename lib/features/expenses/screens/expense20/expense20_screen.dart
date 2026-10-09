import '../../../../utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../../controllers/ExpanseDefaultValueController.dart';
import '../../controllers/expenseController.dart';
import '../../models/NewExpenseModel.dart';
import 'expense20_claim_form.dart';
import 'expense20_policy.dart';
import 'expense20_pdf.dart';
import 'expense20_widgets.dart';
import 'expense20_working_location.dart';

class Expense20Screen extends StatefulWidget {
  const Expense20Screen({super.key});
  static const menuTitle = 'Expense 2.0';

  @override
  State<Expense20Screen> createState() => _Expense20ScreenState();
}

enum _Expense20Export {
  downloadAll,
  shareAll,
  downloadSelection,
  shareSelection
}

class _Expense20ScreenState extends State<Expense20Screen> {
  final _expenses = ExpenseController();
  final _settings = ScraperSettingsController();
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final _historyScroll = ScrollController();
  final _historyHorizontalScroll = ScrollController();
  final _claimKey = GlobalKey(debugLabel: 'expense20-claim-form');
  List<ExpenseModel> _data = [];
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _historyMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  String _type = 'all';
  String _status = 'all';
  String? _error;
  bool _loading = true;
  bool _submitting = false;
  bool _fetching = false;
  bool _exporting = false;
  String? _workingLocation;
  bool _addingExpense = false;
  bool _summaryVisible = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _chooseWorkingLocation() async {
    if (_addingExpense) return;
    setState(() => _addingExpense = true);
    try {
      final location = await chooseExpense20WorkingLocation(context,
          initial: _workingLocation);
      if (location == null || !mounted) return;
      _workingLocation = location;
      var selectedLocation = location;
      var busy = false;
      final saved = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => StatefulBuilder(
              builder: (context, updateDialog) => PopScope(
                  canPop: !busy,
                  child: Dialog(
                      backgroundColor: TColors.light,
                      insetPadding: const EdgeInsets.all(TSizes.md),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(TSizes.cardRadiusLg)),
                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: TSizes.v650,
                              maxHeight: MediaQuery.sizeOf(context).height *
                                  TSizes.expenseDialogHeightFraction),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                    key: const ValueKey('expense20-close-add'),
                                    tooltip: 'Close expense',
                                    onPressed: busy
                                        ? null
                                        : () =>
                                            Navigator.pop(dialogContext, false),
                                    icon: const Icon(Icons.close,
                                        color: TColors.textPrimary))),
                            Flexible(
                                child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(TSizes.md),
                                    child: Expense20ClaimForm(
                                        key: _claimKey,
                                        workingLocation: selectedLocation,
                                        settings:
                                            _settings.scraperSettings.value,
                                        onChangeWorkingLocation: busy
                                            ? null
                                            : () async {
                                                final changed =
                                                    await chooseExpense20WorkingLocation(
                                                        context,
                                                        initial:
                                                            selectedLocation);
                                                if (changed != null &&
                                                    context.mounted) {
                                                  _workingLocation = changed;
                                                  updateDialog(() =>
                                                      selectedLocation =
                                                          changed);
                                                }
                                              },
                                        onSaved: () =>
                                            Navigator.pop(dialogContext, true),
                                        onBusyChanged: (value) {
                                          if (context.mounted) {
                                            updateDialog(() => busy = value);
                                          }
                                          if (mounted) {
                                            setState(() => _submitting = value);
                                          }
                                        }))),
                          ]))))));
      if (saved == true && mounted) {
        await _load();
      }
    } finally {
      if (mounted) {
        setState(() {
          _addingExpense = false;
          _submitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    _historyScroll.dispose();
    _historyHorizontalScroll.dispose();
    _expenses.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_submitting || _fetching) return;
    _fetching = true;
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final settingsLoad = _settings.fetchSettings();
    List<ExpenseModel>? data;
    String? error;
    try {
      final id = await AuthManager().getUserId();
      if (id == null || id.isEmpty) throw StateError('Missing user');
      data = await _expenses.fetchExpenses();
      data.sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      error =
          'Unable to load expenses. Please check your connection and retry.';
    }
    await settingsLoad;
    _fetching = false;
    if (!mounted) return;
    setState(() {
      if (data != null) _data = data;
      _error = error;
      _loading = false;
    });
    _resetHistoryScroll();
  }

  List<ExpenseModel> _expensesForMonth(DateTime month) =>
      _data.where((expense) {
        final date = DateTime.tryParse(expense.date);
        return date != null &&
            date.year == month.year &&
            date.month == month.month;
      }).toList();

  List<ExpenseModel> get _monthExpenses => _expensesForMonth(_month);

  List<ExpenseModel> get _filtered =>
      (_historyMonth == null ? _data : _expensesForMonth(_historyMonth!))
          .where((expense) {
        final query = _search.text.trim().toLowerCase();
        return (_type == 'all' || expense.category == _type) &&
            (_status == 'all' || expense.status.toLowerCase() == _status) &&
            (query.isEmpty ||
                '${expense.description} ${_details(expense)} '
                        '${expense20Type(expense.category)} ${expense.amount}'
                    .toLowerCase()
                    .contains(query));
      }).toList();

  List<DateTime> get _months {
    final now = DateTime.now();
    final months = <DateTime>{
      _month,
      if (_historyMonth != null) _historyMonth!,
      for (var i = 0; i < 12; i++) DateTime(now.year, now.month - i)
    };
    for (final expense in _data) {
      final date = DateTime.tryParse(expense.date);
      if (date != null) months.add(DateTime(date.year, date.month));
    }
    return months.toList()..sort((a, b) => b.compareTo(a));
  }

  void _setMonth(DateTime? month) {
    if (month != null) {
      setState(() {
        _month = month;
      });
    }
  }

  Widget _monthPicker() => SizedBox(
      width: TSizes.v205,
      child: DropdownButtonFormField<DateTime>(
        key: ValueKey('expense20-month-${_month.toIso8601String()}'),
        value: _month,
        isExpanded: true,
        decoration: expense20Input('',
                prefix: const Icon(Icons.calendar_month_outlined,
                    size: TSizes.v19, color: TColors.primary))
            .copyWith(labelText: 'Summary month'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: TColors.primary,
            fontSize: TSizes.v12,
            fontWeight: FontWeight.w600),
        dropdownColor: TColors.white,
        items: _months
            .map((month) => DropdownMenuItem(
                value: month,
                child: Text(DateFormat('MMMM yyyy').format(month))))
            .toList(),
        onChanged: _setMonth,
      ));

  bool _onExpenseScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      final delta = notification.scrollDelta ?? 0;
      if (delta.abs() > TSizes.v1) {
        final visible = delta < 0;
        if (visible != _summaryVisible) {
          setState(() => _summaryVisible = visible);
        }
      }
    } else if (notification is OverscrollNotification &&
        notification.dragDetails != null &&
        notification.overscroll.abs() > TSizes.v1) {
      final visible = notification.overscroll < 0;
      if (visible != _summaryVisible) {
        setState(() => _summaryVisible = visible);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: TColors.light,
        floatingActionButton: FloatingActionButton.extended(
            key: const ValueKey('expense20-add-expense'),
            backgroundColor: TColors.primary,
            foregroundColor: TColors.white,
            onPressed:
                _addingExpense || _submitting ? null : _chooseWorkingLocation,
            icon: const Icon(Icons.add, size: TSizes.iconSm),
            label: const Text('Add Expense')),
        body: NotificationListener<ScrollNotification>(
            onNotification: _onExpenseScroll,
            child: LayoutBuilder(
                builder: (context, constraints) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRect(
                              child: AnimatedSize(
                                  duration:
                                      MediaQuery.disableAnimationsOf(context)
                                          ? Duration.zero
                                          : const Duration(
                                              milliseconds: TSizes
                                                  .expenseDialogAnimationMs),
                                  curve: Curves.easeInOutCubic,
                                  alignment: Alignment.topCenter,
                                  child: SizedBox(
                                      key: const ValueKey(
                                          'expense20-summary-reveal'),
                                      height: _summaryVisible ? null : 0,
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.all(TSizes.sm),
                                          child: _summary(constraints.maxWidth -
                                              TSizes.md))))),
                          _historyToolbar(),
                          Expanded(
                              child: RefreshIndicator(
                                  onRefresh: _load,
                                  color: TColors.primary,
                                  backgroundColor: TColors.white,
                                  child: SingleChildScrollView(
                                      controller: _scroll,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                          TSizes.sm, 0, TSizes.sm, TSizes.v80),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            if (_loading)
                                              const LinearProgressIndicator(
                                                  color: TColors.primary,
                                                  backgroundColor:
                                                      TColors.borderSecondary),
                                            if (_error != null)
                                              _errorBanner(_error!),
                                            if (!_loading &&
                                                _settings.scraperSettings
                                                        .value ==
                                                    null)
                                              _errorBanner(
                                                  'Allowance rates could not be loaded. Refresh to retry. TA and DA require the current rates.'),
                                            _history(),
                                          ])))),
                        ]))),
      );

  Widget _historyToolbar() => Container(
      color: TColors.light,
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md, vertical: TSizes.xs),
      child: Column(children: [
        Row(children: [
          const Expanded(
              child: Text('My Expense History',
                  style: TextStyle(
                      color: TColors.textPrimary,
                      fontSize: TSizes.fontSizeMd,
                      fontWeight: FontWeight.w700))),
          const SizedBox(width: TSizes.sm),
         // _monthPicker(),
          IconButton(
              tooltip: 'Expense Policy',
              onPressed: () =>
                  showExpense20Policy(context, _settings.scraperSettings.value),
              icon: const Icon(Icons.policy_outlined,
                  size: TSizes.iconSm, color: TColors.primary)),
         // const Spacer(),

          _exportMenu(history: true),
        ]),

      ]));

  Widget _exportMenu({required bool history}) =>
      Builder(builder: (buttonContext) {
        final enabled = !_loading &&
            !_submitting &&
            !_exporting &&
            _error == null &&
            _data.isNotEmpty;
        final selection = history ? _filtered : _monthExpenses;
        return PopupMenuButton<_Expense20Export>(
          key: ValueKey('expense20-export-${history ? 'history' : 'claim'}'),
          enabled: enabled,
          tooltip: 'Download or share expenses as PDF',
          color: TColors.white,
          onSelected: (action) {
            final box = buttonContext.findRenderObject() as RenderBox?;
            final bounds =
                box == null ? null : box.localToGlobal(Offset.zero) & box.size;
            _exportPdf(action, history: history, shareBounds: bounds);
          },
          itemBuilder: (_) => [
            _exportItem(
                _Expense20Export.downloadAll,
                Icons.download_outlined,
                'Download PDF - all expenses',
                '${_data.length} saved expenses, every month'),
            _exportItem(
                _Expense20Export.shareAll,
                Icons.share_outlined,
                'Share PDF - all expenses',
                '${_data.length} saved expenses, every month'),
            const PopupMenuDivider(),
            _exportItem(
                _Expense20Export.downloadSelection,
                Icons.download_outlined,
                'Download PDF - current selection',
                '${selection.length} matching expenses',
                enabled: selection.isNotEmpty),
            _exportItem(
                _Expense20Export.shareSelection,
                Icons.share_outlined,
                'Share PDF - current selection',
                '${selection.length} matching expenses',
                enabled: selection.isNotEmpty),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: TSizes.v14, vertical: TSizes.v10),
            decoration: BoxDecoration(
              color: TColors.primaryBackground,
              borderRadius: BorderRadius.circular(TSizes.v8),
              border: Border.all(color: TColors.borderSecondary),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                  _exporting
                      ? Icons.hourglass_top
                      : Icons.picture_as_pdf_outlined,
                  size: TSizes.v18,
                  color: enabled ? TColors.primary : TColors.textSecondary),
              const SizedBox(width: TSizes.v8),
              Text(_exporting ? 'Preparing PDF…' : 'Export PDF',
                  style: TextStyle(
                      color: enabled ? TColors.primary : TColors.textSecondary,
                      fontSize: TSizes.v12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: TSizes.v6),
              const Icon(Icons.keyboard_arrow_down,
                  size: TSizes.v18, color: TColors.primary),
            ]),
          ),
        );
      });

  PopupMenuItem<_Expense20Export> _exportItem(
          _Expense20Export value, IconData icon, String title, String subtitle,
          {bool enabled = true}) =>
      PopupMenuItem(
        value: value,
        enabled: enabled,
        height: TSizes.v64,
        child: Row(children: [
          Icon(icon,
              size: TSizes.v20,
              color: enabled ? TColors.primary : TColors.textSecondary),
          const SizedBox(width: TSizes.v10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        fontSize: TSizes.v12,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? TColors.textPrimary
                            : TColors.textSecondary)),
                const SizedBox(height: TSizes.v3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: TSizes.v10, color: TColors.textSecondary)),
              ])),
        ]),
      );

  Future<void> _exportPdf(_Expense20Export action,
      {required bool history, Rect? shareBounds}) async {
    if (_exporting || _loading || _submitting || _error != null) return;
    final all = action == _Expense20Export.downloadAll ||
        action == _Expense20Export.shareAll;
    final share = action == _Expense20Export.shareAll ||
        action == _Expense20Export.shareSelection;
    final records = List<ExpenseModel>.of(all
        ? _data
        : history
            ? _filtered
            : _monthExpenses);
    if (records.isEmpty) return;
    final scope = all
        ? 'All saved expenses - every month'
        : [
            history && _historyMonth == null
                ? 'All months'
                : DateFormat('MMMM yyyy')
                    .format(history ? _historyMonth! : _month),
            if (history && _type != 'all') 'Type: ${expense20Type(_type)}',
            if (history && _status != 'all') 'Status: $_status',
            if (history && _search.text.trim().isNotEmpty)
              'Search: ${_search.text.trim()}',
          ].join(' | ');
    final now = DateTime.now();
    final filename =
        'expenses_${all ? 'all' : history && _historyMonth == null ? 'filtered_all_months' : DateFormat('yyyy-MM').format(history ? _historyMonth! : _month)}_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';
    setState(() => _exporting = true);
    try {
      final user = await AuthManager().getUserData();
      final name = user?.user?.name ?? records.first.userName;
      final bytes = await Expense20Pdf.build(
          expenses: records,
          scope: scope,
          userName: name.trim().isEmpty ? 'My expenses' : name,
          generatedAt: now);
      if (!mounted) return;
      if (share) {
        await Printing.sharePdf(
            bytes: bytes,
            filename: filename,
            bounds: shareBounds,
            subject: 'Expense statement - $scope');
      } else {
        final path = await FilePicker.platform.saveFile(
            dialogTitle: 'Save expense PDF',
            fileName: filename,
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            bytes: bytes);
        if (path != null && mounted) {
          expense20Message(context, 'Expense PDF saved successfully.');
        }
      }
    } catch (error) {
      debugPrint('[Expense20Pdf] Export failed: $error');
      if (mounted) {
        expense20Message(context,
            'Unable to ${share ? 'share' : 'save'} the expense PDF. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Widget _summary(double width) {
    final columns = width >= TSizes.v850
        ? 4
        : width >= TSizes.v320
            ? 2
            : 1;
    final cardWidth = (width - (columns - 1) * TSizes.v12) / columns;
    final monthData = _monthExpenses;
    return Wrap(spacing: TSizes.v12, runSpacing: TSizes.v12, children: [
      for (final status in ['approved', 'pending', 'rejected', 'total'])
        SizedBox(
            width: cardWidth,
            child: _summaryCard(
                status,
                status == 'total'
                    ? monthData
                    : monthData
                        .where(
                            (expense) => expense.status.toLowerCase() == status)
                        .toList())),
    ]);
  }

  Widget _summaryCard(String status, List<ExpenseModel> expenses) {
    final total = expenses.fold(0.0, (sum, expense) => sum + _amount(expense));
    final color =
        status == 'total' ? TColors.primary : expense20StatusColor(status);
    final background = status == 'total'
        ? TColors.primaryBackground
        : expense20StatusBackground(status);
    final title = status == 'total'
        ? 'Total Claimed'
        : '${status[0].toUpperCase()}${status.substring(1)}';
    final icon = switch (status) {
      'approved' => Icons.task_alt,
      'pending' => Icons.hourglass_empty,
      'rejected' => Icons.cancel_outlined,
      _ => Icons.bar_chart,
    };
    return Container(
        padding: const EdgeInsets.all(TSizes.sm),
        decoration: BoxDecoration(
            color: background.withValues(alpha: TColors.expenseSummaryOpacity),
            borderRadius: BorderRadius.circular(TSizes.v12),
            border: Border.all(color: TColors.borderSecondary)),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(TSizes.xs),
              decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(TSizes.v10)),
              child: Icon(icon, color: color, size: TSizes.iconSm)),
          const SizedBox(width: TSizes.v12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(_loading && _data.isEmpty ? '—' : expense20Money(total),
                    key: ValueKey('expense20-summary-$status'),
                    style: TextStyle(
                        color: color,
                        fontSize: TSizes.v19,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: TSizes.v3),
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: TSizes.v13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: TSizes.v4),
                Text(
                    _loading && _data.isEmpty
                        ? 'Loading claims…'
                        : '${DateFormat('MMM').format(_month)} · ${expenses.length} ${expenses.length == 1 ? 'claim' : 'claims'}',
                    style: const TextStyle(
                        color: TColors.textSecondary, fontSize: TSizes.v11)),
              ])),
        ]));
  }

  Widget _errorBanner(String message) => Container(
      margin: const EdgeInsets.only(bottom: TSizes.v16),
      padding: const EdgeInsets.all(TSizes.v12),
      decoration: BoxDecoration(
          color: TColors.errorBg,
          borderRadius: BorderRadius.circular(TSizes.v8)),
      child: Row(children: [
        const Icon(Icons.info_outline, color: TColors.error, size: TSizes.v20),
        const SizedBox(width: TSizes.v10),
        Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: TColors.error, fontSize: TSizes.v12))),
        TextButton(
            onPressed: _loading ? null : _load,
            child: const Text('Retry', style: TextStyle(color: TColors.error)))
      ]));

  Widget _history() {
    final filtered = _filtered;
    return Expense20Panel(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      LayoutBuilder(builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth >= TSizes.v620
            ? (constraints.maxWidth - TSizes.v36) / 4
            : constraints.maxWidth >= TSizes.v380
                ? (constraints.maxWidth - TSizes.v12) / 2
                : constraints.maxWidth;
        return Wrap(spacing: TSizes.v12, runSpacing: TSizes.v12, children: [
          SizedBox(
              width: fieldWidth,
              child: _filter(
                  'expense20-history-month',
                  _historyMonth == null
                      ? 'all'
                      : DateFormat('yyyy-MM').format(_historyMonth!),
                  {
                    'all': 'All months',
                    for (final month in _months)
                      DateFormat('yyyy-MM').format(month):
                          DateFormat('MMM yyyy').format(month),
                  }, (value) {
                setState(() => _historyMonth =
                    value == 'all' ? null : DateTime.parse('$value-01'));
                _resetHistoryScroll();
              })),
          SizedBox(
              width: fieldWidth,
              child: _filter('expense20-type-filter', _type, {
                'all': 'All Types',
                'travel': 'TA',
                'daily': 'DA',
                'extra': 'Other Expense'
              }, (value) {
                setState(() => _type = value);
                _resetHistoryScroll();
              })),
          SizedBox(
              width: fieldWidth,
              child: _filter('expense20-status-filter', _status, {
                'all': 'All Status',
                'approved': 'Approved',
                'pending': 'Pending',
                'rejected': 'Rejected'
              }, (value) {
                setState(() => _status = value);
                _resetHistoryScroll();
              })),
          SizedBox(
              width: fieldWidth,
              child: TextField(
                  controller: _search,
                  key: const ValueKey('expense20-search'),
                  style: const TextStyle(
                      color: TColors.textPrimary, fontSize: TSizes.v12),
                  decoration: expense20Input('Search…',
                      prefix: const Icon(Icons.search,
                          size: TSizes.v18, color: TColors.textSecondary)),
                  onChanged: (_) {
                    setState(() {});
                    _resetHistoryScroll();
                  })),
        ]);
      }),
      const SizedBox(height: TSizes.v18),
      if (filtered.isEmpty)
        Container(
            padding: const EdgeInsets.symmetric(
                vertical: TSizes.v50, horizontal: TSizes.v12),
            child: Column(children: [
              const Icon(Icons.receipt_long_outlined,
                  color: TColors.darkGrey, size: TSizes.v38),
              const SizedBox(height: TSizes.v12),
              Text(
                  _loading
                      ? 'Loading expense history…'
                      : _error != null
                          ? 'Expense history is unavailable. Please retry.'
                          : 'No expenses match this selection.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: TColors.textSecondary, fontSize: TSizes.v13)),
            ]))
      else
        _historyList(filtered),
      const SizedBox(height: TSizes.v16),
      Text(
          filtered.isEmpty
              ? '0 expenses'
              : 'Showing all ${filtered.length} ${filtered.length == 1 ? 'expense' : 'expenses'}',
          style: const TextStyle(
              color: TColors.textSecondary, fontSize: TSizes.v11)),
    ]));
  }

  void _resetHistoryScroll() {
    if (_historyScroll.hasClients) _historyScroll.jumpTo(0);
  }

  Widget _historyList(List<ExpenseModel> rows) =>
      LayoutBuilder(builder: (context, constraints) {
        final height = (rows.length * 80.0 + 48).clamp(
            128.0,
            (MediaQuery.sizeOf(context).height *
                    TSizes.expenseHistoryHeightFraction)
                .clamp(TSizes.v280, TSizes.v640));
        return SizedBox(
            key: const ValueKey('expense20-history-viewport'),
            height: height,
            child: Scrollbar(
                controller: _historyScroll,
                thumbVisibility: true,
                notificationPredicate: (notification) =>
                    notification.metrics.axis == Axis.vertical,
                child: Scrollbar(
                    controller: _historyHorizontalScroll,
                    thumbVisibility: constraints.maxWidth < TSizes.v650,
                    notificationPredicate: (notification) =>
                        notification.metrics.axis == Axis.horizontal,
                    child: SingleChildScrollView(
                        controller: _historyHorizontalScroll,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                            width: constraints.maxWidth < TSizes.v650
                                ? 650
                                : constraints.maxWidth,
                            child: Column(children: [
                              _historyTable([
                                TableRow(
                                    decoration: const BoxDecoration(
                                        color: TColors.light),
                                    children: [
                                      'Date',
                                      'Type',
                                      'Details',
                                      'Amount (₹)',
                                      'Status',
                                      'Bill',
                                      'Action'
                                    ]
                                        .map((text) =>
                                            _tableText(text, bold: true))
                                        .toList())
                              ]),
                              Expanded(
                                  child: NotificationListener<
                                          OverscrollNotification>(
                                      onNotification: (notification) {
                                        if (notification.metrics.axis ==
                                                Axis.vertical &&
                                            notification.overscroll < 0 &&
                                            _scroll.hasClients) {
                                          _scroll.jumpTo((_scroll.offset +
                                                  notification.overscroll)
                                              .clamp(
                                                  _scroll
                                                      .position.minScrollExtent,
                                                  _scroll.position
                                                      .maxScrollExtent));
                                        }
                                        return false;
                                      },
                                      child: ListView.separated(
                                          physics:
                                              const ClampingScrollPhysics(),
                                          key: const ValueKey(
                                              'expense20-history-list'),
                                          controller: _historyScroll,
                                          primary: false,
                                          itemCount: rows.length,
                                          separatorBuilder: (_, __) =>
                                              const Divider(
                                                  height: TSizes.v1,
                                                  thickness: 1,
                                                  color:
                                                      TColors.borderSecondary),
                                          itemBuilder: (_, index) => KeyedSubtree(
                                              key: ValueKey(
                                                  'expense20-history-row-${rows[index].id}'),
                                              child: _historyTable([
                                                _historyExpenseRow(rows[index])
                                              ]))))),
                            ]))))));
      });

  Widget _historyTable(List<TableRow> rows) => Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FixedColumnWidth(90),
        1: FixedColumnWidth(72),
        2: FlexColumnWidth(),
        3: FixedColumnWidth(95),
        4: FixedColumnWidth(100),
        5: FixedColumnWidth(45),
        6: FixedColumnWidth(60),
      },
      children: rows);

  TableRow _historyExpenseRow(ExpenseModel expense) => TableRow(children: [
        _tableText(_formatDate(expense.date)),
        Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: TSizes.v8, vertical: TSizes.v14),
            child: Row(children: [
              Icon(expense20Icon(expense.category),
                  size: TSizes.v18,
                  color: expense20TypeColor(expense.category)),
              const SizedBox(width: TSizes.v6),
              Expanded(
                  child: Text(expense20Type(expense.category),
                      style: TextStyle(
                          color: expense20TypeColor(expense.category),
                          fontSize: TSizes.v11))),
            ])),
        Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: TSizes.v8, vertical: TSizes.v14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_details(expense),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: TColors.textPrimary, fontSize: TSizes.v12)),
              const SizedBox(height: TSizes.v3),
              Text(_subDetails(expense),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: TColors.textSecondary, fontSize: TSizes.v10)),
            ])),
        _tableText(expense20Money(_amount(expense))),
        Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: TSizes.v5, vertical: TSizes.v8),
            child: Expense20Status(expense.status)),
        expense.bill.trim().isEmpty
            ? _tableText('—')
            : IconButton(
                tooltip: 'View bill',
                onPressed: () => _viewBill(expense.bill),
                icon: const Icon(Icons.receipt_outlined,
                    color: TColors.primary, size: TSizes.v19)),
        TextButton(
            onPressed: () => _viewExpense(expense),
            style: TextButton.styleFrom(foregroundColor: TColors.primary),
            child: const Text('View', style: TextStyle(fontSize: TSizes.v11))),
      ]);

  Widget _filter(String key, String value, Map<String, String> values,
          ValueChanged<String> onChanged) =>
      DropdownButtonFormField<String>(
          key: ValueKey('$key-$value'),
          value: value,
          isExpanded: true,
          decoration: expense20Input(''),
          dropdownColor: TColors.white,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: TColors.textPrimary, fontSize: TSizes.v12),
          items: values.entries
              .map((entry) =>
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)))
              .toList(),
          onChanged: (next) {
            if (next != null) onChanged(next);
          });

  Widget _tableText(String text, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.v8, vertical: TSizes.v14),
      child: Text(text,
          style: TextStyle(
              color: TColors.textPrimary,
              fontSize: TSizes.v11,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400)));

  double _amount(ExpenseModel expense) => double.tryParse(expense.amount) ?? 0;
  String _formatDate(String text) {
    final date = DateTime.tryParse(text);
    return date == null ? text : DateFormat('dd MMM yyyy').format(date);
  }

  String _details(ExpenseModel expense) {
    if (expense.category == 'travel') {
      return expense.travelDetails.isEmpty
          ? 'Travel Allowance'
          : expense.travelDetails
              .map((leg) => '${leg.from} → ${leg.to}')
              .join(' · ');
    }
    if (expense.category == 'daily') {
      return switch (expense.dailyAllowanceType) {
        'headoffice' => 'Headquarter DA',
        'ex-headquarters' => 'X Station DA',
        'outside' => 'Out of Station DA',
        _ => 'Daily Allowance',
      };
    }
    return expense.description.isEmpty
        ? 'Other Expense'
        : expense.description.split('\n').first;
  }

  String _subDetails(ExpenseModel expense) => expense.category == 'travel'
      ? '${expense.travelDetails.fold(0.0, (sum, leg) => sum + leg.km).toStringAsFixed(1)} km · '
          '${expense.travelDetails.length} ${expense.travelDetails.length == 1 ? 'leg' : 'legs'}'
      : expense.paymentStatus?.isNotEmpty == true
          ? 'Payment: ${expense.paymentStatus}'
          : 'Submitted expense';

  Future<void> _viewBill(String bill) async {
    final parsed = Uri.tryParse(bill);
    final url = parsed?.hasScheme == true
        ? bill
        : Uri.parse(
                '${THttpHelper.baseUrl.replaceFirst(RegExp(r'/api/?$'), '')}/')
            .resolve(bill)
            .toString();
    await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
            backgroundColor: TColors.white,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: TSizes.v760,
                    maxHeight: MediaQuery.sizeOf(context).height *
                        TSizes.expenseDetailsHeightFraction),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Close bill',
                          icon:
                              const Icon(Icons.close, color: TColors.primary))),
                  Flexible(
                      child: InteractiveViewer(
                          child: Image.network(url,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                      ? child
                                      : const Padding(
                                          padding: EdgeInsets.all(TSizes.v40),
                                          child: CircularProgressIndicator(
                                              color: TColors.primary)),
                              errorBuilder: (_, error, stack) => const Padding(
                                  padding: EdgeInsets.all(TSizes.v30),
                                  child: Text(
                                      'Unable to display this bill. Please retry.',
                                      style:
                                          TextStyle(color: TColors.error)))))),
                ]))));
  }

  Future<void> _viewExpense(ExpenseModel expense) => showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
          backgroundColor: TColors.white,
          surfaceTintColor: TColors.transparent,
          insetPadding: const EdgeInsets.symmetric(
              horizontal: TSizes.v16, vertical: TSizes.v24),
          child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: TSizes.v650,
                  maxHeight: MediaQuery.sizeOf(context).height *
                      TSizes.expensePolicyHeightFraction),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                    padding: const EdgeInsets.all(TSizes.v20),
                    child: Expense20Heading(
                        title: '${expense20Type(expense.category)} Expense',
                        subtitle: _formatDate(expense.date),
                        icon: expense20Icon(expense.category),
                        action: Expense20Status(expense.status))),
                const Divider(
                    height: TSizes.v1, color: TColors.borderSecondary),
                Flexible(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(TSizes.v20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _detail('Claim amount',
                                  expense20Money(_amount(expense))),
                              _detail('Details', _details(expense)),
                              if (expense.category == 'travel') ...[
                                _detail(
                                    'Actual distance', _subDetails(expense)),
                                for (final leg in expense.travelDetails)
                                  _detail('${leg.from} → ${leg.to}',
                                      '${leg.km} km'),
                                if (expense.ratePerKm.isNotEmpty)
                                  _detail('Rate per KM', expense.ratePerKm),
                              ],
                              if (expense.endDate?.isNotEmpty == true)
                                _detail(
                                    'End date', _formatDate(expense.endDate!)),
                              _detail(
                                  'Purpose / Remarks',
                                  expense.description.isEmpty
                                      ? '—'
                                      : expense.description),
                              _detail(
                                  'Payment status',
                                  expense.paymentStatus?.isNotEmpty == true
                                      ? expense.paymentStatus!
                                      : 'Not recorded'),
                              if (expense.paymentDate?.isNotEmpty == true)
                                _detail('Payment date',
                                    _formatDate(expense.paymentDate!)),
                              if (expense.paymentMonthYear?.isNotEmpty == true)
                                _detail('Payment period',
                                    expense.paymentMonthYear!),
                              if (expense.transactionId?.isNotEmpty == true)
                                _detail(
                                    'Transaction ID', expense.transactionId!),
                              if (expense.paymentNote?.isNotEmpty == true)
                                _detail('Payment note', expense.paymentNote!),
                              if (expense.bill.isNotEmpty)
                                OutlinedButton.icon(
                                    onPressed: () => _viewBill(expense.bill),
                                    icon: const Icon(Icons.receipt_outlined,
                                        color: TColors.primary),
                                    label: const Text('View Bill',
                                        style:
                                            TextStyle(color: TColors.primary))),
                            ]))),
                Padding(
                    padding: const EdgeInsets.all(TSizes.v16),
                    child: OverflowBar(
                        spacing: TSizes.v12,
                        alignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Close',
                                  style:
                                      TextStyle(color: TColors.textSecondary))),
                          if (['travel', 'daily'].contains(expense.category) &&
                              expense.editCount < 1)
                            FilledButton.icon(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  _edit(expense);
                                },
                                style: FilledButton.styleFrom(
                                    backgroundColor: TColors.primary,
                                    foregroundColor: TColors.white),
                                icon: const Icon(Icons.edit_outlined,
                                    size: TSizes.v18),
                                label: const Text('Edit Expense')),
                        ])),
              ]))));

  Widget _detail(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: TSizes.v16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: TColors.textSecondary, fontSize: TSizes.v12)),
        const SizedBox(height: TSizes.v5),
        SelectableText(value,
            style: const TextStyle(
                color: TColors.textPrimary,
                fontSize: TSizes.v14,
                height: TSizes.v1_5)),
      ]));

  Future<void> _edit(ExpenseModel expense) async {
    if (_settings.scraperSettings.value == null) {
      expense20Message(context, 'Refresh the allowance rates before editing.');
      return;
    }
    final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                backgroundColor: TColors.light,
                appBar: AppBar(
                    title: const Text('Expense 2.0 · Edit'),
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white),
                body: SingleChildScrollView(
                    padding: const EdgeInsets.all(TSizes.v20),
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: TSizes.v680),
                            child: Expense20ClaimForm(
                                settings: _settings.scraperSettings.value,
                                expense: expense,
                                onSaved: () =>
                                    Navigator.pop(context, true))))))));
    if (saved == true && mounted) _load();
  }
}
