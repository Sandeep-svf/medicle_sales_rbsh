import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../models/pending_visit_model.dart';
import '../repository/pending_visit_repository.dart';
import '../repository/pending_schedule_repository.dart';

class PendingVisitSyncService {
  static const Duration _requestTimeout = Duration(seconds: 20);
  static const int batchSize = 10;
  static Future<void>? _activeSync;

  PendingVisitSyncService({
    PendingVisitRepository? repository,
    PendingScheduleRepository? scheduleRepository,
    AuthManager? authManager,
    http.Client? client,
    String? baseUrl,
  })  : _repository = repository ?? PendingVisitRepository(),
        _scheduleRepository = scheduleRepository ?? PendingScheduleRepository(),
        _authManager = authManager ?? AuthManager(),
        _client = client ?? http.Client(),
        _ownsClient = client == null,
        _baseUrl = baseUrl ?? THttpHelper.baseUrl;

  final PendingVisitRepository _repository;
  final PendingScheduleRepository _scheduleRepository;
  final AuthManager _authManager;
  final http.Client _client;
  final bool _ownsClient;
  final String _baseUrl;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void startListening() {
    debugPrint("PendingVisitSyncService: Connectivity listener started.");

    _subscription?.cancel();
    unawaited(_syncWhenConnected());

    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      debugPrint("PendingVisitSyncService: Connectivity Changed = $result");

      if (!result.contains(ConnectivityResult.none)) {
        debugPrint(
            "PendingVisitSyncService: Internet available. Starting sync...");
        unawaited(syncPendingVisits());
      } else {
        debugPrint("PendingVisitSyncService: Internet unavailable.");
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    if (_ownsClient) _client.close();
  }

  Future<void> _syncWhenConnected() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (!connectivity.contains(ConnectivityResult.none)) {
        await syncPendingVisits();
      }
    } catch (error) {
      debugPrint(
        'PendingVisitSyncService: Connectivity check failed: $error',
      );
    }
  }

  Future<void> syncPendingVisits() {
    final activeSync = _activeSync;
    if (activeSync != null) return activeSync;

    final sync = _performSync();
    _activeSync = sync;

    return sync.whenComplete(() {
      if (identical(_activeSync, sync)) {
        _activeSync = null;
      }
    });
  }

  Future<void> _performSync() async {
    try {
      await _syncPendingVisits();
    } catch (error, stackTrace) {
      debugPrint(
        'PendingVisitSyncService: Could not access pending visits: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _syncPendingVisits() async {
    debugPrint(
        "PendingVisitSyncService: ======================================");
    debugPrint("PendingVisitSyncService: syncPendingVisits() started");

    final pendingVisits = await _loadReadyVisits();

    debugPrint(
        "PendingVisitSyncService: Pending Visits Count = ${pendingVisits.length}");
    debugPrint(
      'PendingVisitSyncService: Ready visit IDs = ${pendingVisits.map((visit) => '${visit.visitId}(server=${visit.serverVisitId}, schedule=${visit.localScheduleId})').join(', ')}',
    );

    if (pendingVisits.isEmpty) {
      debugPrint("PendingVisitSyncService: No pending visits found.");
      debugPrint(
          "PendingVisitSyncService: ======================================");
      return;
    }

    final token = await _authManager.getAuthToken();
    if (token == null || token.trim().isEmpty) {
      debugPrint(
        'PendingVisitSyncService: No auth token. Pending visits retained.',
      );
      return;
    }

    for (var offset = 0; offset < pendingVisits.length; offset += batchSize) {
      final end = (offset + batchSize > pendingVisits.length)
          ? pendingVisits.length
          : offset + batchSize;
      final chunk = pendingVisits.sublist(offset, end);
      try {
        final uri = Uri.parse('$_baseUrl/doctor-visits/bulk-confirm');

        final requestBody = {
          "visits": chunk
              .map((visit) => {
                    "id": visit.uploadVisitId,
                    "userLatitude": visit.userLatitude,
                    "userLongitude": visit.userLongitude,
                    "notes": visit.notes,
                    "productIds": visit.productIds,
                  })
              .toList(),
        };

        debugPrint("------------------------------------------");
        debugPrint(
            "PendingVisitSyncService: Syncing ${chunk.length} visits (${offset + 1}-$end of ${pendingVisits.length})");
        debugPrint("PendingVisitSyncService: URL = $uri");
        debugPrint(
            "PendingVisitSyncService: Request JSON =\n${const JsonEncoder.withIndent('  ').convert(requestBody)}");

        final response = await _client
            .put(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(requestBody),
            )
            .timeout(_requestTimeout);

        debugPrint(
            "PendingVisitSyncService: Response Status = ${response.statusCode}");
        debugPrint(
            'PendingVisitSyncService: BULK CONFIRM RAW RESPONSE = ${response.body}');

        dynamic responseBody;
        try {
          responseBody = jsonDecode(response.body);
          final pretty =
              const JsonEncoder.withIndent('  ').convert(responseBody);

          debugPrint("PendingVisitSyncService: Response JSON =\n$pretty");
        } catch (_) {
          debugPrint(
              "PendingVisitSyncService: Raw Response = ${response.body}");
        }

        final responseAccepted = response.statusCode >= 200 &&
            response.statusCode < 300 &&
            !(responseBody is Map &&
                (responseBody['status'] == false ||
                    responseBody['success'] == false));
        debugPrint(
          'PendingVisitSyncService: BULK CONFIRM ACCEPTED = $responseAccepted',
        );

        if (responseAccepted) {
          final errorIndexes = <int>{};
          if (responseBody is Map && responseBody['errors'] is List) {
            for (final error in responseBody['errors']) {
              if (error is Map && error['index'] is num) {
                errorIndexes.add((error['index'] as num).toInt());
              }
            }
          }
          final successfulIndexes = <int>[
            for (var i = 0; i < chunk.length; i++)
              if (!errorIndexes.contains(i)) i,
          ];
          final responseData =
              responseBody is Map && responseBody['data'] is List
                  ? responseBody['data'] as List
                  : const <Object>[];
          final indexesToDelete = errorIndexes.isEmpty
              ? List<int>.generate(chunk.length, (index) => index)
              : responseData.length == successfulIndexes.length
                  ? successfulIndexes
                  : const <int>[];

          debugPrint(
              "PendingVisitSyncService: Batch accepted; error indexes=$errorIndexes; deleting ${indexesToDelete.length} successful visits");

          for (final index in indexesToDelete) {
            final visit = chunk[index];
            await _repository.deleteVisit(visit.visitId);
            if (visit.localScheduleId != null) {
              await _scheduleRepository.delete(visit.localScheduleId!);
            }
            debugPrint(
                "PendingVisitSyncService: Deleted from SQLite -> ${visit.visitId}");
          }
        } else {
          debugPrint(
              "PendingVisitSyncService: Batch failed. Keeping ${chunk.length} records in SQLite.");
        }
      } on TimeoutException {
        debugPrint(
          'PendingVisitSyncService: Batch timed out. Remaining visits retained.',
        );
        break;
      } on SocketException {
        debugPrint(
          'PendingVisitSyncService: Internet unreachable. '
          'Remaining batches retained.',
        );
        break;
      } on http.ClientException {
        debugPrint(
          'PendingVisitSyncService: API unreachable. '
          'Remaining batches retained.',
        );
        break;
      } catch (e, stackTrace) {
        debugPrint("PendingVisitSyncService: Exception = $e");
        debugPrint("PendingVisitSyncService: StackTrace = $stackTrace");
        debugPrint("PendingVisitSyncService: Batch kept in SQLite.");
      }
    }

    debugPrint("PendingVisitSyncService: syncPendingVisits() finished");
    final remaining = await _repository.getPendingVisits();
    debugPrint(
      'PendingVisitSyncService: Remaining pending visit IDs = ${remaining.map((visit) => '${visit.visitId}(server=${visit.serverVisitId}, schedule=${visit.localScheduleId})').join(', ')}',
    );
    debugPrint(
        "PendingVisitSyncService: ======================================");
  }

  /// A confirmation can be created while its schedule is still local. The
  /// schedule may be uploaded before the confirmation worker runs (or by a
  /// previous worker pass), so resolve the visit ID from the schedule outbox
  /// here as well. This keeps the confirmation worker correct even when the
  /// pending-visit row was created before the schedule response arrived.
  Future<List<PendingVisitModel>> _loadReadyVisits() async {
    final storedVisits = await _repository.getPendingVisits();
    final ready = <PendingVisitModel>[];

    debugPrint(
      'PendingVisitSyncService: Stored pending visit rows = ${storedVisits.map((visit) => '${visit.visitId}(server=${visit.serverVisitId}, schedule=${visit.localScheduleId})').join(', ')}',
    );

    for (final storedVisit in storedVisits) {
      var visit = storedVisit;
      final localScheduleId = visit.localScheduleId;

      if (localScheduleId != null && visit.serverVisitId == null) {
        try {
          final schedule =
              await _scheduleRepository.findByLocalId(localScheduleId);
          final resolvedServerVisitId = schedule?.serverVisitId?.trim();

          if (resolvedServerVisitId != null &&
              resolvedServerVisitId.isNotEmpty) {
            // Keep the visit outbox aligned with the schedule outbox. The
            // repository update is durable; the copied model is used for this
            // sync pass without requiring another database read.
            await _repository.resolveServerVisitId(
              localScheduleId: localScheduleId,
              serverVisitId: resolvedServerVisitId,
            );
            visit = visit.copyWith(
              visitId: resolvedServerVisitId,
              serverVisitId: resolvedServerVisitId,
            );
            debugPrint(
              'PendingVisitSyncService: Resolved $localScheduleId -> '
              '$resolvedServerVisitId from schedule outbox',
            );
          }
        } catch (error, stackTrace) {
          // One corrupt/locked local row must not prevent other visits from
          // being uploaded. This visit remains pending for the next pass.
          debugPrint(
            'PendingVisitSyncService: Could not resolve schedule '
            '$localScheduleId: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      // A local schedule without a server visit ID is intentionally held
      // until bulk-schedule succeeds. Other visits are still eligible.
      if (visit.localScheduleId == null || visit.serverVisitId != null) {
        ready.add(visit);
      } else {
        debugPrint(
          'PendingVisitSyncService: Holding ${visit.visitId}; local schedule '
          '${visit.localScheduleId} has no server visit ID yet.',
        );
      }
    }

    return ready;
  }
}
