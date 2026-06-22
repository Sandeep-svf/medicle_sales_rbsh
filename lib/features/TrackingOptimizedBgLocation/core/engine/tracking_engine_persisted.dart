/*
import 'dart:convert';

import '../../storage/last_location_dao.dart';
import '../../storage/upload_queue_dao.dart';

import '../model/location_point.dart';
import '../buffer/buffer_event.dart';

import '../../debug/tracking_debug_state.dart';
import 'tracking_engine.dart';

class TrackingEnginePersisted {
  final _engine = TrackingEngine();

  //  SAFE DAOs (ALLOWED IN BACKGROUND)
  final _lastLocationDao = LastLocationDao();
  final _uploadQueueDao = UploadQueueDao();

  /// =========================================================
  /// MAIN ENTRY POINT FROM BACKGROUND SERVICE
  /// =========================================================
  Future<void> process(LocationPoint point) async {
    // ==================================================
    // 1. ALWAYS SAVE LAST LOCATION (CRASH / KILL SAFE)
    // ==================================================
    await _lastLocationDao.save(point);
    print('[LAST] saved ${point.latitude}, ${point.longitude}');

    // ==================================================
    // 2. RUN CORE ENGINE (PURE LOGIC — NO DB)
    // ==================================================
    final event = _engine.processRawPoint(
      point,
      DateTime.now(),
    );

    // ==================================================
    // 3. DEBUG STATE (IN-MEMORY ONLY)
    // ==================================================
    TrackingDebugState.lastSpeed = point.speed;

    if (event.decision.name == 'accepted') {
      TrackingDebugState.acceptedGps++;
    } else {
      TrackingDebugState.rejectedGps++;
    }

    TrackingDebugState.activeStop = event.activeStop;

    print(
      '[DEBUG] accepted=${TrackingDebugState.acceptedGps}, '
          'rejected=${TrackingDebugState.rejectedGps}, '
          'speed=${point.speed.toStringAsFixed(2)}, '
          'activeStop=${event.activeStop != null}',
    );

    // ==================================================
    // 4. PHASE-2 WRITE-AHEAD BUFFER (THE ONLY DB WRITE)
    // ==================================================
    if (event.decision.name == 'accepted') {
      await _uploadQueueDao.enqueue(
        BufferEvent(
          type: BufferEntityType.location,
          entityId:
          point.timestampUtc.millisecondsSinceEpoch.toString(),
          payload: jsonEncode({
            'latitude': point.latitude,
            'longitude': point.longitude,
            'accuracy': point.accuracy,
            'speed': point.speed,
            'timestamp_utc':
            point.timestampUtc.toIso8601String(),
          }),
          createdAtUtc: DateTime.now().toUtc(),
        ),
      );

      print('[QUEUE] location enqueued');
    } else {
      print('[QUEUE] location rejected');
    }
  }

  // ==================================================
  // DEBUG PAYLOAD FOR UI BADGE
  // ==================================================
  Map<String, dynamic> buildDebugPayload() {
    return {
      'acceptedGps': TrackingDebugState.acceptedGps,
      'rejectedGps': TrackingDebugState.rejectedGps,
      'lastSpeed': TrackingDebugState.lastSpeed,
      'activeStopMinutes':
      TrackingDebugState.activeStop?.duration.inMinutes,
    };
  }

  /// ==================================================
  /// USED WHEN APP REOPENS AFTER KILL
  /// ==================================================
  Future<LocationPoint?> loadLastPoint() {
    return _lastLocationDao.load();
  }
}
*/


// updated one for fix store data in the db
import 'dart:convert';

import '../../storage/last_location_dao.dart';
import '../../storage/upload_queue_dao.dart';

import '../model/location_point.dart';
import '../buffer/buffer_event.dart';

import '../../debug/tracking_debug_state.dart';
import 'tracking_engine.dart';

class TrackingEnginePersisted {
  final _engine = TrackingEngine();

  // SAFE DAOs (ALLOWED IN BACKGROUND)
  final _lastLocationDao = LastLocationDao();
  final _uploadQueueDao = UploadQueueDao();

  /// =========================================================
  /// MAIN ENTRY POINT FROM BACKGROUND SERVICE
  /// =========================================================
  Future<void> process(
      LocationPoint point,
      String trackingSessionId,
      ) async {
    // ==================================================
    // 1. ALWAYS SAVE LAST LOCATION (CRASH / KILL SAFE)
    // ==================================================
    await _lastLocationDao.save(point);
    print('[LAST] saved ${point.latitude}, ${point.longitude}');

    // ==================================================
    // 2. RUN CORE ENGINE (PURE LOGIC — NO DB)
    // ==================================================
    final event = _engine.processRawPoint(
      point,
      DateTime.now(),
    );

    // ==================================================
    // 3. DEBUG STATE (IN-MEMORY ONLY)
    // ==================================================
    TrackingDebugState.lastSpeed = point.speed;

    if (event.decision.name == 'accepted') {
      TrackingDebugState.acceptedGps++;
    } else {
      TrackingDebugState.rejectedGps++;
    }

    TrackingDebugState.activeStop = event.activeStop;

    print(
      '[DEBUG] accepted=${TrackingDebugState.acceptedGps}, '
          'rejected=${TrackingDebugState.rejectedGps}, '
          'speed=${point.speed.toStringAsFixed(2)}, '
          'activeStop=${event.activeStop != null}',
    );

    // ==================================================
    // 4. PHASE-2 WRITE-AHEAD BUFFER (THE ONLY DB WRITE)
    // ==================================================
    if (event.decision.name == 'accepted') {
      // MUST be unique
      final entityId =
          '${trackingSessionId}_'
          '${point.timestampUtc.millisecondsSinceEpoch}_'
          '${point.latitude.toStringAsFixed(6)}_'
          '${point.longitude.toStringAsFixed(6)}';

      await _uploadQueueDao.enqueue(
        BufferEvent(
          type: BufferEntityType.location,
          entityId: entityId,
          payload: jsonEncode({
            //  REQUIRED METADATA
            'event_type': 'LOCATION_POINT',
            'tracking_session_id': trackingSessionId,

            //  LOCATION DATA
            'latitude': point.latitude,
            'longitude': point.longitude,
            'accuracy': point.accuracy,
            'speed': point.speed,

            //  TIME
            'timestamp_utc': point.timestampUtc.toIso8601String(),
          }),
          createdAtUtc: DateTime.now().toUtc(),
        ),
      );

      print('[QUEUE] location enqueued → $entityId');
    } else {
      print('[QUEUE] location rejected');
    }
  }

  // ==================================================
  // DEBUG PAYLOAD FOR UI BADGE
  // ==================================================
  Map<String, dynamic> buildDebugPayload() {
    return {
      'acceptedGps': TrackingDebugState.acceptedGps,
      'rejectedGps': TrackingDebugState.rejectedGps,
      'lastSpeed': TrackingDebugState.lastSpeed,
      'activeStopMinutes':
      TrackingDebugState.activeStop?.duration.inMinutes,
    };
  }

  /// ==================================================
  /// USED WHEN APP REOPENS AFTER KILL
  /// ==================================================
  Future<LocationPoint?> loadLastPoint() {
    return _lastLocationDao.load();
  }
}

