import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/doctor.dart';
import '../models/doctor_sync_models.dart';
import '../repositories/doctor_repository.dart';
import '../repositories/doctor_search_index.dart';
import '../services/doctor_connectivity_monitor.dart';
import '../sync/doctor_sync_coordinator.dart';

class DoctorFilterOption {
  const DoctorFilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

class DoctorOfflineController extends GetxController
    with WidgetsBindingObserver {
  DoctorOfflineController({
    required DoctorRepository repository,
    required DoctorSyncCoordinator syncCoordinator,
    DoctorConnectivityMonitor? connectivityMonitor,
    Duration connectivityDebounce = const Duration(milliseconds: 900),
  })  : _repository = repository,
        _syncCoordinator = syncCoordinator,
        _connectivityMonitor =
            connectivityMonitor ?? ConnectivityPlusDoctorConnectivityMonitor(),
        _connectivityDebounce = connectivityDebounce,
        _searchIndex = DoctorSearchIndex(const <Doctor>[]);

  final DoctorRepository _repository;
  final DoctorSyncCoordinator _syncCoordinator;
  final DoctorConnectivityMonitor _connectivityMonitor;
  final Duration _connectivityDebounce;
  final DoctorSearchIndex _searchIndex;

  StreamSubscription<List<Doctor>>? _doctorSubscription;
  StreamSubscription<DoctorSyncStatus>? _statusSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _connectivityTimer;
  bool _initialized = false;
  bool _shutDown = false;

  List<Doctor> _allDoctors = const [];
  List<Doctor> _visibleDoctors = const [];
  DoctorQuery _query = const DoctorQuery();
  String? _selectedLocalId;
  String? _selectionNotice;
  DoctorSyncStatus _syncStatus = const DoctorSyncStatus.idle();
  bool _networkAvailable = true;

  List<Doctor> get allDoctors => _allDoctors;
  List<Doctor> get visibleDoctors => _visibleDoctors;
  DoctorQuery get query => _query;
  DoctorSyncStatus get syncStatus => _syncStatus;
  bool get networkAvailable => _networkAvailable;
  bool get isInitialized => _initialized;
  String? get selectionNotice => _selectionNotice;

  Doctor? get selectedDoctor {
    final localId = _selectedLocalId;
    return localId == null ? null : _searchIndex.find(localId);
  }

  List<DoctorFilterOption> get priorityOptions {
    return _exactOptions(
      _allDoctors.map((doctor) => doctor.priority).whereType<String>(),
    );
  }

  List<DoctorFilterOption> get headOfficeOptions {
    return _namedOptions(
      _allDoctors.map(
        (doctor) => MapEntry(doctor.headOfficeId, doctor.headOfficeName),
      ),
      missingLabel: 'Head office name unavailable',
    );
  }

  List<DoctorFilterOption> get areaOptions {
    return _namedOptions(
      _allDoctors.map((doctor) => MapEntry(doctor.areaId, doctor.areaName)),
      missingLabel: 'Area name unavailable',
    );
  }

  Future<void> initialize() async {
    if (_initialized || _shutDown) return;
    WidgetsBinding.instance.addObserver(this);
    _syncStatus = _syncCoordinator.status;
    _applyDoctors(await _repository.readDoctors());

    _doctorSubscription = _repository.watchDoctors().listen(
      _applyDoctors,
      onError: (_) {
        _syncStatus = DoctorSyncStatus(
          phase: DoctorSyncPhase.storageUnavailable,
          message: 'The encrypted doctor cache could not be read.',
          downloadedCount: _allDoctors.length,
          hasCachedData: _allDoctors.isNotEmpty,
          lastSuccessfulSyncUtc: _syncStatus.lastSuccessfulSyncUtc,
        );
        _notifyUi();
      },
    );
    _statusSubscription = _syncCoordinator.statusChanges.listen((status) {
      _syncStatus = status;
      _notifyUi();
    });
    _connectivitySubscription = _connectivityMonitor.availabilityChanges.listen(
      _handleConnectivity,
    );
    try {
      _handleConnectivity(await _connectivityMonitor.isNetworkAvailable());
    } catch (_) {}
    _initialized = true;
    _notifyUi();
    unawaited(_syncCoordinator.synchronize());
  }

  void setSearch(String value) {
    _query = _query.copyWith(search: value);
    _applyQuery();
  }

  void setPriority(String? value) {
    _query = _query.copyWith(priority: value);
    _applyQuery();
  }

  void setHeadOffice(String? value) {
    _query = _query.copyWith(headOfficeId: value, areaId: null);
    _applyQuery();
  }

  void setArea(String? value) {
    _query = _query.copyWith(areaId: value);
    _applyQuery();
  }

  void clearFilters() {
    _query = DoctorQuery(search: _query.search);
    _applyQuery();
  }

  void selectDoctor(String? localId) {
    if (localId != null && _searchIndex.find(localId) == null) return;
    _selectedLocalId = localId;
    _selectionNotice = null;
    _notifyUi();
  }

  void clearSelectionNotice() {
    if (_selectionNotice == null) return;
    _selectionNotice = null;
    _notifyUi();
  }

  Future<void> refreshDoctors() => _syncCoordinator.synchronize();

  Future<void> rebuildOfflineCache() {
    return _syncCoordinator.synchronize(rebuildBootstrap: true);
  }

  void _applyDoctors(List<Doctor> doctors) {
    if (_shutDown) return;
    final previousSelectedId = _selectedLocalId;
    _allDoctors = List<Doctor>.unmodifiable(doctors);
    _searchIndex.rebuild(_allDoctors);
    if (previousSelectedId != null &&
        _searchIndex.find(previousSelectedId) == null) {
      _selectedLocalId = null;
      _selectionNotice = 'The selected doctor is no longer available.';
    }
    _applyQuery();
  }

  void _applyQuery() {
    _visibleDoctors = _searchIndex.query(_query);
    _notifyUi();
  }

  void _handleConnectivity(bool isAvailable) {
    if (_shutDown) return;
    final wasAvailable = _networkAvailable;
    _networkAvailable = isAvailable;
    _notifyUi();
    if (_networkAvailable && !wasAvailable) {
      _connectivityTimer?.cancel();
      _connectivityTimer = Timer(_connectivityDebounce, () {
        if (!_shutDown && _networkAvailable) {
          unawaited(_syncCoordinator.synchronize());
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_shutDown) {
      unawaited(_syncCoordinator.synchronize());
    }
  }

  List<DoctorFilterOption> _exactOptions(Iterable<String> values) {
    final normalized = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort((first, second) => first.toLowerCase().compareTo(
            second.toLowerCase(),
          ));
    return List<DoctorFilterOption>.unmodifiable(
      normalized.map(
        (value) => DoctorFilterOption(value: value, label: value),
      ),
    );
  }

  List<DoctorFilterOption> _namedOptions(
    Iterable<MapEntry<String?, String?>> entries, {
    required String missingLabel,
  }) {
    final labels = <String, String>{};
    for (final entry in entries) {
      final id = entry.key?.trim();
      if (id == null || id.isEmpty) continue;
      final name = entry.value?.trim();
      labels[id] = name == null || name.isEmpty ? missingLabel : name;
    }
    final options = labels.entries
        .map(
          (entry) => DoctorFilterOption(
            value: entry.key,
            label: entry.value,
          ),
        )
        .toList()
      ..sort((first, second) => first.label.toLowerCase().compareTo(
            second.label.toLowerCase(),
          ));
    return List<DoctorFilterOption>.unmodifiable(options);
  }

  void _notifyUi() {
    if (!_shutDown) update();
  }

  Future<void> shutdown() async {
    if (_shutDown) return;
    _shutDown = true;
    WidgetsBinding.instance.removeObserver(this);
    _connectivityTimer?.cancel();
    await _doctorSubscription?.cancel();
    await _statusSubscription?.cancel();
    await _connectivitySubscription?.cancel();
  }

  @override
  void onClose() {
    unawaited(shutdown());
    super.onClose();
  }
}
