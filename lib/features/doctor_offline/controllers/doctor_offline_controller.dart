import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../services/doctor_creation_store.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/camera/CameraLocationResult.dart';
import '../../../utils/camera/image_overlay_utils.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';

import '../models/doctor.dart';
import '../models/pending_doctor_location_request.dart';
import '../models/doctor_sync_models.dart';
import '../repositories/doctor_repository.dart';
import '../repositories/pending_doctor_location_repository.dart';
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
    this.creationStore,
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

  final DoctorCreationStore? creationStore;
  List<Doctor> _downloadedDoctors = const [];
  List<Doctor> _createdDoctors = const [];
  Set<String> pendingImageIds = {};
  String? _capturingImageLocalId;
  Set<String> _creationIds = {};
  Timer? _creationTimer;
  StreamSubscription<void>? _creationSubscription;
  int _creationRead = 0;
  String? get uploadMessage => creationStore?.message;
  bool get isUploading => creationStore?.uploading ?? false;
  bool get isCapturingImage => _capturingImageLocalId != null;

  bool isCapturingImageFor(Doctor doctor) =>
      _capturingImageLocalId == doctor.localId;
  final DoctorRepository _repository;
  final DoctorSyncCoordinator _syncCoordinator;
  final DoctorConnectivityMonitor _connectivityMonitor;
  final Duration _connectivityDebounce;
  final DoctorSearchIndex _searchIndex;
  final PendingDoctorLocationRepository _locationRequestRepository =
      PendingDoctorLocationRepository();

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
    await reloadCreations();
    _applyDoctors(await _repository.readDoctors());
    _creationSubscription = creationStore?.changes.listen((_) {
      _creationTimer?.cancel();
      _creationTimer = Timer(
          const Duration(milliseconds: 80), () => unawaited(reloadCreations()));
    });

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
    unawaited(refreshDoctors());
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

  Future<void> refreshDoctors() async {
    await _syncCoordinator.synchronize();
    final store = creationStore;
    if (store == null || _shutDown) return;
    try {
      await store.reconcileDownloaded(await _repository.readDoctors());
      await store.synchronize();
      await reloadCreations();
      await _syncPendingLocationRequests();
    } catch (_) {
      if (!_shutDown) {
        _selectionNotice =
            'Saved doctors could not be synchronized. Refresh to retry.';
        _notifyUi();
      }
    }
  }

  Future<void> addGeoImage(Doctor doctor) async {
    final store = creationStore;
    if (store == null ||
        _capturingImageLocalId != null ||
        doctor.geoImageUrl?.trim().isNotEmpty == true) {
      return;
    }
    _capturingImageLocalId = doctor.localId;
    _notifyUi();
    try {
      final result = await CameraLocationService.captureImageWithLocation();
      if (result == null) return;
      final image = await ImageOverlayUtil.addOverlay(
        original: result.image,
        lat: result.latitude,
        lng: result.longitude,
      );
      await store.queueImage(doctor: doctor, image: image);
      await reloadCreations();
      await store.synchronize();
      // The upload response is persisted in the local outbox first. Pull the
      // server delta afterward so the encrypted doctor cache receives the
      // canonical geoImageUrl and syncVersion before the list is rebuilt.
      await refreshDoctors();
    } catch (_) {
      _selectionNotice = 'The geo image could not be saved. Please try again.';
      _notifyUi();
    } finally {
      _capturingImageLocalId = null;
      _notifyUi();
    }
  }

  Future<void> requestDoctorLocation(Doctor doctor,
      {required double latitude, required double longitude}) async {
    final doctorId = doctor.serverId ?? doctor.localId;
    final accountId = await AuthManager().getUserId() ?? '';
    try {
      if (!await _connectivityMonitor.isNetworkAvailable()) {
        await _queueLocationRequest(
          doctor: doctor,
          accountId: accountId,
          latitude: latitude,
          longitude: longitude,
        );
        return;
      }

      final approvalRequired = await _sendLocationRequest(
        doctorId: doctorId,
        latitude: latitude,
        longitude: longitude,
      );
      _showLocationRequestResult(approvalRequired: approvalRequired);
    } on TimeoutException {
      await _queueLocationRequest(
        doctor: doctor,
        accountId: accountId,
        latitude: latitude,
        longitude: longitude,
      );
    } on SocketException {
      await _queueLocationRequest(
        doctor: doctor,
        accountId: accountId,
        latitude: latitude,
        longitude: longitude,
      );
    } on http.ClientException {
      await _queueLocationRequest(
        doctor: doctor,
        accountId: accountId,
        latitude: latitude,
        longitude: longitude,
      );
    } on _RetryableDoctorLocationRequest {
      await _queueLocationRequest(
        doctor: doctor,
        accountId: accountId,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (error) {
      Get.snackbar(
        'Location Request Failed',
        error.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _queueLocationRequest({
    required Doctor doctor,
    required String accountId,
    required double latitude,
    required double longitude,
  }) async {
    final requestKey = '$accountId:${doctor.localId}';
    await _locationRequestRepository.upsert(
      PendingDoctorLocationRequest(
        requestKey: requestKey,
        accountId: accountId,
        localDoctorId: doctor.localId,
        requestedDoctorId: doctor.serverId ?? doctor.localId,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    _selectionNotice =
        'Location request saved offline. It will be sent when internet is available.';
    _notifyUi();
    Get.snackbar(
      'Saved Offline',
      'The location request will be sent when internet is available.',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  Future<void> _syncPendingLocationRequests() async {
    final accountId = await AuthManager().getUserId();
    if (accountId == null || accountId.isEmpty) return;
    if (!await _connectivityMonitor.isNetworkAvailable()) return;

    final requests = await _locationRequestRepository.getForAccount(accountId);
    for (final request in requests) {
      final doctor = _searchIndex.find(request.localDoctorId);
      // A locally-created doctor must be created first so the location request
      // can use its server ID instead of the local UUID.
      final doctorId = doctor?.serverId ?? request.requestedDoctorId;
      if (doctor?.localSyncState == DoctorLocalSyncState.pendingCreate &&
          doctor?.serverId == null) {
        continue;
      }
      try {
        await _sendLocationRequest(
          doctorId: doctorId,
          latitude: request.latitude,
          longitude: request.longitude,
        );
        await _locationRequestRepository.delete(request.requestKey);
        _selectionNotice = 'Location request sent for admin approval.';
        _notifyUi();
      } on TimeoutException {
        break;
      } on SocketException {
        break;
      } on http.ClientException {
        break;
      } on _RetryableDoctorLocationRequest {
        break;
      } catch (_) {
        // Keep rejected requests visible for a later retry or manual review.
      }
    }
  }

  Future<bool> _sendLocationRequest({
    required String doctorId,
    required double latitude,
    required double longitude,
  }) async {
    final token = await AuthManager().getAuthToken();
    if (token == null || token.isEmpty) {
      throw StateError('Authentication failed. Please login again.');
    }
    final response = await http
        .put(
          Uri.parse('${THttpHelper.baseUrl}/doctors/$doctorId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
        )
        .timeout(const Duration(seconds: 30));
    Map<String, dynamic> body = const {};
    try {
      body = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {}
    if (response.statusCode == 408 || response.statusCode >= 500) {
      throw const _RetryableDoctorLocationRequest();
    }
    if (response.statusCode != 200 || body['success'] != true) {
      throw StateError(body['message']?.toString() ??
          'The location request could not be submitted.');
    }
    return body['approvalRequired'] == true;
  }

  void _showLocationRequestResult({required bool approvalRequired}) {
    Get.snackbar(
      approvalRequired ? 'Location Request Submitted' : 'Location Updated',
      approvalRequired
          ? 'Doctor location is pending admin approval.'
          : 'Doctor location updated successfully.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    _selectionNotice = approvalRequired
        ? 'Location update request is pending admin approval.'
        : 'Doctor location updated successfully.';
    _notifyUi();
  }

  Future<void> reloadCreations() async {
    final store = creationStore;
    if (store == null || _shutDown) return;
    final generation = ++_creationRead;
    try {
      final records = await store.readDoctors();
      final images = await store.pendingImages();
      final ids = await store.localIds();
      if (_shutDown || generation != _creationRead) return;
      _createdDoctors = records;
      pendingImageIds = images;
      _creationIds = ids;
      _mergeDoctors();
    } catch (_) {
      if (!_shutDown) {
        _selectionNotice =
            'Saved doctor data could not be read. Reopen Offline Doctors.';
        _notifyUi();
      }
    }
  }

  Future<void> rebuildOfflineCache() {
    return _syncCoordinator.synchronize(rebuildBootstrap: true);
  }

  void _applyDoctors(List<Doctor> doctors) {
    _downloadedDoctors = doctors;
    _mergeDoctors();
  }

  void _mergeDoctors() {
    if (_shutDown) return;
    final byClient = <String, Doctor>{};
    final byServer = <String, Doctor>{};
    for (final local in _createdDoctors) {
      if (local.clientGeneratedId != null) {
        byClient[local.clientGeneratedId!] = local;
      }
      if (local.serverId != null) byServer[local.serverId!] = local;
    }
    final merged = <String, Doctor>{
      for (final d in _createdDoctors) d.localId: d
    };
    for (final remote in _downloadedDoctors) {
      final local =
          byClient[remote.clientGeneratedId] ?? byServer[remote.serverId];
      if (local == null) {
        final id = _creationIds.contains(remote.clientGeneratedId)
            ? remote.clientGeneratedId!
            : remote.localId;
        merged[id] = remote.copyWith(localId: id);
      } else if (remote.syncVersion != null &&
          (local.syncVersion == null ||
              remote.syncVersion! >= local.syncVersion!)) {
        // Keep the local navigation identity when the download catches up.
        final remoteHasImage = remote.geoImageUrl?.trim().isNotEmpty == true;
        final localHasImage = local.geoImageUrl?.trim().isNotEmpty == true;
        // Keep a locally confirmed upload visible if the delta page still
        // contains an older server version without the image. The next delta
        // replaces it once the server returns the canonical URL.
        merged[local.localId] = remote.copyWith(
          localId: local.localId,
          geoImageUrl: !remoteHasImage && localHasImage
              ? local.geoImageUrl
              : remote.geoImageUrl,
        );
      }
    }
    final doctors = merged.values.toList();
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
          unawaited(refreshDoctors());
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_shutDown) {
      unawaited(refreshDoctors());
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
    _creationTimer?.cancel();
    await _creationSubscription?.cancel();
    await creationStore?.close();
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

// A timeout/5xx response is safe to retry from the local outbox. Validation
// and authorization errors remain visible instead of being retried forever.
class _RetryableDoctorLocationRequest implements Exception {
  const _RetryableDoctorLocationRequest();
}
