import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../../../addDoctor/controllers/DoctroController.dart';
import '../../../addDoctor/models/DoctorModelList.dart' as online_doctor;
import '../../../doctor_offline/doctor_offline_module.dart';
import '../../../doctor_offline/models/doctor.dart' as offline_doctor;
import '../models/pending_area_assignment_model.dart';
import '../repository/pending_area_assignment_repository.dart';
import '../services/doctor_area_assignment_queue_service.dart';
import '../services/doctor_schedule_service.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

// Adjust these imports to match your project structure

class ScheduleVisitScreen extends StatefulWidget {
  const ScheduleVisitScreen({super.key});

  @override
  State<ScheduleVisitScreen> createState() => _ScheduleVisitScreenState();
}

class _ScheduleVisitScreenState extends State<ScheduleVisitScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final DoctorListController _doctorListController =
      Get.isRegistered<DoctorListController>()
          ? Get.find<DoctorListController>()
          : Get.put(DoctorListController());
  final AuthManager _authManager = AuthManager();
  DoctorOfflineModule? _doctorModule;
  List<offline_doctor.Doctor> _offlineDoctors = const [];
  List<offline_doctor.Doctor> _filteredOfflineDoctors = const [];
  List<_ScheduleArea> _offlineAreas = const [];
  final Map<String, _ScheduleArea> _selectedAreaOverrides =
      <String, _ScheduleArea>{};
  final Map<String, PendingAreaAssignmentModel> _savedAreaAssignments =
      <String, PendingAreaAssignmentModel>{};

  // Selected Data
  final List<_ScheduleDoctor> _selectedDoctors = <_ScheduleDoctor>[];
  final Map<String, _DoctorScheduleDraft> _doctorDrafts =
      <String, _DoctorScheduleDraft>{};
  bool _useSameDetails = true;
  bool _isSubmitting = false;

  // Animation Controller
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Setup Animation
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
    unawaited(_loadOfflineDoctors());
  }

  Future<void> _loadOfflineDoctors() async {
    final accountId = await _authManager.getUserId();
    if (accountId == null || accountId.trim().isEmpty) return;
    DoctorOfflineModule? module;
    try {
      module = await DoctorOfflineModule.acquire(accountId: accountId);
      _doctorModule = module;
      await module.controller.refreshDoctors();
      final cachedAreas = await _readCachedAreas(module);
      final pendingAreas =
          await PendingAreaAssignmentRepository().getForUser(accountId);
      if (!mounted) return;
      final doctors = _restoreCachedAreaIds(
        module.controller.allDoctors,
        cachedAreas,
      );
      setState(() {
        _offlineDoctors = List<offline_doctor.Doctor>.of(doctors);
        _filteredOfflineDoctors = List<offline_doctor.Doctor>.of(doctors);
        _offlineAreas = cachedAreas;
        _savedAreaAssignments
          ..clear()
          ..addEntries(
            pendingAreas.map(
                (assignment) => MapEntry(assignment.doctorLocalId, assignment)),
          );
        _selectedAreaOverrides
          ..clear()
          ..addEntries(
            pendingAreas
                .where((assignment) => assignment.areaId.trim().isNotEmpty)
                .map(
                  (assignment) => MapEntry(
                    assignment.doctorLocalId,
                    _ScheduleArea(
                      id: assignment.areaId,
                      name: assignment.areaName,
                    ),
                  ),
                ),
          );
      });
    } catch (error) {
      debugPrint(
          'ScheduleVisitScreen: offline doctor catalog unavailable: $error');
      if (module != null) {
        if (identical(_doctorModule, module)) _doctorModule = null;
        await module.dispose();
      }
      unawaited(_doctorListController.fetchDoctorList());
    }
  }

  Future<List<_ScheduleArea>> _readCachedAreas(
      DoctorOfflineModule module) async {
    final rows = await module.controller.creationStore?.readLookup('areas') ??
        const <Map<String, dynamic>>[];
    final areas = <String, _ScheduleArea>{};
    for (final row in rows) {
      final id = row['id'] ?? row['_id'];
      final name = row['name'];
      final areaId = id?.toString().trim();
      final areaName = name?.toString().trim();
      if (areaId != null &&
          areaId.isNotEmpty &&
          areaName != null &&
          areaName.isNotEmpty) {
        areas[areaId] = _ScheduleArea(id: areaId, name: areaName);
      }
    }
    return areas.values.toList(growable: false);
  }

  List<offline_doctor.Doctor> _restoreCachedAreaIds(
    List<offline_doctor.Doctor> doctors,
    List<_ScheduleArea> areas,
  ) {
    final areasByName = <String, _ScheduleArea>{
      for (final area in areas) area.name.trim().toLowerCase(): area,
    };
    return doctors.map((doctor) {
      if (doctor.areaId != null || doctor.areaName == null) return doctor;
      final area = areasByName[doctor.areaName!.trim().toLowerCase()];
      return area == null
          ? doctor
          : doctor.copyWith(areaId: area.id, areaName: area.name);
    }).toList(growable: false);
  }

  @override
  void dispose() {
    final module = _doctorModule;
    if (module != null) unawaited(module.dispose());
    _dateController.dispose();
    _notesController.dispose();
    _remarkController.dispose();
    for (final draft in _doctorDrafts.values) {
      draft.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  List<_ScheduleDoctor> get _selectedDoctorOptions =>
      List<_ScheduleDoctor>.unmodifiable(_selectedDoctors);

  void _replaceSelectedDoctors(List<_ScheduleDoctor> doctors) {
    final selectedKeys = doctors.map((doctor) => doctor.key).toSet();
    for (final key in _doctorDrafts.keys.toList()) {
      if (!selectedKeys.contains(key)) {
        _doctorDrafts.remove(key)?.dispose();
      }
    }
    for (final doctor in doctors) {
      _doctorDrafts.putIfAbsent(
        doctor.key,
        () => _DoctorScheduleDraft(
          date: _dateController.text,
          notes: _notesController.text,
          remark: _remarkController.text,
        ),
      );
    }
    setState(() {
      _selectedDoctors
        ..clear()
        ..addAll(doctors);
    });
  }

  void _removeSelectedDoctor(_ScheduleDoctor doctor) {
    _doctorDrafts.remove(doctor.key)?.dispose();
    setState(() {
      _selectedDoctors.removeWhere((selected) => selected.key == doctor.key);
    });
  }

  void _setDetailsMode(bool useSameDetails) {
    if (_useSameDetails == useSameDetails) return;

    if (!useSameDetails) {
      for (final doctor in _selectedDoctors) {
        final draft = _doctorDrafts[doctor.key];
        if (draft == null) continue;
        draft.date = _dateController.text;
        draft.notesController.text = _notesController.text;
        draft.remarkController.text = _remarkController.text;
      }
    } else if (_selectedDoctors.isNotEmpty) {
      final firstDraft = _doctorDrafts[_selectedDoctors.first.key];
      if (firstDraft != null) {
        _dateController.text = firstDraft.date;
        _notesController.text = firstDraft.notesController.text;
        _remarkController.text = firstDraft.remarkController.text;
      }
    }

    setState(() => _useSameDetails = useSameDetails);
  }

  Future<void> _pickDateForDoctor(_ScheduleDoctor doctor) async {
    final draft = _doctorDrafts[doctor.key];
    if (draft == null) return;
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateFormat('dd-MM-yyyy').parseStrict(draft.date);
    } catch (_) {}
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: TColors.primary,
            onPrimary: TColors.white,
            onSurface: TColors.pureBlack,
          ),
          dialogBackgroundColor: TColors.white,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        draft.date = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  bool _isValidScheduleDate(String value) {
    try {
      DateFormat('dd-MM-yyyy').parseStrict(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  // --- 🔍 MULTI-SELECT DOCTOR SHEET ---
  void _openDoctorSearchSheet() {
    if (_offlineDoctors.isNotEmpty) {
      _openOfflineDoctorSearchSheet();
      return;
    }
    _doctorListController.filterDoctors("");
    final selectedKeys = _selectedDoctors.map((doctor) => doctor.key).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, sheetState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: TSizes.v40,
                      height: TSizes.v4,
                      decoration: BoxDecoration(
                          color: TColors.materialGrey300,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  _buildSheetHeader(
                    title: TTexts.uiTextSelectDoctors_6a8b4df3,
                    count: selectedKeys.length,
                    onDone: () {
                      final selected = _doctorListController.doctorList
                          .map(_ScheduleDoctor.fromOnline)
                          .where((doctor) => selectedKeys.contains(doctor.key))
                          .toList();
                      _replaceSelectedDoctors(selected);
                      Navigator.pop(context);
                    },
                  ),
                  if (selectedKeys.isNotEmpty)
                    _buildSelectionPreview(
                      selectedKeys: selectedKeys,
                      doctors: _doctorListController.doctorList
                          .map(_ScheduleDoctor.fromOnline)
                          .toList(),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: TTexts.uiTextSearchByName,
                        prefixIcon:
                            const Icon(Icons.search, color: TColors.primary),
                        filled: true,
                        fillColor: TColors.materialGrey100,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16),
                      ),
                      onChanged: (val) {
                        _doctorListController.filterDoctors(val);
                        sheetState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: TSizes.v10),
                  Expanded(
                    child: Obx(() {
                      final list = _doctorListController.filteredDoctors;
                      if (list.isEmpty) {
                        return const Center(
                            child: Text(TTexts.uiTextNoDoctorsFound));
                      }

                      return ListView.separated(
                        controller: scrollController,
                        itemCount: list.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: TSizes.v2),
                        itemBuilder: (context, index) {
                          final doctor =
                              _ScheduleDoctor.fromOnline(list[index]);
                          return _buildDoctorSelectionTile(
                            doctor: doctor,
                            selected: selectedKeys.contains(doctor.key),
                            onSelected: () {
                              if (selectedKeys.contains(doctor.key)) {
                                selectedKeys.remove(doctor.key);
                              } else {
                                selectedKeys.add(doctor.key);
                              }
                              _replaceSelectedDoctors(
                                _doctorListController.doctorList
                                    .map(_ScheduleDoctor.fromOnline)
                                    .where((item) =>
                                        selectedKeys.contains(item.key))
                                    .toList(),
                              );
                              sheetState(() {});
                            },
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openOfflineDoctorSearchSheet() {
    var query = '';
    var visible = List<offline_doctor.Doctor>.of(_filteredOfflineDoctors);
    final selectedKeys = _selectedDoctors.map((doctor) => doctor.key).toSet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, sheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) => Container(
              decoration: const BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: TSizes.v14),
                  _buildSheetHeader(
                    title: TTexts.uiTextSelectDoctors_6a8b4df3,
                    count: selectedKeys.length,
                    onDone: () {
                      final selected = _offlineDoctors
                          .map(_ScheduleDoctor.fromOffline)
                          .where((doctor) => selectedKeys.contains(doctor.key))
                          .toList();
                      _replaceSelectedDoctors(selected);
                      Navigator.pop(context);
                    },
                  ),
                  if (selectedKeys.isNotEmpty)
                    _buildSelectionPreview(
                      selectedKeys: selectedKeys,
                      doctors: _offlineDoctors
                          .map(_ScheduleDoctor.fromOffline)
                          .toList(),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: TTexts.uiTextSearchByName,
                        prefixIcon:
                            const Icon(Icons.search, color: TColors.primary),
                        filled: true,
                        fillColor: TColors.materialGrey100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        query = value.trim().toLowerCase();
                        visible = _offlineDoctors
                            .where((doctor) => doctor.matchesSearch(query))
                            .toList();
                        sheetState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: visible.isEmpty
                        ? const Center(child: Text(TTexts.uiTextNoDoctorsFound))
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: visible.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: TSizes.v2),
                            itemBuilder: (_, index) {
                              final doctor =
                                  _ScheduleDoctor.fromOffline(visible[index]);
                              return _buildDoctorSelectionTile(
                                doctor: doctor,
                                selected: selectedKeys.contains(doctor.key),
                                onSelected: () {
                                  if (selectedKeys.contains(doctor.key)) {
                                    selectedKeys.remove(doctor.key);
                                  } else {
                                    selectedKeys.add(doctor.key);
                                  }
                                  _replaceSelectedDoctors(
                                    _offlineDoctors
                                        .map(_ScheduleDoctor.fromOffline)
                                        .where((item) =>
                                            selectedKeys.contains(item.key))
                                        .toList(),
                                  );
                                  sheetState(() {});
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSheetHeader({
    required String title,
    required int count,
    required VoidCallback onDone,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              count == 0 ? title : '$title ($count selected)',
              style: TextStyle(
                fontSize: TSizes.v18,
                fontWeight: FontWeight.bold,
                color: TColors.materialGrey800,
              ),
            ),
          ),
          TextButton(
            onPressed: onDone,
            child: const Text(TTexts.uiTextDone),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionPreview({
    required Set<String> selectedKeys,
    required List<_ScheduleDoctor> doctors,
  }) {
    final selectedDoctors = doctors
        .where((doctor) => selectedKeys.contains(doctor.key))
        .toList(growable: false);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      decoration: BoxDecoration(
        color: TColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TTexts.uiTextSelectedDoctors,
            style: TextStyle(
              color: TColors.primary,
              fontSize: TSizes.v12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TSizes.v6),
          Wrap(
            spacing: TSizes.v6,
            runSpacing: TSizes.v0,
            children: selectedDoctors
                .map(
                  (doctor) => Chip(
                    label: Text(
                      doctor.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    avatar: CircleAvatar(
                      backgroundColor: TColors.primary.withOpacity(0.12),
                      child: Text(
                        doctor.initial,
                        style: const TextStyle(
                          color: TColors.primary,
                          fontSize: TSizes.v11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: TColors.white,
                    side: BorderSide.none,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSelectionTile({
    required _ScheduleDoctor doctor,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      elevation: TSizes.v0,
      color: selected ? TColors.primary.withOpacity(0.06) : TColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected
              ? TColors.primary.withOpacity(0.35)
              : TColors.materialGrey.withOpacity(0.15),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: onSelected,
        leading: CircleAvatar(
          backgroundColor: TColors.primary.withOpacity(0.1),
          child: Text(
            doctor.initial,
            style: const TextStyle(
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          doctor.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            doctor.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style:
                TextStyle(color: TColors.materialGrey700, height: TSizes.v1_3),
          ),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: TTexts.uiTextDoctorDetails_92c212eb,
              icon: const Icon(Icons.info_outline_rounded),
              color: TColors.primary,
              onPressed: () => _showDoctorDetails(doctor),
            ),
            Checkbox(
              value: selected,
              activeColor: TColors.primary,
              onChanged: (_) => onSelected(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorDetails(_ScheduleDoctor doctor) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doctor.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(
                  Icons.local_hospital_outlined, 'Clinic', doctor.clinic),
              _detailRow(Icons.location_on_outlined, 'Address', doctor.address),
              _detailRow(Icons.medical_services_outlined, 'Specialization',
                  doctor.specialization),
              _detailRow(
                  Icons.school_outlined, 'Qualification', doctor.qualification),
              _detailRow(Icons.phone_outlined, 'Phone', doctor.phone),
              _detailRow(Icons.email_outlined, 'Email', doctor.email),
              _detailRow(
                  Icons.map_outlined, 'Area', _effectiveAreaName(doctor)),
              _detailRow(Icons.flag_outlined, 'Priority', doctor.priority),
              if (doctor.timings != null)
                _detailRow(Icons.schedule_outlined, 'Available timings',
                    doctor.timings!),
              _detailRow(
                doctor.serverId == null
                    ? Icons.cloud_off_outlined
                    : Icons.cloud_done_outlined,
                'Sync status',
                doctor.serverId == null
                    ? 'Doctor will sync before this schedule'
                    : 'Doctor synced',
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: TColors.white,
              ),
              child: const Text(TTexts.uiTextClose),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: TSizes.v18, color: TColors.primary),
          const SizedBox(width: TSizes.v10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    color: TColors.materialGrey800, height: TSizes.v1_3),
                children: [
                  TextSpan(
                    text: '$label\n',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ScheduleArea? _selectedAreaFor(_ScheduleDoctor doctor) =>
      _selectedAreaOverrides[doctor.key];

  _ScheduleArea? _cachedAreaFor(_ScheduleDoctor doctor) {
    final areaName = doctor.areaName?.trim().toLowerCase();
    if (areaName == null || areaName.isEmpty) return null;
    for (final area in _offlineAreas) {
      if (area.name.trim().toLowerCase() == areaName) return area;
    }
    return null;
  }

  String? _effectiveAreaId(_ScheduleDoctor doctor) =>
      doctor.areaId ??
      _selectedAreaFor(doctor)?.id ??
      _cachedAreaFor(doctor)?.id;

  String? _effectiveAreaName(_ScheduleDoctor doctor) =>
      _selectedAreaFor(doctor)?.name ??
      doctor.areaName ??
      _cachedAreaFor(doctor)?.name ??
      doctor.area;

  bool _needsAreaSelection(_ScheduleDoctor doctor) =>
      _effectiveAreaId(doctor) == null;

  Future<void> _openAreaPicker(_ScheduleDoctor doctor) async {
    if (_offlineAreas.isEmpty) {
      Get.snackbar(
        'Area unavailable',
        TTexts.uiTextNoCachedAreasAreAvailableConnectOnceTo,
        backgroundColor: TColors.materialOrange.withOpacity(0.1),
        colorText: TColors.materialDeepOrange,
      );
      return;
    }

    final selected = await showModalBottomSheet<_ScheduleArea>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.transparent,
      builder: (context) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final visible = _offlineAreas
                .where((area) => area.name
                    .toLowerCase()
                    .contains(query.trim().toLowerCase()))
                .toList(growable: false);
            return DraggableScrollableSheet(
              initialChildSize: 0.72,
              minChildSize: 0.45,
              maxChildSize: 0.92,
              builder: (_, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: TColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select area for ${doctor.name}',
                              style: const TextStyle(
                                fontSize: TSizes.v18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: TTexts.uiTextClose,
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: TextField(
                        onChanged: (value) =>
                            setSheetState(() => query = value),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: TTexts.uiTextSearchCachedAreas,
                          filled: true,
                          fillColor: TColors.hex_FFF5F7FA,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: visible.isEmpty
                          ? const Center(
                              child: Text(TTexts.uiTextNoMatchingAreas))
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              itemCount: visible.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: TSizes.v1),
                              itemBuilder: (_, index) {
                                final area = visible[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: TColors.hex_FFEAF2FF,
                                    child: Icon(Icons.map_outlined,
                                        color: TColors.primary),
                                  ),
                                  title: Text(area.name),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.pop(context, area),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedAreaOverrides[doctor.key] = selected);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: TColors.primary,
                onPrimary: TColors.white,
                onSurface: TColors.pureBlack),
            dialogBackgroundColor: TColors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_selectedDoctors.isEmpty) {
      Get.snackbar("Required", TTexts.uiTextPleaseSelectAtLeastOneDoctor,
          backgroundColor: TColors.materialOrange.withOpacity(0.1),
          colorText: TColors.materialRedAccent);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_useSameDetails) {
      if (!_isValidScheduleDate(_dateController.text)) {
        Get.snackbar("Required", TTexts.uiTextPleaseSelectAValidScheduleDate,
            backgroundColor: TColors.materialOrange.withOpacity(0.1),
            colorText: TColors.materialRedAccent);
        return;
      }
      if (_notesController.text.trim().isEmpty) {
        Get.snackbar(
            "Required", TTexts.uiTextPleaseAddNotesForTheScheduledVisit,
            backgroundColor: TColors.materialOrange.withOpacity(0.1),
            colorText: TColors.materialRedAccent);
        return;
      }
    } else {
      for (final doctor in _selectedDoctors) {
        final draft = _doctorDrafts[doctor.key];
        if (draft == null || !_isValidScheduleDate(draft.date)) {
          Get.snackbar("Missing date", "Select a valid date for ${doctor.name}",
              backgroundColor: TColors.materialOrange.withOpacity(0.1),
              colorText: TColors.materialRedAccent);
          return;
        }
        if (draft.notesController.text.trim().isEmpty) {
          Get.snackbar("Missing notes", "Add notes for ${doctor.name}",
              backgroundColor: TColors.materialOrange.withOpacity(0.1),
              colorText: TColors.materialRedAccent);
          return;
        }
      }
    }

    final missingAreas =
        _selectedDoctors.where(_needsAreaSelection).toList(growable: false);
    if (missingAreas.isNotEmpty) {
      final names = missingAreas.map((doctor) => doctor.name).join(', ');
      Get.snackbar(
        'Area required',
        'Select an area before scheduling: $names',
        backgroundColor: TColors.materialOrange.withOpacity(0.1),
        colorText: TColors.materialDeepOrange,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = await _authManager.getUserId();
      if (userId == null || userId.isEmpty) {
        throw StateError('User is not authenticated.');
      }
      final areaQueueService = DoctorAreaAssignmentQueueService();
      for (final doctor in _selectedDoctors) {
        final selectedArea = _selectedAreaFor(doctor);
        if (doctor.areaId == null && selectedArea != null) {
          final saved = _savedAreaAssignments[doctor.key];
          if (saved?.areaId != selectedArea.id) {
            await areaQueueService.queueAssignment(
              doctorLocalId: doctor.localId,
              serverDoctorId: doctor.serverId,
              userId: userId,
              areaId: selectedArea.id,
              areaName: selectedArea.name,
            );
          }
        }
      }
      final scheduleService = DoctorScheduleService();
      for (var index = 0; index < _selectedDoctors.length; index++) {
        final doctor = _selectedDoctors[index];
        final draft = _useSameDetails
            ? _DoctorScheduleValues(
                date: _dateController.text,
                notes: _notesController.text.trim(),
                remark: _remarkController.text.trim(),
              )
            : _DoctorScheduleValues.fromDraft(_doctorDrafts[doctor.key]!);
        await scheduleService.queueSchedule(
          doctorLocalId: doctor.localId,
          serverDoctorId: doctor.serverId,
          userId: userId,
          date: draft.date,
          notes: draft.notes,
          remark: draft.remark,
          doctorName: doctor.name,
          areaId: _effectiveAreaId(doctor),
          areaName: _effectiveAreaName(doctor),
          doctorLatitude: doctor.latitude,
          doctorLongitude: doctor.longitude,
          // Trigger one synchronization after every selected doctor has
          // been written to the local outbox.
          syncTrigger:
              index == _selectedDoctors.length - 1 ? null : () async {},
        );
      }

      Get.snackbar(
        'Schedules saved',
        '${_selectedDoctors.length} doctor schedule${_selectedDoctors.length == 1 ? '' : 's'} queued for ordered synchronization.',
        backgroundColor: TColors.success.withOpacity(0.1),
        colorText: TColors.success,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to schedule visit: $e",
          backgroundColor: TColors.materialRed.withOpacity(0.1),
          colorText: TColors.materialRed);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.hex_FFF5F7FA,
      // Keep the hero below the app bar so its title can never be clipped by
      // the transparent toolbar overlay.
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: TColors.primary,
        elevation: TSizes.v0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: TColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: LayoutBuilder(builder: (context, constraints) {
          return MediaQuery.of(context).size.width < 600
              ? const Text(TTexts.uiTextNewAppointment,
                  style: TextStyle(
                      color: TColors.white, fontWeight: FontWeight.w600))
              : const SizedBox.shrink();
        }),
        centerTitle: true,
        iconTheme: const IconThemeData(color: TColors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildTabletLayout(constraints);
          } else {
            return _buildMobileLayout(constraints);
          }
        },
      ),
    );
  }

  // ==========================================
  // 📱 MOBILE LAYOUT (Improved)
  // ==========================================
  Widget _buildMobileLayout(BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;
    // Keep the mobile hero compact so the doctor and schedule controls are
    // visible without making the user scroll through empty space first.
    final headerHeight = size.height < 700 ? 230.0 : 245.0;

    return SizedBox(
      height: constraints.maxHeight,
      child: Stack(
        children: [
          // 1. Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: _buildGradientBanner(isMobile: true),
          ),

          // 2. Form Body (Moved down slightly to clear text)
          Positioned(
            top: headerHeight - 28,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Invisible Spacer for top overlap visual
                    const SizedBox(height: TSizes.v10),
                    _buildFormContent(),
                    // Extra bottom padding for the button + safe area
                    const SizedBox(height: TSizes.v120),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating Bottom Button
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 💻 TABLET / LANDSCAPE LAYOUT
  // ==========================================
  Widget _buildTabletLayout(BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          flex: 4, // 40% width
          child: _buildGradientBanner(isMobile: false),
        ),
        Expanded(
          flex: 6, // 60% width
          child: Container(
            color: TColors.hex_FFF5F7FA,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: TSizes.v40),
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints:
                            const BoxConstraints(maxWidth: TSizes.v500),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          physics: const BouncingScrollPhysics(),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  TTexts.uiTextAppointmentDetails,
                                  style: TextStyle(
                                      fontSize: TSizes.v28,
                                      fontWeight: FontWeight.bold,
                                      color: TColors.materialGrey800),
                                ),
                                const SizedBox(height: TSizes.v8),
                                Text(
                                  TTexts
                                      .uiTextFillInTheDetailsBelowToScheduleYour,
                                  style: TextStyle(
                                      fontSize: TSizes.v16,
                                      color: TColors.materialGrey600),
                                ),
                                const SizedBox(height: TSizes.v32),
                                _buildFormContent(),
                                const SizedBox(height: TSizes.v40),
                                _buildSubmitButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 🎨 REUSABLE WIDGETS
  // ==========================================

  Widget _buildGradientBanner({required bool isMobile}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TColors.primary, TColors.hex_FF4B68FF],
        ),
        borderRadius: isMobile
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32))
            : BorderRadius.zero,
      ),
      child: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _decorativeCircle(200)),
          Positioned(bottom: 50, left: -50, child: _decorativeCircle(150)),

          // Content with SafeArea to prevent clipping
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                isMobile ? 20 : 24,
                24,
                isMobile ? 12 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isMobile) ...[
                    const Icon(Icons.medical_services_outlined,
                        size: TSizes.v60, color: TColors.white24),
                    const SizedBox(height: TSizes.v32),
                  ],
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: TColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            color: TColors.materialAmber, size: TSizes.v16),
                        SizedBox(width: TSizes.v4),
                        Text(TTexts.uiTextHighPriority,
                            style: TextStyle(
                                color: TColors.white,
                                fontSize: TSizes.v12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.v16),
                  Text(
                    TTexts.scheduleVisit,
                    style: TextStyle(
                        color: TColors.white,
                        fontSize: isMobile ? 28 : 32,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: TSizes.v8),
                  Text(
                    TTexts.uiTextPlanYourNextSuccessfulInteraction,
                    style: TextStyle(
                        color: TColors.white.withOpacity(0.9),
                        fontSize: TSizes.v14),
                  ),
                  if (isMobile) const SizedBox(height: TSizes.v12),
                  if (!isMobile) const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        _AnimatedEntry(
          controller: _animController,
          index: 1,
          child: GestureDetector(
            onTap: _openDoctorSearchSheet,
            child: _buildInputCard(
              title: TTexts.uiTextSelectDoctors,
              icon: Icons.person_search_rounded,
              child: _selectedDoctors.isEmpty
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            TTexts.uiTextTapToSearchAndSelectOneOrMore,
                            style: TextStyle(
                              fontSize: TSizes.v16,
                              color: TColors.materialGrey500,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: TColors.primary),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedDoctors.length} doctor${_selectedDoctors.length == 1 ? '' : 's'} selected',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: TColors.primary,
                          ),
                        ),
                        const SizedBox(height: TSizes.v10),
                        ..._selectedDoctorOptions.map(_buildSelectedDoctorTile),
                        const SizedBox(height: TSizes.v4),
                        const Text(
                          TTexts.uiTextTapHereToAddOrRemoveDoctors,
                          style: TextStyle(
                              color: TColors.materialGrey,
                              fontSize: TSizes.v12),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: TSizes.v16),
        if (_selectedDoctors.isNotEmpty) ...[
          _AnimatedEntry(
            controller: _animController,
            index: 2,
            child: _buildAreaAssignmentSection(),
          ),
          const SizedBox(height: TSizes.v16),
        ],
        _AnimatedEntry(
          controller: _animController,
          index: 3,
          child: _buildScheduleDetailsSection(),
        ),
      ],
    );
  }

  Widget _buildAreaAssignmentSection() {
    final pending = _selectedDoctors.where(_needsAreaSelection).toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    return _buildInputCard(
      title: TTexts.uiTextAreaRequiredBeforeScheduling,
      icon: Icons.map_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TTexts.uiTextSelectAnAreaForEachDoctorWithoutAn,
            style:
                TextStyle(color: TColors.materialGrey700, height: TSizes.v1_35),
          ),
          const SizedBox(height: TSizes.v12),
          if (_offlineAreas.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColors.materialOrange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                TTexts.uiTextNoCachedAreasAreAvailableConnectOnceTo,
                style: TextStyle(color: TColors.materialDeepOrange),
              ),
            ),
          ...pending.map(
            (doctor) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      doctor.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _offlineAreas.isEmpty
                        ? null
                        : () => _openAreaPicker(doctor),
                    icon: const Icon(Icons.pin_drop_outlined, size: TSizes.v18),
                    label: const Text(TTexts.uiTextSelectArea_81d6a3dd),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputCard(
          title: TTexts.uiTextScheduleDetails,
          icon: Icons.tune_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                TTexts.uiTextChooseHowToSetTheVisitDetails,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: TSizes.v12),
              _buildDetailsModeToggle(),
              const SizedBox(height: TSizes.v10),
              Text(
                _useSameDetails
                    ? 'One date and note will be applied to every selected doctor.'
                    : 'Set a different date, note, or remark for each doctor.',
                style: TextStyle(
                    color: TColors.materialGrey600, fontSize: TSizes.v12),
              ),
            ],
          ),
        ),
        const SizedBox(height: TSizes.v12),
        if (_useSameDetails) ...[
          _buildSharedDateCard(),
          const SizedBox(height: TSizes.v12),
          _buildSharedNotesCard(),
        ] else
          _buildCustomDoctorScheduleCards(),
      ],
    );
  }

  Widget _buildDetailsModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TColors.hex_FFF1F4F9,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildModeOption(
            label: TTexts.uiTextSameForAll,
            icon: Icons.copy_all_rounded,
            selected: _useSameDetails,
            onTap: () => _setDetailsMode(true),
          ),
          _buildModeOption(
            label: TTexts.uiTextCustomizeEach,
            icon: Icons.edit_note_rounded,
            selected: !_useSameDetails,
            onTap: () => _setDetailsMode(false),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? TColors.white : TColors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: TColors.pureBlack.withOpacity(0.06),
                      blurRadius: TSizes.v6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: TSizes.v17,
                  color: selected ? TColors.primary : TColors.materialGrey600),
              const SizedBox(width: TSizes.v6),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? TColors.primary : TColors.materialGrey700,
                    fontSize: TSizes.v12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSharedDateCard() {
    return GestureDetector(
      onTap: _pickDate,
      child: _buildInputCard(
        title: TTexts.uiTextDateForAllSelectedDoctors,
        icon: Icons.calendar_month_rounded,
        child: Row(
          children: [
            Text(
              _dateController.text.isEmpty
                  ? 'Select date'
                  : _dateController.text,
              style: TextStyle(
                fontSize: TSizes.v16,
                fontWeight: FontWeight.bold,
                color: TColors.materialGrey800,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_calendar_rounded,
                  color: TColors.primary, size: TSizes.v20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedNotesCard() {
    return _buildInputCard(
      title: TTexts.uiTextNotesAndRemarkForAllDoctors,
      icon: Icons.notes_rounded,
      child: Column(
        children: [
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(fontSize: TSizes.v15),
            decoration: InputDecoration(
              hintText: TTexts.uiTextPurposeOfTheVisitsRequired,
              hintStyle: TextStyle(
                  color: TColors.materialGrey400, fontSize: TSizes.v14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) =>
                value!.trim().isEmpty ? 'Notes are required' : null,
          ),
          const Divider(height: TSizes.v20),
          TextFormField(
            controller: _remarkController,
            maxLines: 2,
            style: const TextStyle(fontSize: TSizes.v15),
            decoration: InputDecoration(
              hintText: TTexts.uiTextRemarkOptional,
              hintStyle: TextStyle(
                  color: TColors.materialGrey400, fontSize: TSizes.v14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDoctorScheduleCards() {
    return Column(
      children: _selectedDoctors
          .map(_buildCustomDoctorScheduleCard)
          .toList(growable: false),
    );
  }

  Widget _buildCustomDoctorScheduleCard(_ScheduleDoctor doctor) {
    final draft = _doctorDrafts[doctor.key];
    if (draft == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildInputCard(
        title: doctor.name,
        icon: Icons.person_pin_circle_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctor.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: TColors.materialGrey600, fontSize: TSizes.v12),
            ),
            const SizedBox(height: TSizes.v14),
            GestureDetector(
              onTap: () => _pickDateForDoctor(doctor),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: TColors.hex_FFF7F9FC,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: TColors.materialGrey.withOpacity(0.18)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_outlined,
                        color: TColors.primary, size: TSizes.v20),
                    const SizedBox(width: TSizes.v10),
                    Expanded(
                      child: Text(
                        draft.date,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.edit_calendar_outlined,
                        color: TColors.primary, size: TSizes.v19),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TSizes.v12),
            TextFormField(
              controller: draft.notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: TSizes.v14),
              decoration: const InputDecoration(
                labelText: TTexts.notes,
                hintText: TTexts.uiTextPurposeOfThisVisit,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) => value!.trim().isEmpty
                  ? 'Notes are required for this doctor'
                  : null,
            ),
            const SizedBox(height: TSizes.v12),
            TextFormField(
              controller: draft.remarkController,
              maxLines: 2,
              style: const TextStyle(fontSize: TSizes.v14),
              decoration: const InputDecoration(
                labelText: TTexts.uiTextRemarkOptional,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDoctorTile(_ScheduleDoctor doctor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: TSizes.v18,
            backgroundColor: TColors.primary.withOpacity(0.1),
            child: Text(
              doctor.initial,
              style: const TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: TSizes.v10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: TSizes.v2),
                Text(
                  doctor.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: TColors.materialGrey700, fontSize: TSizes.v12),
                ),
                const SizedBox(height: TSizes.v3),
                Text(
                  'Area: ${_effectiveAreaName(doctor) ?? 'Required'}',
                  style: TextStyle(
                    color: _effectiveAreaId(doctor) == null
                        ? TColors.materialDeepOrange
                        : TColors.materialGrey700,
                    fontSize: TSizes.v12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: TTexts.uiTextRemoveDoctor,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded),
            color: TColors.materialGrey600,
            onPressed: () => _removeSelectedDoctor(doctor),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return _AnimatedEntry(
      controller: _animController,
      index: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: TColors.primary.withOpacity(0.4),
                blurRadius: TSizes.v20,
                offset: const Offset(0, 10)),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            foregroundColor: TColors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: TSizes.v0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: TSizes.v24,
                  width: TSizes.v24,
                  child: CircularProgressIndicator(
                      color: TColors.white, strokeWidth: TSizes.v2))
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(TTexts.uiTextConfirmSchedule,
                        style: TextStyle(
                            fontSize: TSizes.v16, fontWeight: FontWeight.bold)),
                    SizedBox(width: TSizes.v8),
                    Icon(Icons.check_circle_outline_rounded, size: TSizes.v20)
                  ],
                ),
        ),
      ),
    );
  }

  Widget _decorativeCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: TColors.white.withOpacity(0.08)),
    );
  }

  Widget _buildInputCard(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: TColors.materialGrey.withOpacity(0.06),
              blurRadius: TSizes.v15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: TSizes.v18, color: TColors.primary),
              const SizedBox(width: TSizes.v8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                    fontSize: TSizes.v12,
                    fontWeight: FontWeight.bold,
                    color: TColors.materialGrey,
                    letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: TSizes.v12),
          child,
        ],
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _AnimatedEntry(
      {required this.controller, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(
            parent: controller,
            curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic)),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
              parent: controller,
              curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut)),
        ),
        child: child,
      ),
    );
  }
}

class _DoctorScheduleDraft {
  _DoctorScheduleDraft({
    required this.date,
    required String notes,
    required String remark,
  })  : notesController = TextEditingController(text: notes),
        remarkController = TextEditingController(text: remark);

  String date;
  final TextEditingController notesController;
  final TextEditingController remarkController;

  void dispose() {
    notesController.dispose();
    remarkController.dispose();
  }
}

class _DoctorScheduleValues {
  const _DoctorScheduleValues({
    required this.date,
    required this.notes,
    required this.remark,
  });

  final String date;
  final String notes;
  final String remark;

  factory _DoctorScheduleValues.fromDraft(_DoctorScheduleDraft draft) {
    return _DoctorScheduleValues(
      date: draft.date,
      notes: draft.notesController.text.trim(),
      remark: draft.remarkController.text.trim(),
    );
  }
}

class _ScheduleArea {
  const _ScheduleArea({required this.id, required this.name});

  final String id;
  final String name;
}

class _ScheduleDoctor {
  const _ScheduleDoctor({
    required this.key,
    required this.localId,
    required this.serverId,
    required this.name,
    required this.specialization,
    required this.clinic,
    required this.address,
    required this.qualification,
    required this.phone,
    required this.email,
    required this.area,
    required this.areaId,
    required this.areaName,
    required this.priority,
    required this.timings,
    required this.latitude,
    required this.longitude,
  });

  final String key;
  final String localId;
  final String? serverId;
  final String name;
  final String? specialization;
  final String? clinic;
  final String? address;
  final String? qualification;
  final String? phone;
  final String? email;
  final String? area;
  final String? areaId;
  final String? areaName;
  final String? priority;
  final String? timings;
  final double? latitude;
  final double? longitude;

  String get initial {
    final value = name.trim();
    return value.isEmpty ? '?' : value.substring(0, 1).toUpperCase();
  }

  String get summary {
    final values = <String>[];
    for (final value in [specialization, clinic, address]) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty) values.add(text);
    }
    return values.isEmpty ? 'Doctor details not available' : values.join(' • ');
  }

  factory _ScheduleDoctor.fromOffline(offline_doctor.Doctor doctor) {
    return _ScheduleDoctor(
      key: doctor.localId,
      localId: doctor.localId,
      serverId: _text(doctor.serverId),
      name: doctor.displayName,
      specialization: _text(doctor.specialization),
      clinic: _text(doctor.clinicName),
      address: _firstText([doctor.clinicAddress, doctor.location]),
      qualification: _text(doctor.qualification),
      phone: _text(doctor.phone),
      email: _text(doctor.email),
      area: _firstText([doctor.areaName, doctor.headOfficeName]),
      areaId: _text(doctor.areaId),
      areaName: _text(doctor.areaName),
      priority: _text(doctor.priority),
      timings: _text(doctor.availableTimings),
      latitude: doctor.latitude?.toDouble(),
      longitude: doctor.longitude?.toDouble(),
    );
  }

  factory _ScheduleDoctor.fromOnline(online_doctor.Doctor doctor) {
    return _ScheduleDoctor(
      key: doctor.id,
      localId: doctor.id,
      serverId: _text(doctor.id),
      name: doctor.name.trim().isEmpty ? 'Unnamed doctor' : doctor.name,
      specialization: _text(doctor.specialization),
      clinic: _text(doctor.clinicName),
      address: _firstText([doctor.clinicAddress, doctor.location]),
      qualification: _text(doctor.qualification),
      phone: _text(doctor.phone),
      email: _text(doctor.email),
      area: _firstText([doctor.area?.name, doctor.headOffice?.name]),
      areaId: _text(doctor.area?.id),
      areaName: _text(doctor.area?.name),
      priority: _text(doctor.priority),
      timings: _text(doctor.availableTimings),
      latitude: double.tryParse(doctor.latitude ?? ''),
      longitude: double.tryParse(doctor.longitude ?? ''),
    );
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String? _firstText(Iterable<Object?> values) {
    for (final value in values) {
      final text = _text(value);
      if (text != null) return text;
    }
    return null;
  }
}
