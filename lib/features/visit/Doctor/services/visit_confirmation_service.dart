import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/local_storage/auth_manager.dart';
import '../models/pending_visit_model.dart';
import '../repository/pending_visit_repository.dart';
import '../../../../utils/http/http_client.dart';

class VisitConfirmationService {
  static const Duration _requestTimeout = Duration(seconds: 20);

  final PendingVisitRepository _repository = PendingVisitRepository();
  final AuthManager _authManager = AuthManager();

  Future<http.Response> confirmVisit({
    required String visitId,
    required double doctorLatitude,
    required double doctorLongitude,
    required Position position,
    required List<String> productIds,
    String notes = "",
    bool forceOffline = false,
  }) async {
    final token = await _authManager.getAuthToken();
    var canAttemptOnline = !forceOffline;
    List<ConnectivityResult> connectivity = const [ConnectivityResult.none];

    if (canAttemptOnline) {
      try {
        connectivity = await Connectivity().checkConnectivity();
        canAttemptOnline = !connectivity.contains(ConnectivityResult.none);
      } catch (error) {
        canAttemptOnline = false;
        debugPrint(
          'VisitConfirmationService: Connectivity check failed: $error',
        );
      }
    }

    debugPrint(
        "VisitConfirmationService: ======================================");
    debugPrint(
        "VisitConfirmationService: confirmVisit() started");
    debugPrint(
        "VisitConfirmationService: Visit ID = $visitId");
    debugPrint(
        "VisitConfirmationService: Connectivity = $connectivity");

    debugPrint(
        "VisitConfirmationService: Latitude = ${position.latitude}");
    debugPrint(
        "VisitConfirmationService: Longitude = ${position.longitude}");
    debugPrint(
        "VisitConfirmationService: Selected Products = $productIds");

    // ============================
    // ONLINE
    // ============================
    if (canAttemptOnline) {
      final uri =
      Uri.parse('${THttpHelper.baseUrl}/doctor-visits/bulk-confirm');

      final requestBody = {
        "visits": [
          {
            "id": visitId,
            "userLatitude": position.latitude,
            "userLongitude": position.longitude,
            "notes": notes,
            "productIds": productIds,
          }
        ]
      };

      debugPrint("VisitConfirmationService: ONLINE MODE");
      debugPrint("VisitConfirmationService: URL = $uri");
      debugPrint(
          "VisitConfirmationService: Request JSON = ${const JsonEncoder.withIndent('  ').convert(requestBody)}");

      try {
        final response = await http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        ).timeout(_requestTimeout);

        debugPrint(
            "VisitConfirmationService: Response Status = ${response.statusCode}");

        try {
          final pretty = const JsonEncoder.withIndent('  ')
              .convert(jsonDecode(response.body));
          debugPrint(
              "VisitConfirmationService: Response JSON =\n$pretty");
        } catch (_) {
          debugPrint(
              "VisitConfirmationService: Raw Response = ${response.body}");
        }

        debugPrint(
            "VisitConfirmationService: ======================================");

        return response;
      } on TimeoutException {
        debugPrint(
          'VisitConfirmationService: Request timed out. Saving offline.',
        );
      } on SocketException {
        debugPrint(
          'VisitConfirmationService: Internet unreachable. Saving offline.',
        );
      } on http.ClientException {
        debugPrint(
          'VisitConfirmationService: API unreachable. Saving offline.',
        );
      }
    }

    return _saveOffline(
      visitId: visitId,
      doctorLatitude: doctorLatitude,
      doctorLongitude: doctorLongitude,
      position: position,
      productIds: productIds,
      notes: notes,
    );
  }

  Future<http.Response> _saveOffline({
    required String visitId,
    required double doctorLatitude,
    required double doctorLongitude,
    required Position position,
    required List<String> productIds,
    required String notes,
  }) async {

    debugPrint("VisitConfirmationService: OFFLINE MODE");
    debugPrint(
        "VisitConfirmationService: Saving visit into SQLite...");

    final double distance = Geolocator.distanceBetween(
      doctorLatitude,
      doctorLongitude,
      position.latitude,
      position.longitude,
    );

    debugPrint(
        "VisitConfirmationService: Distance = ${distance.toStringAsFixed(2)} meters");

    if (distance > 200) {
      final response = {
        "status": false,
        "offline": true,
        "message":
        "You are ${distance.toStringAsFixed(0)} meters away from the doctor's location. Please move within 200 meters to confirm this visit.",
      };

      return http.Response(
        jsonEncode(response),
        400,
      );
    }

    debugPrint(
        "VisitConfirmationService: Distance validation passed. Saving visit into SQLite...");

    final pendingVisit = PendingVisitModel(
      visitId: visitId,
      userLatitude: position.latitude,
      userLongitude: position.longitude,
      notes: notes,
      productIds: productIds,
      createdAt: DateTime.now(),
    );

    await _repository.insertVisit(pendingVisit);

    debugPrint(
        "VisitConfirmationService: Visit saved locally");
    debugPrint(
        "VisitConfirmationService: Visit ID = $visitId");

    final offlineResponse = {
      "status": true,
      "message": "Visit saved offline successfully.",
      "offline": true,
    };

    debugPrint(
        "VisitConfirmationService: Offline Response = ${const JsonEncoder.withIndent('  ').convert(offlineResponse)}");

    debugPrint(
        "VisitConfirmationService: ======================================");

    return http.Response(
      jsonEncode(offlineResponse),
      200,
    );
  }
}
