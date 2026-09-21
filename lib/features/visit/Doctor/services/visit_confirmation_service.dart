import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/local_storage/auth_manager.dart';
import '../models/pending_visit_model.dart';
import '../repository/pending_visit_repository.dart';
import 'doctor_offline_upload_coordinator.dart';

class VisitConfirmationService {
  VisitConfirmationService({
    PendingVisitRepository? repository,
    AuthManager? authManager,
    Future<void> Function()? syncTrigger,
  })  : _repository = repository ?? PendingVisitRepository(),
        _authManager = authManager ?? AuthManager(),
        _syncTrigger = syncTrigger;

  final PendingVisitRepository _repository;
  final AuthManager _authManager;
  final Future<void> Function()? _syncTrigger;

  Future<http.Response> confirmVisit({
    required String visitId,
    required double doctorLatitude,
    required double doctorLongitude,
    required Position position,
    required List<String> productIds,
    String notes = '',
    String? localScheduleId,
    bool forceOffline = false,
  }) async {
    final configuredMeterRange = await _authManager.getMeterRange();
    final meterRange = configuredMeterRange ?? 200.0;
    final distance = Geolocator.distanceBetween(
      doctorLatitude,
      doctorLongitude,
      position.latitude,
      position.longitude,
    );

    if (distance > meterRange) {
      return _distanceRejectedResponse(
        distance: distance,
        meterRange: meterRange,
      );
    }

    final pendingVisit = PendingVisitModel(
      visitId: visitId,
      userLatitude: position.latitude,
      userLongitude: position.longitude,
      notes: notes,
      productIds: productIds,
      createdAt: DateTime.now().toUtc(),
      localScheduleId: localScheduleId,
      serverVisitId: localScheduleId == null || visitId != localScheduleId
          ? visitId
          : null,
    );

    // The local outbox is the source of truth. The request is durable before
    // any connectivity check or HTTP call can fail.
    await _repository.insertVisit(pendingVisit);

    // The sync service owns all uploads and always sends batches of ten. It
    // safely retries when the device is offline or the request is slow.
    if (!forceOffline) {
      // Keep every automatic confirmation behind the same ordered pipeline:
      // doctors/geo images -> schedules -> visit confirmations. The screen
      // supplies its lifecycle-managed coordinator; the fallback creates a
      // short-lived coordinator so callers outside the screen cannot bypass
      // the doctor and schedule stages.
      unawaited(_triggerOrderedSync());
    }

    debugPrint(
      'VisitConfirmationService: Visit $visitId saved to local outbox',
    );
    return _queuedResponse();
  }

  Future<void> _triggerOrderedSync() async {
    final trigger = _syncTrigger;
    if (trigger != null) {
      await trigger();
      return;
    }

    final coordinator = DoctorOfflineUploadCoordinator();
    try {
      await coordinator.syncAll();
    } finally {
      coordinator.dispose();
    }
  }

  http.Response _queuedResponse() {
    return http.Response(
      jsonEncode({
        'status': true,
        'message': 'Visit saved locally and queued for sync.',
        'offline': true,
        'queued': true,
      }),
      200,
    );
  }

  http.Response _distanceRejectedResponse({
    required double distance,
    required double meterRange,
  }) {
    return http.Response(
      jsonEncode({
        'status': false,
        'offline': true,
        'message':
            "You are ${_formatKilometers(distance)} away from the doctor's location. Please move within ${_formatKilometers(meterRange)} to confirm this visit.",
      }),
      400,
    );
  }

  String _formatKilometers(double meters) {
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }
}
