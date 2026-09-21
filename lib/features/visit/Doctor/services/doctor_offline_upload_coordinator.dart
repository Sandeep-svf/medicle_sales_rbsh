import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/features/doctor_offline/doctor_offline.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../models/pending_schedule_model.dart';
import '../repository/pending_area_assignment_repository.dart';
import '../repository/pending_schedule_repository.dart';
import '../repository/pending_visit_repository.dart';
import 'doctor_area_assignment_sync_service.dart';
import 'pending_visit_sync_service.dart';

class DoctorOfflineUploadCoordinator {
  DoctorOfflineUploadCoordinator({
    PendingAreaAssignmentRepository? areaAssignmentRepository,
    PendingScheduleRepository? scheduleRepository,
    PendingVisitRepository? visitRepository,
    PendingVisitSyncService? visitSyncService,
    DoctorAreaAssignmentSyncService? areaAssignmentSyncService,
    AuthManager? authManager,
    http.Client? client,
    String? baseUrl,
  })  : _scheduleRepository = scheduleRepository ?? PendingScheduleRepository(),
        _visitRepository = visitRepository ?? PendingVisitRepository(),
        _authManager = authManager ?? AuthManager(),
        _client = client ?? http.Client(),
        _ownsClient = client == null,
        _visitSyncService = visitSyncService ??
            PendingVisitSyncService(
              repository: visitRepository,
              authManager: authManager,
              baseUrl: baseUrl,
            ),
        _ownsVisitSyncService = visitSyncService == null,
        _baseUrl = baseUrl ?? THttpHelper.baseUrl,
        _areaAssignmentSyncService = areaAssignmentSyncService ??
            DoctorAreaAssignmentSyncService(
              repository:
                  areaAssignmentRepository ?? PendingAreaAssignmentRepository(),
              authManager: authManager,
              client: client,
              baseUrl: baseUrl,
            ),
        _ownsAreaAssignmentSyncService = areaAssignmentSyncService == null;

  static Future<void>? _activeSync;

  final PendingScheduleRepository _scheduleRepository;
  final PendingVisitRepository _visitRepository;
  final AuthManager _authManager;
  final http.Client _client;
  final bool _ownsClient;
  final PendingVisitSyncService _visitSyncService;
  final bool _ownsVisitSyncService;
  final String _baseUrl;
  final DoctorAreaAssignmentSyncService _areaAssignmentSyncService;
  final bool _ownsAreaAssignmentSyncService;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void startListening() {
    _connectivitySubscription?.cancel();
    unawaited(_syncWhenConnected());
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (results) {
        if (!results.contains(ConnectivityResult.none)) {
          unawaited(syncAll());
        }
      },
    );
  }

  Future<void> _syncWhenConnected() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (!results.contains(ConnectivityResult.none)) await syncAll();
    } catch (error) {
      debugPrint(
          'DoctorOfflineUploadCoordinator: connectivity check failed: $error');
    }
  }

  Future<void> syncAll() {
    final active = _activeSync;
    if (active != null) return active;
    final operation = _performSync();
    _activeSync = operation;
    return operation.whenComplete(() {
      if (identical(_activeSync, operation)) _activeSync = null;
    });
  }

  Future<void> _performSync() async {
    final accountId = await _authManager.getUserId();
    if (accountId == null || accountId.trim().isEmpty) {
      debugPrint(
          'DoctorOfflineUploadCoordinator: SYNC STOPPED - no authenticated user ID.');
      return;
    }

    debugPrint('DoctorOfflineUploadCoordinator: SYNC START account=$accountId');

    DoctorOfflineModule? module;
    try {
      module = await DoctorOfflineModule.acquire(accountId: accountId);
      // This call uploads pending doctor creations and refreshes the cache.
      // It preserves the existing doctor module behavior and exposes the
      // merged local/server identity map needed by schedule uploads.
      await module.controller.refreshDoctors();
      final assignedAreas =
          await _areaAssignmentSyncService.syncPendingAssignments(
        userId: accountId,
        doctors: module.controller.doctorsForSync,
      );
      await _syncSchedules(
        accountId,
        module.controller.doctorsForSync,
        assignedAreas,
      );
      debugPrint(
          'DoctorOfflineUploadCoordinator: DOCTOR/SCHEDULE STAGE FINISHED');
    } catch (error, stackTrace) {
      debugPrint(
          'DoctorOfflineUploadCoordinator: doctor/schedule stage failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (module != null) await module.dispose();
    }

    // PendingVisitSyncService skips confirmations that still reference a
    // local schedule UUID, so already-resolved confirmations can continue
    // even if another schedule remains blocked.
    debugPrint(
        'DoctorOfflineUploadCoordinator: VISIT CONFIRMATION STAGE STARTED');
    await _visitSyncService.syncPendingVisits();
    debugPrint(
        'DoctorOfflineUploadCoordinator: SYNC FINISHED account=$accountId');
  }

  Future<void> _syncSchedules(
    String userId,
    List<Doctor> doctors,
    Map<String, String> assignedAreas,
  ) async {
    final pending = await _scheduleRepository.getPendingForUser(userId);
    debugPrint(
        'DoctorOfflineUploadCoordinator: Pending schedules found=${pending.length}');
    if (pending.isEmpty) return;

    final byLocalId = <String, Doctor>{};
    final byClientId = <String, Doctor>{};
    final byServerId = <String, Doctor>{};
    for (final doctor in doctors) {
      byLocalId[doctor.localId] = doctor;
      if (doctor.clientGeneratedId != null) {
        byClientId[doctor.clientGeneratedId!] = doctor;
      }
      if (doctor.serverId != null) byServerId[doctor.serverId!] = doctor;
    }

    final ready = <_ReadySchedule>[];
    for (final schedule in pending) {
      final doctor = byLocalId[schedule.doctorLocalId] ??
          byClientId[schedule.doctorLocalId] ??
          (schedule.serverDoctorId == null
              ? null
              : byServerId[schedule.serverDoctorId!]);
      final serverDoctorId = schedule.serverDoctorId ?? doctor?.serverId;
      if (serverDoctorId == null || serverDoctorId.trim().isEmpty) {
        debugPrint(
            'DoctorOfflineUploadCoordinator: HOLD schedule=${schedule.localId}; no server doctor ID.');
        await _scheduleRepository.markError(
          localId: schedule.localId,
          message: 'Waiting for doctor synchronization.',
        );
        continue;
      }
      final areaId = _firstNonEmpty([
        doctor?.areaId,
        assignedAreas[schedule.doctorLocalId],
        if (schedule.serverDoctorId != null)
          assignedAreas[schedule.serverDoctorId!],
        assignedAreas[serverDoctorId],
      ]);
      if (areaId == null || areaId.trim().isEmpty) {
        debugPrint(
            'DoctorOfflineUploadCoordinator: HOLD schedule=${schedule.localId}; no area ID.');
        await _scheduleRepository.markError(
          localId: schedule.localId,
          message: 'Waiting for doctor area assignment.',
        );
        continue;
      }
      if (schedule.serverDoctorId != serverDoctorId) {
        await _scheduleRepository.setServerDoctorId(
          localId: schedule.localId,
          serverDoctorId: serverDoctorId,
        );
      }
      ready.add(_ReadySchedule(schedule, serverDoctorId));
      debugPrint(
          'DoctorOfflineUploadCoordinator: READY schedule=${schedule.localId} doctor=$serverDoctorId');
    }

    const chunkSize = 50;
    for (var offset = 0; offset < ready.length; offset += chunkSize) {
      final end = (offset + chunkSize > ready.length)
          ? ready.length
          : offset + chunkSize;
      await _uploadScheduleChunk(ready.sublist(offset, end));
    }
  }

  Future<void> _uploadScheduleChunk(List<_ReadySchedule> schedules) async {
    final token = await _authManager.getAuthToken();
    if (token == null || token.trim().isEmpty) {
      for (final item in schedules) {
        await _scheduleRepository.markError(
          localId: item.schedule.localId,
          message: 'Authentication required before schedule upload.',
        );
      }
      return;
    }

    final request = {
      'user_id': schedules.first.schedule.userId,
      'visits': schedules.map((item) {
        final schedule = item.schedule;
        return <String, dynamic>{
          'doctor_id': item.serverDoctorId,
          'date': schedule.date,
          'notes': schedule.notes,
          if (schedule.remark.trim().isNotEmpty) 'remark': schedule.remark,
        };
      }).toList(),
    };

    debugPrint(
        'DoctorOfflineUploadCoordinator: BULK SCHEDULE URL=$_baseUrl/doctor-visits/bulk-schedule');
    debugPrint(
        'DoctorOfflineUploadCoordinator: BULK SCHEDULE REQUEST JSON=\n${const JsonEncoder.withIndent('  ').convert(request)}');

    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/doctor-visits/bulk-schedule'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(request),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic> body = const {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) body = Map<String, dynamic>.from(decoded);
      } catch (_) {}

      debugPrint(
          'DoctorOfflineUploadCoordinator: BULK SCHEDULE STATUS=${response.statusCode}');
      debugPrint(
          'DoctorOfflineUploadCoordinator: BULK SCHEDULE RAW RESPONSE=${response.body}');
      debugPrint(
          'DoctorOfflineUploadCoordinator: BULK SCHEDULE PARSED RESPONSE=${const JsonEncoder.withIndent('  ').convert(body)}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        await _markAll(
          schedules,
          'Schedule upload failed (${response.statusCode}).',
        );
        return;
      }

      if (body['success'] == false || body['status'] == false) {
        await _markAll(
          schedules,
          body['message']?.toString().trim().isNotEmpty == true
              ? body['message'].toString()
              : 'Schedule upload was rejected by the server.',
        );
        return;
      }

      final errorsByIndex = <int, String>{};
      for (final error in _asList(body['errors'])) {
        if (error is! Map) continue;
        final index = _asInt(error['index']);
        if (index != null) {
          errorsByIndex[index] =
              error['error']?.toString() ?? 'Schedule rejected by server.';
        }
      }

      final data = _asList(body['data']);
      final skipped = _asList(body['skipped']);
      final resolved = _resolveScheduleResponse(
        responseItems: [...data, ...skipped],
        schedules: schedules,
        errorsByIndex: errorsByIndex,
      );

      debugPrint(
          'DoctorOfflineUploadCoordinator: BULK SCHEDULE RESPONSE mapping=$resolved errors=$errorsByIndex');

      for (var i = 0; i < schedules.length; i++) {
        final item = schedules[i];
        final serverVisitId = resolved[i];
        if (serverVisitId != null && serverVisitId.isNotEmpty) {
          await _scheduleRepository.markUploaded(
            localId: item.schedule.localId,
            serverVisitId: serverVisitId,
          );
          await _visitRepository.resolveServerVisitId(
            localScheduleId: item.schedule.localId,
            serverVisitId: serverVisitId,
          );
          debugPrint(
              'DoctorOfflineUploadCoordinator: SCHEDULE SYNCED local=${item.schedule.localId} serverVisit=$serverVisitId');
        } else {
          debugPrint(
              'DoctorOfflineUploadCoordinator: SCHEDULE NOT SYNCED local=${item.schedule.localId} reason=${errorsByIndex[i] ?? 'server response did not include an ID'}');
          await _scheduleRepository.markError(
            localId: item.schedule.localId,
            message: errorsByIndex[i] ??
                'Server response did not identify the created schedule.',
          );
        }
      }
    } catch (error) {
      await _markAll(
          schedules, 'Schedule upload could not reach the server: $error');
    }
  }

  Map<int, String> _resolveScheduleResponse({
    required List<Object?> responseItems,
    required List<_ReadySchedule> schedules,
    required Map<int, String> errorsByIndex,
  }) {
    final resolved = <int, String>{};
    final unresolvedResponseIds = <String>[];

    for (final value in responseItems) {
      if (value is! Map) continue;
      final id = _serverVisitId(value);
      if (id == null) continue;

      final explicitIndex = _responseIndex(value);
      if (explicitIndex != null &&
          explicitIndex >= 0 &&
          explicitIndex < schedules.length &&
          !errorsByIndex.containsKey(explicitIndex)) {
        resolved[explicitIndex] = id;
        continue;
      }

      final responseLocalId = _responseLocalId(value);
      if (responseLocalId != null) {
        final matchingIndex = schedules.indexWhere(
          (item) => item.schedule.localId == responseLocalId,
        );
        if (matchingIndex >= 0 && !errorsByIndex.containsKey(matchingIndex)) {
          resolved[matchingIndex] = id;
          continue;
        }
      }

      unresolvedResponseIds.add(id);
    }

    // The API currently returns created/skipped items without always returning
    // their request index. Order mapping is safe only when every successful
    // request is represented; otherwise keep the schedule pending for a
    // retry instead of attaching the wrong server ID to it.
    final successfulIndexes = <int>[
      for (var i = 0; i < schedules.length; i++)
        if (!errorsByIndex.containsKey(i)) i,
    ];
    final remainingIndexes = successfulIndexes
        .where((index) => !resolved.containsKey(index))
        .toList();
    if (unresolvedResponseIds.length == remainingIndexes.length) {
      for (var i = 0; i < unresolvedResponseIds.length; i++) {
        resolved[remainingIndexes[i]] = unresolvedResponseIds[i];
      }
    }

    return resolved;
  }

  Future<void> _markAll(List<_ReadySchedule> schedules, String message) async {
    for (final item in schedules) {
      await _scheduleRepository.markError(
        localId: item.schedule.localId,
        message: message,
      );
    }
  }

  static List<Object?> _asList(Object? value) =>
      value is List ? List<Object?>.from(value) : const <Object?>[];

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _serverVisitId(Object? value) {
    if (value is! Map) return null;
    final nested = value['visit'];
    if (nested is Map) {
      final nestedId = _serverVisitId(nested);
      if (nestedId != null) return nestedId;
    }
    final nestedSchedule = value['schedule'];
    if (nestedSchedule is Map) {
      final nestedId = _serverVisitId(nestedSchedule);
      if (nestedId != null) return nestedId;
    }
    for (final key in const [
      'id',
      'visitId',
      'visit_id',
      'scheduleId',
      'schedule_id',
      'doctorVisitId',
      'doctor_visit_id',
      '_id',
    ]) {
      final id = value[key]?.toString().trim();
      if (id != null && id.isNotEmpty) return id;
    }
    return null;
  }

  static int? _responseIndex(Map<Object?, Object?> value) {
    for (final key in const [
      'index',
      'requestIndex',
      'request_index',
      'inputIndex',
      'input_index',
    ]) {
      final index = _asInt(value[key]);
      if (index != null) return index;
    }
    return null;
  }

  static String? _responseLocalId(Map<Object?, Object?> value) {
    for (final key in const [
      'localId',
      'local_id',
      'scheduleLocalId',
      'schedule_local_id',
      'clientGeneratedId',
      'client_generated_id',
    ]) {
      final text = value[key]?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  static String? _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      if (value?.trim().isNotEmpty == true) return value;
    }
    return null;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    if (_ownsAreaAssignmentSyncService) _areaAssignmentSyncService.dispose();
    if (_ownsVisitSyncService) _visitSyncService.dispose();
    if (_ownsClient) _client.close();
  }
}

class _ReadySchedule {
  const _ReadySchedule(this.schedule, this.serverDoctorId);

  final PendingScheduleModel schedule;
  final String serverDoctorId;
}
