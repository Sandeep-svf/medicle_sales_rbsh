import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../services/doctor_area_assignment_service.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class DoctorAreaAssignmentScreen extends StatefulWidget {
  const DoctorAreaAssignmentScreen({
    super.key,
    required this.doctors,
    required this.areas,
    required this.service,
    this.mandatory = false,
  });

  final List<PendingAreaDoctor> doctors;
  final List<DoctorAreaOption> areas;
  final DoctorAreaAssignmentService service;
  final bool mandatory;

  @override
  State<DoctorAreaAssignmentScreen> createState() =>
      _DoctorAreaAssignmentScreenState();
}

class _DoctorAreaAssignmentScreenState
    extends State<DoctorAreaAssignmentScreen> {
  late final List<PendingAreaDoctor> _pending;
  late final List<DoctorAreaOption> _areas;
  final Map<String, String?> _selectedAreas = {};
  final Set<String> _saving = {};
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _pending = [...widget.doctors];
    _areas = [...widget.areas];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PendingAreaDoctor> get _visibleDoctors {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return _pending;
    return _pending.where((doctor) {
      return doctor.name.toLowerCase().contains(query) ||
          (doctor.specialization ?? '').toLowerCase().contains(query) ||
          (doctor.clinicName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  String? _areaNameFor(String? areaId) {
    if (areaId == null) return null;
    for (final area in _areas) {
      if (area.id == areaId) return area.name;
    }
    return null;
  }

  Future<void> _assign(PendingAreaDoctor doctor, [String? areaId]) async {
    areaId ??= _selectedAreas[doctor.id];
    if (areaId == null || _saving.contains(doctor.id)) return;
    setState(() => _saving.add(doctor.id));
    try {
      await widget.service.assignArea(
          doctorId: doctor.id,
          areaId: areaId,
          localDoctorId: doctor.localDoctorId,
          areaName: _areaNameFor(areaId));
      if (!mounted) return;
      setState(() {
        _saving.remove(doctor.id);
        _pending.removeWhere((item) => item.id == doctor.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(TTexts.uiTextAreaAssignedSuccessfully)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving.remove(doctor.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Area assignment failed: ${_errorMessage(error)}')),
      );
    }
  }

  Future<void> _findAreaByPincode(PendingAreaDoctor doctor) async {
    final result = await _showPincodeLookup();
    if (!mounted || result == null) return;

    // The lookup dialog has just completed its reverse transition. Wait for
    // that route to finish deactivating before opening the confirmation route;
    // pushing both routes in the same frame can trip Flutter's inherited
    // element deactivation assertion on some Flutter versions.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final pincode = result.$1;
    final office = result.$2;
    final officeName = (office['Name'] ?? '').toString();
    final existing = _areas.where((area) =>
        area.name.trim().toLowerCase() == officeName.trim().toLowerCase());
    final confirmed = await _confirmArea(
      office,
      pincode,
      alreadyExists: existing.isNotEmpty,
    );
    if (!mounted || confirmed != true) return;

    setState(() => _saving.add(doctor.id));
    try {
      final area = existing.isNotEmpty
          ? existing.first
          : await widget.service.createArea(
              name: officeName,
              pincode: pincode,
              postOffice: officeName,
              headOfficeId: doctor.headOfficeId ?? '',
            );
      if (!_areas.any((item) => item.id == area.id)) _areas.add(area);
      if (!mounted) return;
      setState(() {
        _saving.remove(doctor.id);
        _selectedAreas[doctor.id] = area.id;
      });
      await _assign(doctor, area.id);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving.remove(doctor.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('StateError: ', ''))),
      );
    }
  }

  Future<void> _selectExistingArea(PendingAreaDoctor doctor) async {
    final area = await showModalBottomSheet<DoctorAreaOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.transparent,
      builder: (_) => _ExistingAreaPicker(areas: _areas),
    );
    if (!mounted || area == null) return;
    setState(() => _selectedAreas[doctor.id] = area.id);
    await _assign(doctor, area.id);
  }

  Future<(String, Map<String, dynamic>)?> _showPincodeLookup() async {
    final pincodeController = TextEditingController();
    List<Map<String, dynamic>> offices = [];
    Map<String, dynamic>? selectedOffice;
    String? error;
    bool loading = false;

    final result = await showDialog<(String, Map<String, dynamic>)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> lookup() async {
            final pincode = pincodeController.text.trim();
            if (!RegExp(r'^\d{6}$').hasMatch(pincode)) {
              setDialogState(() => error = 'Enter a valid 6 digit pincode.');
              return;
            }
            setDialogState(() {
              loading = true;
              error = null;
              selectedOffice = null;
            });
            try {
              final fetched = await widget.service.fetchPostOffices(pincode);
              if (!dialogContext.mounted) return;
              setDialogState(() {
                offices = fetched;
                selectedOffice = fetched.length == 1 ? fetched.first : null;
                loading = false;
              });
            } catch (e) {
              if (!dialogContext.mounted) return;
              setDialogState(() {
                loading = false;
                error = e.toString().replaceFirst('StateError: ', '');
              });
            }
          }

          return AlertDialog(
            title: const Text(TTexts.uiTextFindAreaByPincode),
            content: SizedBox(
              width: TSizes.v460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      TTexts.uiTextEnterTheDoctorSPincodeToFetchNearby,
                    ),
                    const SizedBox(height: TSizes.md),
                    TextField(
                      controller: pincodeController,
                      autofocus: true,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: TTexts.uiTextPincode,
                        prefixIcon: Icon(Icons.pin_drop_outlined),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      onSubmitted: (_) => lookup(),
                    ),
                    const SizedBox(height: TSizes.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: loading ? null : lookup,
                        icon: loading
                            ? const SizedBox(
                                width: TSizes.v16,
                                height: TSizes.v16,
                                child: CircularProgressIndicator(
                                    strokeWidth: TSizes.v2),
                              )
                            : const Icon(Icons.search),
                        label: Text(loading
                            ? 'Fetching post offices…'
                            : 'Verify & fetch post offices'),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: TSizes.sm),
                      Text(error!,
                          style: const TextStyle(color: TColors.error)),
                    ],
                    if (offices.isNotEmpty) ...[
                      const SizedBox(height: TSizes.md),
                      Text('${offices.length} post offices found',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: TSizes.xs),
                      ...offices.map((office) =>
                          RadioListTile<Map<String, dynamic>>(
                            contentPadding: EdgeInsets.zero,
                            value: office,
                            groupValue: selectedOffice,
                            title: Text((office['Name'] ?? '').toString()),
                            subtitle: Text([
                              office['Block'],
                              office['District'],
                              office['State'],
                            ]
                                .whereType<String>()
                                .where((value) => value.isNotEmpty)
                                .join(' • ')),
                            onChanged: (value) =>
                                setDialogState(() => selectedOffice = value),
                          )),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(TTexts.cancel)),
              FilledButton(
                onPressed: selectedOffice == null
                    ? null
                    : () => Navigator.of(dialogContext)
                        .pop((pincodeController.text.trim(), selectedOffice!)),
                child: const Text(TTexts.uiTextUseSelectedPostOffice),
              ),
            ],
          );
        },
      ),
    );
    pincodeController.dispose();
    return result;
  }

  Future<bool?> _confirmArea(
    Map<String, dynamic> office,
    String pincode, {
    required bool alreadyExists,
  }) {
    final officeName = (office['Name'] ?? '').toString();
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            alreadyExists ? 'Assign existing area' : 'Confirm doctor area'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alreadyExists
                ? 'An area with this post-office name already exists. Review it before assigning.'
                : 'Review the detected post office before creating and assigning it.'),
            const SizedBox(height: TSizes.md),
            _InfoLine(label: TTexts.uiTextAreaName_01cf5f96, value: officeName),
            _InfoLine(label: TTexts.uiTextPincode, value: pincode),
            _InfoLine(
                label: TTexts.uiTextBlock,
                value: (office['Block'] ?? '-').toString()),
            _InfoLine(
                label: TTexts.uiTextDistrict,
                value: (office['District'] ?? '-').toString()),
            _InfoLine(
                label: TTexts.uiTextState,
                value: (office['State'] ?? '-').toString()),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(TTexts.cancel)),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(alreadyExists ? 'Assign area' : 'Create & assign')),
        ],
      ),
    );
  }

  void _skip() => Navigator.of(context).pop(false);

  String _errorMessage(Object error) {
    final message = error.toString().replaceFirst('StateError: ', '').trim();
    return message.isEmpty ? 'Please try again.' : message;
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.doctors.length - _pending.length;
    final visibleDoctors = _visibleDoctors;
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: TColors.primaryBackground,
        appBar: AppBar(
          automaticallyImplyLeading: !widget.mandatory,
          titleSpacing: 0,
          backgroundColor: TColors.primary,
          foregroundColor: TColors.white,
          elevation: TSizes.v0,
          title: const Row(
            children: [
              CircleAvatar(
                radius: TSizes.v17,
                backgroundColor: TColors.white24,
                child: Icon(Icons.map_outlined,
                    size: TSizes.v19, color: TColors.white),
              ),
              SizedBox(width: TSizes.v10),
              Text(TTexts.uiTextAssignDoctorAreas),
            ],
          ),
          actions: [
            if (!widget.mandatory)
              TextButton(
                onPressed: _skip,
                child: const Text(TTexts.skip,
                    style: TextStyle(color: TColors.white)),
              ),
          ],
        ),
        bottomNavigationBar: widget.mandatory
            ? SafeArea(
                minimum: const EdgeInsets.fromLTRB(
                    TSizes.md, TSizes.sm, TSizes.md, TSizes.md),
                child: _pending.isEmpty
                    ? FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(Icons.dashboard_customize_outlined),
                        label: const Text(TTexts.uiTextContinueToDashboard),
                      )
                    : OutlinedButton.icon(
                        onPressed: _skip,
                        icon: const Icon(Icons.schedule_outlined),
                        label: const Text(TTexts.uiTextSkipForNow),
                      ),
              )
            : null,
        body: SafeArea(
          bottom: !widget.mandatory,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: _AssignmentHero(
                  total: widget.doctors.length,
                  completed: completed,
                  mandatory: widget.mandatory,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      TSizes.md, 0, TSizes.md, TSizes.md),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _search = value),
                    decoration: InputDecoration(
                      hintText: TTexts.uiTextSearchByDoctorSpecialtyOrClinic,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.isEmpty
                          ? null
                          : IconButton(
                              tooltip: TTexts.uiTextClearSearch,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _search = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: TColors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: TColors.primary, width: TSizes.v1_4),
                      ),
                    ),
                  ),
                ),
              ),
              if (_pending.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _CompleteState(mandatory: widget.mandatory),
                )
              else if (visibleDoctors.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _NoSearchResults(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      TSizes.md, 0, TSizes.md, TSizes.lg),
                  sliver: SliverList.separated(
                    itemCount: visibleDoctors.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: TSizes.sm),
                    itemBuilder: (_, index) {
                      final doctor = visibleDoctors[index];
                      return _DoctorAssignmentTile(
                        key: ValueKey(doctor.id),
                        doctor: doctor,
                        selectedAreaId: _selectedAreas[doctor.id],
                        selectedAreaName:
                            _areaNameFor(_selectedAreas[doctor.id]),
                        saving: _saving.contains(doctor.id),
                        onSelectExistingArea: () => _selectExistingArea(doctor),
                        onAssign: () => _assign(doctor),
                        onPincodeArea: () => _findAreaByPincode(doctor),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentHero extends StatelessWidget {
  const _AssignmentHero(
      {required this.total, required this.completed, required this.mandatory});
  final int total;
  final int completed;
  final bool mandatory;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 1.0 : completed / total;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(
              TSizes.md, TSizes.md, TSizes.md, TSizes.md),
          padding: const EdgeInsets.all(TSizes.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [TColors.primary_shade700, TColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: TColors.primary.withValues(alpha: .22),
                blurRadius: TSizes.v18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mandatory ? 'Complete your setup' : 'Area assignment',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: TColors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: TSizes.xs),
                        Text(
                          mandatory
                              ? 'Assign each doctor to an area before continuing.'
                              : 'Keep your doctor directory organised by assigning areas.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: TColors.white.withValues(alpha: .84),
                                    height: TSizes.v1_35,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: TSizes.md),
                  Container(
                    width: TSizes.v62,
                    height: TSizes.v62,
                    decoration: BoxDecoration(
                      color: TColors.white.withValues(alpha: .16),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: TColors.white.withValues(alpha: .38)),
                    ),
                    child: Center(
                      child: Text(
                        '${(value * 100).round()}%',
                        style: const TextStyle(
                            color: TColors.white,
                            fontSize: TSizes.v16,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: TSizes.v8,
                  backgroundColor: TColors.white.withValues(alpha: .22),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(TColors.white),
                ),
              ),
              const SizedBox(height: TSizes.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$completed of $total assigned',
                      style: const TextStyle(
                          color: TColors.white, fontWeight: FontWeight.w700)),
                  Text('${total - completed} remaining',
                      style: TextStyle(
                          color: TColors.white.withValues(alpha: .78),
                          fontSize: TSizes.v12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(TSizes.md),
              decoration: const BoxDecoration(
                  color: TColors.primary_shade50, shape: BoxShape.circle),
              child: const Icon(Icons.person_search_outlined,
                  size: TSizes.v34, color: TColors.primary),
            ),
            const SizedBox(height: TSizes.md),
            Text(TTexts.uiTextNoDoctorsFound,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: TSizes.xs),
            Text(TTexts.uiTextTryADifferentNameSpecialtyOrClinicSearch,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: TColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _DoctorAssignmentTile extends StatelessWidget {
  const _DoctorAssignmentTile(
      {super.key,
      required this.doctor,
      required this.selectedAreaId,
      required this.selectedAreaName,
      required this.saving,
      required this.onAssign,
      required this.onPincodeArea,
      required this.onSelectExistingArea});
  final PendingAreaDoctor doctor;
  final String? selectedAreaId;
  final String? selectedAreaName;
  final bool saving;
  final VoidCallback onAssign;
  final VoidCallback onPincodeArea;
  final VoidCallback onSelectExistingArea;

  @override
  Widget build(BuildContext context) {
    final initials = doctor.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final details = [doctor.specialization, doctor.clinicName]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join(' • ');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: TColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selectedAreaId == null
              ? TColors.cardBorder
              : TColors.primary.withValues(alpha: .45),
          width: selectedAreaId == null ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: TColors.pureBlack.withValues(alpha: .045),
              blurRadius: TSizes.v12,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: TSizes.v25,
                backgroundColor: TColors.primary_shade50,
                child: Text(initials.isEmpty ? '?' : initials,
                    style: const TextStyle(
                        color: TColors.primary, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: TSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: TColors.textPrimary)),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: TSizes.v3),
                      Text(details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: TColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              _StatusPill(
                  label: selectedAreaId == null ? 'Needs area' : 'Ready',
                  ready: selectedAreaId != null),
            ],
          ),
          const SizedBox(height: TSizes.md),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              color: selectedAreaName == null
                  ? TColors.warningBg
                  : TColors.successBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selectedAreaName == null
                      ? Icons.info_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: selectedAreaName == null
                      ? TColors.warning
                      : TColors.success,
                  size: TSizes.v19,
                ),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  child: Text(
                    selectedAreaName == null
                        ? 'No area assigned yet. Choose an existing area or find one using the doctor’s pincode.'
                        : 'Area selected: $selectedAreaName. Assign it to finish this doctor.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TColors.textPrimary, height: TSizes.v1_3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TSizes.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: saving ? null : onPincodeArea,
                  icon: const Icon(Icons.pin_drop_outlined, size: TSizes.v18),
                  label: const Text(TTexts.uiTextFindByPincode),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: TSizes.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: saving ? null : onSelectExistingArea,
                  icon: const Icon(Icons.list_alt_outlined, size: TSizes.v18),
                  label: const Text(TTexts.uiTextChooseExisting),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: selectedAreaId == null || saving ? null : onAssign,
              icon: saving
                  ? const SizedBox(
                      width: TSizes.v17,
                      height: TSizes.v17,
                      child: CircularProgressIndicator(
                          strokeWidth: TSizes.v2, color: TColors.white))
                  : const Icon(Icons.check_circle_outline),
              label: Text(saving ? 'Assigning…' : 'Assign Area'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.ready});

  final String label;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final color = ready ? TColors.success : TColors.warning;
    final background = ready ? TColors.successBg : TColors.warningBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ready ? Icons.check_rounded : Icons.priority_high_rounded,
              size: TSizes.v14, color: color),
          const SizedBox(width: TSizes.v4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: TSizes.v11,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: TSizes.v86,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ExistingAreaPicker extends StatefulWidget {
  const _ExistingAreaPicker({required this.areas});

  final List<DoctorAreaOption> areas;

  @override
  State<_ExistingAreaPicker> createState() => _ExistingAreaPickerState();
}

class _ExistingAreaPickerState extends State<_ExistingAreaPicker> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DoctorAreaOption> get _filteredAreas {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.areas;
    return widget.areas
        .where((area) => area.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAreas;
    final height = MediaQuery.sizeOf(context).height * .78;
    return SafeArea(
      child: Container(
        height: height.clamp(420.0, 700.0).toDouble(),
        decoration: const BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: TSizes.sm),
            Container(
              width: TSizes.v52,
              height: TSizes.v5,
              decoration: BoxDecoration(
                color: TColors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  TSizes.lg, TSizes.md, TSizes.md, TSizes.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(TSizes.sm),
                    decoration: BoxDecoration(
                      color: TColors.primary_shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        color: TColors.primary),
                  ),
                  const SizedBox(width: TSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(TTexts.uiTextSelectExistingArea,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: TSizes.v2),
                        Text(
                            '${filtered.length} area${filtered.length == 1 ? '' : 's'} available',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: TColors.textSecondary,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: TTexts.uiTextSearchAreaByName,
                  prefixIcon: const Icon(Icons.search, color: TColors.primary),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  filled: true,
                  fillColor: TColors.primary_shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: TColors.primary, width: TSizes.v1_4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.sm),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(TSizes.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_off_outlined,
                                size: TSizes.v48, color: TColors.darkGrey),
                            const SizedBox(height: TSizes.sm),
                            Text(
                              widget.areas.isEmpty
                                  ? 'No existing areas found.'
                                  : 'No areas match your search.',
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(color: TColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          TSizes.md, TSizes.xs, TSizes.md, TSizes.lg),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: TSizes.v1, indent: 56),
                      itemBuilder: (_, index) {
                        final area = filtered[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: TSizes.sm, vertical: TSizes.xs),
                          leading: Container(
                            width: TSizes.v40,
                            height: TSizes.v40,
                            decoration: BoxDecoration(
                              color: TColors.primary_shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.location_on,
                                color: TColors.primary),
                          ),
                          title: Text(area.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text(
                              TTexts.uiTextTapToSelectAndAssignThisArea),
                          trailing: const Icon(Icons.chevron_right,
                              color: TColors.primary),
                          onTap: () => Navigator.of(context).pop(area),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteState extends StatelessWidget {
  const _CompleteState({required this.mandatory});
  final bool mandatory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.verified_rounded,
              color: TColors.success, size: TSizes.v58),
          const SizedBox(height: TSizes.md),
          Text(mandatory ? 'All areas assigned' : 'No pending assignments',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: TSizes.sm),
          const Text(TTexts.uiTextDoctorRecordsAreReadyForTheDashboard,
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
