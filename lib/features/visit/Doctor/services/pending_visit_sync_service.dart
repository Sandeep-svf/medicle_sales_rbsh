import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/http/http_client.dart';
import '../../../../utils/local_storage/auth_manager.dart';
import '../repository/pending_visit_repository.dart';

class PendingVisitSyncService {
  final PendingVisitRepository _repository = PendingVisitRepository();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final AuthManager _authManager = AuthManager();

  void startListening() {
    debugPrint(
        "PendingVisitSyncService: Connectivity listener started.");

    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      debugPrint(
          "PendingVisitSyncService: Connectivity Changed = $result");

      if (!result.contains(ConnectivityResult.none)) {
        debugPrint(
            "PendingVisitSyncService: Internet available. Starting sync...");
        syncPendingVisits();
      } else {
        debugPrint(
            "PendingVisitSyncService: Internet unavailable.");
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> syncPendingVisits() async {
    debugPrint(
        "PendingVisitSyncService: ======================================");
    debugPrint(
        "PendingVisitSyncService: syncPendingVisits() started");

    final pendingVisits = await _repository.getPendingVisits();
    final token = await _authManager.getAuthToken();

    debugPrint(
        "PendingVisitSyncService: Pending Visits Count = ${pendingVisits.length}");

    if (pendingVisits.isEmpty) {
      debugPrint(
          "PendingVisitSyncService: No pending visits found.");
      debugPrint(
          "PendingVisitSyncService: ======================================");
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
        );

        debugPrint(
            "PendingVisitSyncService: Response Status = ${response.statusCode}");

        try {
          final pretty = const JsonEncoder.withIndent('  ')
              .convert(jsonDecode(response.body));

          debugPrint(
              "PendingVisitSyncService: Response JSON =\n$pretty");
        } catch (_) {
          debugPrint(
              "PendingVisitSyncService: Raw Response = ${response.body}");
        }

        if (response.statusCode == 200 ||
            response.statusCode == 201) {

          debugPrint(
              "PendingVisitSyncService: Sync Successful");

          await _repository.deleteVisit(visit.visitId);

          debugPrint(
              "PendingVisitSyncService: Deleted from SQLite -> ${visit.visitId}");
        } else {
          debugPrint(
              "PendingVisitSyncService: Sync Failed. Keeping record in SQLite.");
        }
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