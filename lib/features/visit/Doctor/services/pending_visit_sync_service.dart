import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../repository/pending_visit_repository.dart';

class PendingVisitSyncService {
  static const Duration _requestTimeout = Duration(seconds: 20);
  static Future<void>? _activeSync;

  final PendingVisitRepository _repository = PendingVisitRepository();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final AuthManager _authManager = AuthManager();

  void startListening() {
    debugPrint(
        "PendingVisitSyncService: Connectivity listener started.");

    _subscription?.cancel();
    unawaited(_syncWhenConnected());

    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      debugPrint(
          "PendingVisitSyncService: Connectivity Changed = $result");

      if (!result.contains(ConnectivityResult.none)) {
        debugPrint(
            "PendingVisitSyncService: Internet available. Starting sync...");
        unawaited(syncPendingVisits());
      } else {
        debugPrint(
            "PendingVisitSyncService: Internet unavailable.");
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
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
    debugPrint(
        "PendingVisitSyncService: syncPendingVisits() started");

    final pendingVisits = await _repository.getPendingVisits();

    debugPrint(
        "PendingVisitSyncService: Pending Visits Count = ${pendingVisits.length}");

    if (pendingVisits.isEmpty) {
      debugPrint(
          "PendingVisitSyncService: No pending visits found.");
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

    for (final visit in pendingVisits) {
      try {
        final uri =
        Uri.parse('${THttpHelper.baseUrl}/doctor-visits/bulk-confirm');

        final requestBody = {
          "visits": [
            {
              "id": visit.visitId,
              "userLatitude": visit.userLatitude,
              "userLongitude": visit.userLongitude,
              "notes": visit.notes,
              "productIds": visit.productIds,
            }
          ]
        };

        debugPrint("------------------------------------------");
        debugPrint(
            "PendingVisitSyncService: Syncing Visit = ${visit.visitId}");
        debugPrint(
            "PendingVisitSyncService: URL = $uri");
        debugPrint(
            "PendingVisitSyncService: Request JSON =\n${const JsonEncoder.withIndent('  ').convert(requestBody)}");

        final response = await http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        ).timeout(_requestTimeout);

        debugPrint(
            "PendingVisitSyncService: Response Status = ${response.statusCode}");

        dynamic responseBody;
        try {
          responseBody = jsonDecode(response.body);
          final pretty = const JsonEncoder.withIndent('  ')
              .convert(responseBody);

          debugPrint(
              "PendingVisitSyncService: Response JSON =\n$pretty");
        } catch (_) {
          debugPrint(
              "PendingVisitSyncService: Raw Response = ${response.body}");
        }

        final responseAccepted = response.statusCode >= 200 &&
            response.statusCode < 300 &&
            !(responseBody is Map &&
                (responseBody['status'] == false ||
                    responseBody['success'] == false));

        if (responseAccepted) {

          debugPrint(
              "PendingVisitSyncService: Sync Successful");

          await _repository.deleteVisit(visit.visitId);

          debugPrint(
              "PendingVisitSyncService: Deleted from SQLite -> ${visit.visitId}");
        } else {
          debugPrint(
              "PendingVisitSyncService: Sync Failed. Keeping record in SQLite.");
        }
      } on TimeoutException {
        debugPrint(
          'PendingVisitSyncService: Sync timed out. Remaining visits retained.',
        );
        break;
      } on SocketException {
        debugPrint(
          'PendingVisitSyncService: Internet unreachable. '
          'Remaining visits retained.',
        );
        break;
      } on http.ClientException {
        debugPrint(
          'PendingVisitSyncService: API unreachable. '
          'Remaining visits retained.',
        );
        break;
      } catch (e, stackTrace) {
        debugPrint(
            "PendingVisitSyncService: Exception = $e");
        debugPrint(
            "PendingVisitSyncService: StackTrace = $stackTrace");
        debugPrint(
            "PendingVisitSyncService: Record kept in SQLite.");
      }
    }

    debugPrint(
        "PendingVisitSyncService: syncPendingVisits() finished");
    debugPrint(
        "PendingVisitSyncService: ======================================");
  }
}
