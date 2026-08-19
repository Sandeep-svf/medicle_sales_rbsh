import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';

import 'app_state_dao.dart';
import 'upload_queue_dao.dart';

class UploadQueueDrainer {
  final UploadQueueDao _dao;
  final int _batchSize;

  bool _running = false;

  UploadQueueDrainer(
      this._dao, {
        int batchSize = 100,
      }) : _batchSize = batchSize;

  Future<void> drainOnce() async {
    // =====================================================
    // PREVENT SAME DRAINER INSTANCE RUNNING TWICE
    // =====================================================

    if (_running) {
      developer.log(
        'Already running. Skipping this cycle.',
        name: 'UploadQueueDrainer',
      );
      return;
    }

    _running = true;

    developer.log(
      '========== Upload Started ==========',
      name: 'UploadQueueDrainer',
    );

    List<Map<String, dynamic>> rows = [];

    try {
      // ===================================================
      // 1. GET PENDING RECORDS
      // ===================================================

      rows = await _dao.fetchPending(
        _batchSize,
      );

      developer.log(
        'Pending rows found: ${rows.length}',
        name: 'UploadQueueDrainer',
      );

      if (rows.isEmpty) {
        developer.log(
          'No pending records to upload.',
          name: 'UploadQueueDrainer',
        );

        return;
      }

      // ===================================================
      // 2. GET DEVICE ID FROM LOCAL DB
      //
      // IMPORTANT:
      //
      // DO NOT call MethodChannel/getAndroidId() here.
      //
      // main.dart already gets the permanent Android ID
      // and stores it in:
      //
      // app_state
      // key = device_id
      //
      // Background isolate simply reads that value.
      // ===================================================

      final appStateDao = AppStateDao();

      final deviceId =
      await appStateDao.get('device_id');

      developer.log(
        'Device ID from app_state : $deviceId',
        name: 'UploadQueueDrainer',
      );

      // ===================================================
      // DEVICE ID IS REQUIRED
      //
      // DO NOT mark rows as SENDING if ID is unavailable.
      // Leave them PENDING so they can retry later.
      // ===================================================

      if (deviceId == null ||
          deviceId.trim().isEmpty) {
        developer.log(
          'Device ID missing. Upload skipped. '
              'Rows remain PENDING.',
          name: 'UploadQueueDrainer',
        );

        return;
      }

      // ===================================================
      // 3. API URL
      // ===================================================

      final url =
          "${THttpHelper.baseUrl}/offline-bg-tracking";

      developer.log(
        'Device ID : $deviceId',
        name: 'UploadQueueDrainer',
      );

      developer.log(
        'URL : $url',
        name: 'UploadQueueDrainer',
      );

      // ===================================================
      // 4. PREPARE EVENTS
      // ===================================================

      final events = rows.map((row) {
        return {
          "entity_type": row["entity_type"],
          "entity_id": row["entity_id"],
          "payload": jsonDecode(
            row["payload"],
          ),
        };
      }).toList();

      final body = {
        "device_id": deviceId,
        "data": events,
      };

      developer.log(
        'Request Body:\n'
            '${const JsonEncoder.withIndent("  ").convert(body)}',
        name: 'UploadQueueDrainer',
      );

      // ===================================================
      // 5. MARK AS SENDING
      //
      // Only after:
      // - records exist
      // - device ID exists
      // - request body successfully created
      // ===================================================

      for (final row in rows) {
        await _dao.markSending(
          row['id'] as int,
        );
      }

      // ===================================================
      // 6. SEND API REQUEST
      // ===================================================

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      developer.log(
        'Response Status : ${response.statusCode}',
        name: 'UploadQueueDrainer',
      );

      developer.log(
        'Response Body : ${response.body}',
        name: 'UploadQueueDrainer',
      );

      // ===================================================
      // 7. SUCCESS
      // ===================================================

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final jsonResponse =
        jsonDecode(response.body);

        if (jsonResponse["success"] == true) {
          developer.log(
            'Upload successful.',
            name: 'UploadQueueDrainer',
          );

          for (final row in rows) {
            await _dao.markSent(
              row['id'] as int,
            );
          }

          developer.log(
            '${rows.length} records marked as sent.',
            name: 'UploadQueueDrainer',
          );

          await _dao.deleteSentOlderThanDays(
            3,
          );

          developer.log(
            'Deleted sent records older than 3 days.',
            name: 'UploadQueueDrainer',
          );

          return;
        }

        // =================================================
        // SERVER RETURNED HTTP SUCCESS BUT success=false
        // =================================================

        developer.log(
          'Server returned success=false.',
          name: 'UploadQueueDrainer',
        );

        for (final row in rows) {
          await _dao.markFailedSafe(
            row['id'] as int,
            row['retry_count'] as int,
          );
        }

        return;
      }

      // ===================================================
      // 8. HTTP FAILURE
      // ===================================================

      developer.log(
        'Upload failed with status '
            '${response.statusCode}.',
        name: 'UploadQueueDrainer',
      );

      for (final row in rows) {
        await _dao.markFailedSafe(
          row['id'] as int,
          row['retry_count'] as int,
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Exception while uploading.',
        name: 'UploadQueueDrainer',
        error: e,
        stackTrace: stackTrace,
      );

      // ===================================================
      // NO INTERNET
      //
      // Return rows back to PENDING.
      // ===================================================

      if (e is SocketException) {
        developer.log(
          'No internet. Keeping rows pending.',
          name: 'UploadQueueDrainer',
        );

        for (final row in rows) {
          await _dao.markPending(
            row['id'] as int,
          );
        }
      } else {
        // =================================================
        // OTHER FAILURE
        // =================================================

        for (final row in rows) {
          await _dao.markFailedSafe(
            row['id'] as int,
            row['retry_count'] as int,
          );
        }
      }
    } finally {
      developer.log(
        '========== Upload Finished ==========',
        name: 'UploadQueueDrainer',
      );

      _running = false;
    }
  }
}