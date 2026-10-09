import '../../../../utils/constants/sizes.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../../controllers/AllowenceController.dart';
import '../../controllers/other_expense_controller.dart';
import '../../models/DailyAllowenceRequestModel.dart';
import '../../models/ExpenseDefaultValueModel.dart';
import '../../models/NewExpenseModel.dart' as saved;
import '../../models/TravelAllowenceRequestModel.dart';
import '../../models/TravelDetails.dart';
import '../../models/allowance_deduction.dart';
import '../../models/other_expense_request.dart';
import '../../services/allowance_visit_service.dart';
import '../widgets/allowance_review_dialog.dart';
import 'expense20_widgets.dart';
import 'expense20_working_location.dart';

/// Presentation for Expense 2.0. Existing models, controllers and daily DCR
/// calculation remain the source of the submission contract.
class Expense20ClaimForm extends StatefulWidget {
  const Expense20ClaimForm(
      {super.key,
      required this.settings,
      required this.onSaved,
      this.expense,
      this.exportAction,
      this.onBusyChanged,
      this.workingLocation,
      this.onChangeWorkingLocation});
  final String? workingLocation;
  final VoidCallback? onChangeWorkingLocation;
  final ExpenseDefaultValueModel? settings;
  final VoidCallback onSaved;
  final saved.ExpenseModel? expense;
  final Widget? exportAction;
  final ValueChanged<bool>? onBusyChanged;

  @override
  State<Expense20ClaimForm> createState() => _Expense20ClaimFormState();
}

class _Expense20ClaimFormState extends State<Expense20ClaimForm> {
  final _remarks = TextEditingController();
  final _amount = TextEditingController();
  final List<_Expense20TravelRow> _travelRows = [];
  int _nextRowId = 0;
  int? _activeRowId;
  String _category = 'travel';
  String _tripType = 'One Way';
  String? _daType;
  String? _billPath;
  DateTime _date = DateTime.now();
  bool _busy = false;

  bool get _hideTa => !_isEdit && widget.workingLocation == 'headoffice';
  bool get _isEdit => widget.expense != null;
  double get _rate => widget.settings?.ratePerKm ?? 0;
  double get _travelAmount =>
      _travelRows.fold(0.0, (sum, row) => sum + row.fare(_rate));
  List<Map<String, dynamic>> get _legs => _travelRows
      .where((row) => row.isValid)
      .map((row) => row.toLeg(_rate))
      .toList();
  String? get _daLocation =>
      !_isEdit ? widget.workingLocation ?? _daType : _daType;
  double get _daAmount => switch (_daLocation) {
        'headoffice' => widget.settings?.headOfficeAmount ?? 0,
        'ex-headquarters' => widget.settings?.exHeadquartersAmount ?? 0,
        'outside' => widget.settings?.outsideHeadOfficeAmount ?? 0,
        _ => 0,
      };

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    if (expense != null) {
      _category = expense.category;
      _date = DateTime.tryParse(expense.date) ?? DateTime.now();
      _remarks.text =
          AllowanceDeduction.removePreviousRemark(expense.description);
      _daType = expense.dailyAllowanceType;
      for (final leg in expense.travelDetails) {
        _travelRows
            .add(_newTravelRow(from: leg.from, to: leg.to, km: '${leg.km}'));
      }
    }
    if (!_isEdit && widget.workingLocation != null) {
      _daType = widget.workingLocation;
      if (_hideTa) _category = 'daily';
    }
    if (_travelRows.isEmpty) _travelRows.add(_newTravelRow());
    _activeRowId = _travelRows.last.id;
  }

  @override
  void didUpdateWidget(covariant Expense20ClaimForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEdit && oldWidget.workingLocation != widget.workingLocation) {
      _daType = widget.workingLocation;
      if (_hideTa && _category == 'travel') _category = 'daily';
    }
  }

  @override
  void dispose() {
    for (final row in _travelRows) {
      row.dispose();
    }
    for (final controller in [_remarks, _amount]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _reset() {
    setState(() {
      _remarks.clear();
      _amount.clear();
      final previousRows = List<_Expense20TravelRow>.of(_travelRows);
      _travelRows.clear();
      for (final row in previousRows) {
        row.dispose();
      }
      _billPath = null;
      _tripType = 'One Way';
      _travelRows.add(_newTravelRow());
      _activeRowId = _travelRows.first.id;
      _daType = widget.workingLocation;
      _date = DateTime.now();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime.now());
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickBill() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          preferredCameraDevice: CameraDevice.rear);
      if (image != null && mounted) setState(() => _billPath = image.path);
    } catch (_) {
      if (mounted) {
        expense20Message(context,
            'Unable to open the camera. Please check camera permission.');
      }
    }
  }

  _Expense20TravelRow _newTravelRow(
      {String from = '', String to = '', String km = ''}) {
    final row = _Expense20TravelRow(_nextRowId++,
        from: from, to: to, km: km, tripType: _tripType);
    for (final controller in [row.from, row.to, row.km]) {
      controller.addListener(_travelChanged);
    }
    return row;
  }

  void _travelChanged() {
    if (mounted) setState(() {});
  }

  void _addLeg() {
    final row = _newTravelRow();
    setState(() {
      _travelRows.add(row);
      _activeRowId = row.id;
    });
    row.fromFocus.requestFocus();
  }

  void _activateRow(_Expense20TravelRow row) {
    if (!mounted || !_travelRows.contains(row)) return;
    setState(() {
      _activeRowId = row.id;
      _tripType = row.tripType;
    });
  }

  void _removeLeg(_Expense20TravelRow row) {
    setState(() {
      _travelRows.remove(row);
      if (_activeRowId == row.id) {
        _activeRowId = _travelRows.last.id;
        _tripType = _travelRows.last.tripType;
      }
    });
    row.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (_hideTa && _category == 'travel') return;
    if (_category == 'travel') {
      final invalid =
          _travelRows.indexWhere((row) => !row.isEmpty && !row.isValid);
      if (invalid >= 0 || _legs.isEmpty) {
        expense20Message(context,
            'Enter From, To and a valid distance in travel row ${invalid >= 0 ? invalid + 1 : 1}.');
        return;
      }
    }
    if (_category == 'daily' && _daLocation == null) {
      expense20Message(context, 'Please select DA location type.');
      return;
    }
    final otherAmount = double.tryParse(_amount.text.trim());
    if (_category == 'extra' &&
        (otherAmount == null || !otherAmount.isFinite || otherAmount < 0)) {
      expense20Message(context, 'Please enter a valid amount.');
      return;
    }
    if (_category == 'extra' && _billPath == null) {
      expense20Message(context, 'Please attach a bill photo.');
      return;
    }
    if (_category != 'extra' && widget.settings == null) {
      expense20Message(context,
          'Allowance rates are unavailable. Refresh the screen and retry.');
      return;
    }
    _setBusy(true);
    try {
      final userId = await AuthManager().getUserId();
      if (!mounted) return;
      if (userId == null || userId.isEmpty) {
        if (mounted) expense20Message(context, 'Please sign in again.');
        return;
      }
      final day = DateFormat('yyyy-MM-dd').format(_date);
      var success = false;
      String? error;
      if (_category == 'extra') {
        final bill = await OtherExpenseController.uploadBill(_billPath!);
        if (!mounted) return;
        if (bill == null) {
          expense20Message(context, 'Bill upload failed. Please retry.');
          return;
        }
        success = await OtherExpenseController.createOtherExpense(
            OtherExpenseRequest(
                userId: userId,
                description: _remarks.text.trim(),
                amount: otherAmount!,
                bill: bill,
                date: _date.toString()));
      } else {
        final visits = await AllowanceVisitService().fetchForDay(userId, _date);
        final deduction = AllowanceDeduction.calculate(
            category: _category,
            date: day,
            grossAmount: _category == 'travel' ? _travelAmount : _daAmount,
            visits: visits);
        if (!mounted) return;
        final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) => AllowanceReviewDialog(deduction: deduction));
        if (confirmed != true || !mounted) return;
        if (_category == 'travel') {
          final request = TravelAllowanceRequest(
              userId: userId,
              date: day,
              amount: deduction.payableAmount,
              description: deduction.appendTo(_remarks.text.trim().isEmpty
                  ? '$_tripType: Travel Allowance submission'
                  : '$_tripType: ${_remarks.text.trim()}'),
              travelDetails: _legs
                  .map((leg) => TravelDetail(
                      from: leg['from'] as String,
                      to: leg['to'] as String,
                      km: (leg['km'] as double) *
                          (leg['tripType'] == 'Round Trip' ? 2 : 1)))
                  .toList());
          success = _isEdit
              ? await AllowanceController.updateExpense(
                  expenseId: widget.expense!.id, data: request.toJson())
              : await AllowanceController.submitTravelAllowance(request,
                  onError: (message) => error = message);
        } else {
          final request = DailyAllowanceRequest(
              userId: userId,
              date: day,
              amount: deduction.payableAmount,
              dailyAllowanceType: _daLocation!,
              description: deduction.appendTo(_remarks.text.trim()));
          success = _isEdit
              ? await AllowanceController.updateExpense(
                  expenseId: widget.expense!.id, data: request.toJson())
              : await AllowanceController.submitDailyAllowance(request);
        }
      }
      if (!mounted) return;
      if (success) {
        expense20Message(
            context,
            _isEdit
                ? 'Expense updated successfully.'
                : 'Expense submitted successfully.');
        if (!_isEdit) {
          _reset();
        }
        _setBusy(false);
        widget.onSaved();
      } else {
        expense20Message(
            context,
            error ??
                (_isEdit
                    ? 'Failed to update expense.'
                    : 'Failed to submit expense. Please retry.'));
      }
    } catch (error) {
      if (mounted) {
        expense20Message(
            context,
            error is AllowanceVisitException
                ? error.message
                : 'Unable to submit expense. Please retry.');
      }
    } finally {
      if (mounted && _busy) _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    setState(() => _busy = value);
    widget.onBusyChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_busy,
        child: Expense20Panel(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Expense20Heading(
                  title: _isEdit ? 'Edit Expense' : 'Add New Expense',
                  subtitle: 'Fill the details below to claim your expense',
                  icon:
                      _isEdit ? Icons.edit_outlined : Icons.add_circle_outline),
              const SizedBox(height: TSizes.v20),
              if (widget.exportAction != null) ...[
                Align(
                    alignment: Alignment.centerRight,
                    child: widget.exportAction),
                const SizedBox(height: TSizes.v16),
              ],
              if (_busy)
                const Padding(
                    padding: EdgeInsets.only(bottom: TSizes.v16),
                    child: LinearProgressIndicator(
                        color: TColors.primary,
                        backgroundColor: TColors.borderSecondary)),
              AbsorbPointer(
                  absorbing: _busy,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.workingLocation != null) ...[
                          Container(
                              padding: const EdgeInsets.all(TSizes.v12),
                              decoration: BoxDecoration(
                                  color: TColors.light,
                                  borderRadius:
                                      BorderRadius.circular(TSizes.v12)),
                              child: Row(children: [
                                const Icon(Icons.location_on_outlined,
                                    color: TColors.primary),
                                const SizedBox(width: TSizes.v8),
                                Expanded(
                                    child: Text(
                                        'Working location: ${expense20WorkingLocations[widget.workingLocation]}${_hideTa ? '\nAdd TA is unavailable while working at HQ.' : ''}')),
                                TextButton(
                                    onPressed: _busy
                                        ? null
                                        : widget.onChangeWorkingLocation,
                                    child: const Text('Change')),
                              ])),
                          const SizedBox(height: TSizes.v16),
                        ],
                        expense20Label('Expense Type', _typeSelector()),
                        const SizedBox(height: TSizes.v20),
                        if (_category == 'travel')
                          ..._travelFields()
                        else if (_category == 'daily')
                          ..._dailyFields()
                        else
                          ..._otherFields(),
                        const SizedBox(height: TSizes.v18),
                        expense20Label(
                            'Purpose / Remarks',
                            TextField(
                                key: const ValueKey('expense20-remarks'),
                                controller: _remarks,
                                minLines: 2,
                                maxLines: 4,
                                style: const TextStyle(
                                    color: TColors.textPrimary,
                                    fontSize: TSizes.v13),
                                decoration: expense20Input(
                                    'e.g. Doctor visits at Purnia HQ'))),
                        const SizedBox(height: TSizes.v18),
                        if (_category == 'extra')
                          _billField()
                        else
                          Container(
                              padding: const EdgeInsets.all(TSizes.v12),
                              decoration: BoxDecoration(
                                  color: TColors.light,
                                  borderRadius:
                                      BorderRadius.circular(TSizes.v7)),
                              child: const Row(children: [
                                Icon(Icons.info_outline,
                                    color: TColors.textSecondary,
                                    size: TSizes.v17),
                                SizedBox(width: TSizes.v8),
                                Expanded(
                                    child: Text(
                                        'TA / DA do not require a bill. Daily call eligibility is reviewed before submission.',
                                        style: TextStyle(
                                            color: TColors.textSecondary,
                                            fontSize: TSizes.v12,
                                            height: TSizes.v1_5))),
                              ])),
                        const SizedBox(height: TSizes.v22),
                        OverflowBar(
                            alignment: MainAxisAlignment.spaceBetween,
                            spacing: TSizes.v12,
                            overflowSpacing: 12,
                            children: [
                              OutlinedButton.icon(
                                  onPressed: _isEdit ? null : _reset,
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: TColors.textSecondary),
                                  icon: const Icon(Icons.restart_alt,
                                      size: TSizes.v18),
                                  label: const Text('Reset')),
                              FilledButton.icon(
                                  key: const ValueKey('expense20-submit'),
                                  onPressed: _busy ? null : _submit,
                                  style: FilledButton.styleFrom(
                                      backgroundColor: TColors.primary,
                                      foregroundColor: TColors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: TSizes.v24,
                                          vertical: TSizes.v18)),
                                  icon: const Icon(Icons.send_outlined,
                                      size: TSizes.v18),
                                  label: Text(_busy
                                      ? 'Please wait…'
                                      : _isEdit
                                          ? 'Update Expense'
                                          : 'Submit Expense')),
                            ]),
                      ])),
            ])),
      );

  Widget _typeSelector() =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final type in [if (!_hideTa) 'travel', 'daily', 'extra'])
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(
                      right: type == 'extra' ? TSizes.v0 : TSizes.v8),
                  child: InkWell(
                      key: ValueKey('expense20-category-$type'),
                      onTap: _isEdit
                          ? null
                          : () => setState(() => _category = type),
                      borderRadius: BorderRadius.circular(TSizes.v8),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.v6, vertical: TSizes.v14),
                          decoration: BoxDecoration(
                              color: _category == type
                                  ? expense20TypeBackground(type)
                                  : expense20TypeBackground(type).withValues(
                                      alpha: TColors.expenseMutedOpacity),
                              borderRadius: BorderRadius.circular(TSizes.v8),
                              border: Border.all(
                                  color: _category == type
                                      ? expense20TypeColor(type)
                                      : TColors.borderSecondary)),
                          child: Column(children: [
                            Icon(expense20Icon(type),
                                color: expense20TypeColor(type),
                                size: TSizes.v26),
                            const SizedBox(height: TSizes.v7),
                            Text(expense20Type(type),
                                style: TextStyle(
                                    color: expense20TypeColor(type),
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: TSizes.v3),
                            Text(
                                type == 'travel'
                                    ? 'Travel Allowance'
                                    : type == 'daily'
                                        ? 'Daily Allowance'
                                        : 'Other Expense',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: TColors.textSecondary,
                                    fontSize: TSizes.v10)),
                          ])))))
      ]);

  Widget _dateField() => expense20Label(
      _category == 'travel' ? 'Travel Date' : 'Expense Date',
      InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(TSizes.v7),
          child: InputDecorator(
              decoration: expense20Input(''),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    color: TColors.primary, size: TSizes.v17),
                const SizedBox(width: TSizes.v10),
                Expanded(
                    child: Text(DateFormat('dd MMM yyyy').format(_date),
                        style: const TextStyle(
                            color: TColors.textPrimary, fontSize: TSizes.v13))),
                const Icon(Icons.expand_more,
                    color: TColors.textSecondary, size: TSizes.v18),
              ]))));

  Widget _field(String key, TextEditingController controller, String hint,
          {bool number = false, bool compact = false, FocusNode? focusNode}) =>
      TextField(
          key: ValueKey(key),
          controller: controller,
          focusNode: focusNode,
          style:
              const TextStyle(color: TColors.textPrimary, fontSize: TSizes.v13),
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: number
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
              : null,
          decoration: compact
              ? expense20Input(hint).copyWith(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: TSizes.v8, vertical: TSizes.v14),
                  suffixText: number ? 'km' : null,
                  suffixStyle: const TextStyle(
                      color: TColors.textSecondary, fontSize: TSizes.v11))
              : expense20Input(hint));

  List<Widget> _travelFields() => [
        expense20Pair(
            expense20Label(
                'Travel Type',
                Wrap(
                    spacing: TSizes.v6,
                    runSpacing: TSizes.v6,
                    children: ['One Way', 'Round Trip']
                        .map((type) => ChoiceChip(
                            label: Text(type,
                                style: const TextStyle(fontSize: TSizes.v12)),
                            selected: _tripType == type,
                            selectedColor: TColors.primaryBackground,
                            backgroundColor: TColors.white,
                            checkmarkColor: TColors.primary,
                            onSelected: (_) => setState(() {
                                  _tripType = type;
                                  final row = _travelRows.firstWhere(
                                      (row) => row.id == _activeRowId,
                                      orElse: () => _travelRows.last);
                                  row.tripType = type;
                                })))
                        .toList())),
            _dateField()),
        const SizedBox(height: TSizes.v18),
        for (var index = 0; index < _travelRows.length; index++)
          _travelRow(_travelRows[index], index),
        Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
                key: const ValueKey('expense20-add-leg'),
                onPressed: widget.settings == null ? null : _addLeg,
                style:
                    OutlinedButton.styleFrom(foregroundColor: TColors.primary),
                icon: const Icon(Icons.add, size: TSizes.v20),
                label: const Text('Add travel row'))),
        const SizedBox(height: TSizes.v16),
        expense20Pair(
            expense20Label(
                'Rate per KM',
                InputDecorator(
                    decoration: expense20Input(''),
                    child: Text(
                        widget.settings == null
                            ? 'Unavailable'
                            : expense20Money(_rate),
                        style: const TextStyle(
                            color: TColors.textPrimary,
                            fontSize: TSizes.v13)))),
            _fare('Original TA fare', _travelAmount)),
        const SizedBox(height: TSizes.v8),
        const Text(
            'Enter each journey in a row. All distances are included in one TA claim.',
            style:
                TextStyle(color: TColors.textSecondary, fontSize: TSizes.v11)),
      ];

  Widget _travelRow(_Expense20TravelRow row, int index) => Focus(
      key: ValueKey('expense20-travel-row-${row.id}'),
      onFocusChange: (focused) {
        if (focused) _activateRow(row);
      },
      child: Container(
          margin: const EdgeInsets.only(bottom: TSizes.v12),
          padding: const EdgeInsets.all(TSizes.v12),
          decoration: BoxDecoration(
              color: TColors.light,
              borderRadius: BorderRadius.circular(TSizes.v8),
              border: Border.all(color: TColors.borderSecondary)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                  child: Text('Journey ${index + 1} · ${row.tripType}',
                      style: const TextStyle(
                          color: TColors.primary,
                          fontSize: TSizes.v11,
                          fontWeight: FontWeight.w600))),
              IconButton(
                  key: ValueKey('expense20-swap-${row.id}'),
                  tooltip: 'Swap locations',
                  constraints: const BoxConstraints.tightFor(
                      width: TSizes.v32, height: TSizes.v32),
                  padding: const EdgeInsets.all(TSizes.v6),
                  onPressed: () {
                    _activateRow(row);
                    final from = row.from.text;
                    row.from.text = row.to.text;
                    row.to.text = from;
                  },
                  icon: const Icon(Icons.swap_horiz,
                      color: TColors.primary, size: TSizes.v18)),
              if (_travelRows.length > 1)
                IconButton(
                    key: ValueKey('expense20-remove-${row.id}'),
                    tooltip: 'Remove travel row',
                    constraints: const BoxConstraints.tightFor(
                        width: TSizes.v32, height: TSizes.v32),
                    padding: const EdgeInsets.all(TSizes.v6),
                    onPressed: () => _removeLeg(row),
                    icon: const Icon(Icons.close,
                        color: TColors.error, size: TSizes.v18)),
            ]),
            const SizedBox(height: TSizes.v8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  flex: 4,
                  child: expense20Label(
                      'From',
                      _field('expense20-from-${row.id}', row.from, 'From',
                          compact: true, focusNode: row.fromFocus))),
              const SizedBox(width: TSizes.v8),
              Expanded(
                  flex: 4,
                  child: expense20Label(
                      'To',
                      _field('expense20-to-${row.id}', row.to, 'To',
                          compact: true))),
              const SizedBox(width: TSizes.v8),
              Expanded(
                  flex: 3,
                  child: expense20Label(
                      'KM',
                      _field('expense20-km-${row.id}', row.km, '0',
                          number: true, compact: true))),
            ]),
          ])));

  List<Widget> _dailyFields() => [
        expense20Pair(
            expense20Label(
                'DA Location Type',
                !_isEdit && widget.workingLocation != null
                    ? InputDecorator(
                        key: const ValueKey('expense20-da-selected-location'),
                        decoration: expense20Input('Working location'),
                        child: Row(children: [
                          const Icon(Icons.location_on_outlined,
                              color: TColors.primary, size: TSizes.iconSm),
                          const SizedBox(width: TSizes.sm),
                          Expanded(
                              child: Text(
                                  expense20WorkingLocations[_daLocation]!,
                                  style: const TextStyle(
                                      color: TColors.textPrimary,
                                      fontSize: TSizes.v13,
                                      fontWeight: FontWeight.w600))),
                        ]),
                      )
                    : DropdownButtonFormField<String>(
                        key: ValueKey('expense20-da-type-$_daType'),
                        value: _daType,
                        isExpanded: true,
                        decoration: expense20Input('Select location type'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: TColors.textPrimary, fontSize: TSizes.v13),
                        dropdownColor: TColors.white,
                        items: const [
                          DropdownMenuItem(
                              value: 'headoffice', child: Text('Headquarter')),
                          DropdownMenuItem(
                              value: 'ex-headquarters',
                              child: Text('X Station')),
                          DropdownMenuItem(
                              value: 'outside', child: Text('Out of Station'))
                        ],
                        onChanged: (value) => setState(() => _daType = value))),
            _dateField()),
        const SizedBox(height: TSizes.v18),
        _fare('Original DA amount', _daAmount),
      ];

  List<Widget> _otherFields() => [
        expense20Pair(
            expense20Label(
                'Amount (₹)',
                _field('expense20-other-amount', _amount, 'Enter amount',
                    number: true)),
            _dateField()),
      ];

  Widget _fare(String label, double value) => Container(
      padding: const EdgeInsets.all(TSizes.v14),
      decoration: BoxDecoration(
          color: TColors.primaryBackground,
          borderRadius: BorderRadius.circular(TSizes.v8)),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: TColors.textSecondary, fontSize: TSizes.v12))),
        Text(expense20Money(value),
            style: const TextStyle(
                color: TColors.primary,
                fontSize: TSizes.v19,
                fontWeight: FontWeight.w700))
      ]));

  Widget _billField() => expense20Label(
      'Bill / Proof (required)',
      InkWell(
          onTap: _pickBill,
          borderRadius: BorderRadius.circular(TSizes.v8),
          child: Container(
              padding: const EdgeInsets.all(TSizes.v18),
              decoration: BoxDecoration(
                  color: TColors.light,
                  borderRadius: BorderRadius.circular(TSizes.v8),
                  border: Border.all(color: TColors.borderPrimary)),
              child: Row(children: [
                if (_billPath == null)
                  const Icon(Icons.camera_alt_outlined,
                      color: TColors.primary, size: TSizes.v30)
                else
                  ClipRRect(
                      borderRadius: BorderRadius.circular(TSizes.v6),
                      child: Image.file(File(_billPath!),
                          width: TSizes.v54,
                          height: TSizes.v54,
                          fit: BoxFit.cover)),
                const SizedBox(width: TSizes.v14),
                Expanded(
                    child: Text(
                        _billPath == null
                            ? 'Capture bill / invoice photo'
                            : 'Bill photo attached · tap to replace',
                        style: const TextStyle(
                            color: TColors.primary, fontSize: TSizes.v12))),
                if (_billPath != null)
                  IconButton(
                      onPressed: () => setState(() => _billPath = null),
                      tooltip: 'Remove bill',
                      icon: const Icon(Icons.close,
                          color: TColors.textSecondary, size: TSizes.v18)),
              ]))));
}

/// Controllers belong to the form; API request models remain unchanged.
class _Expense20TravelRow {
  _Expense20TravelRow(this.id,
      {String from = '',
      String to = '',
      String km = '',
      required this.tripType})
      : from = TextEditingController(text: from),
        to = TextEditingController(text: to),
        km = TextEditingController(text: km);

  final int id;
  final TextEditingController from;
  final TextEditingController to;
  final TextEditingController km;
  final FocusNode fromFocus = FocusNode();
  String tripType;

  double? get distance => double.tryParse(km.text.trim());
  bool get isEmpty =>
      from.text.trim().isEmpty &&
      to.text.trim().isEmpty &&
      km.text.trim().isEmpty;
  bool get isValid =>
      from.text.trim().isNotEmpty &&
      to.text.trim().isNotEmpty &&
      distance != null &&
      distance!.isFinite &&
      distance! >= 0;

  double fare(double rate) =>
      distance != null && distance!.isFinite && distance! >= 0
          ? distance! * rate * (tripType == 'Round Trip' ? 2 : 1)
          : 0;

  Map<String, dynamic> toLeg(double rate) => {
        'from': from.text.trim(),
        'to': to.text.trim(),
        'km': distance!,
        'tripType': tripType,
        'fare': fare(rate),
      };

  void dispose() {
    from.dispose();
    to.dispose();
    km.dispose();
    fromFocus.dispose();
  }
}
