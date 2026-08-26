import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:uuid/uuid.dart';

import '../debug/tracking_console_logger.dart';
import 'app_state_dao.dart';
import 'upload_queue_dao.dart';

class UploadDrainResult {
  final bool hadWork;
  final bool shouldRetry;
  final bool busy;
  final int processedCount;

  const UploadDrainResult({
    required this.hadWork,
    required this.shouldRetry,
    required this.busy,
    required this.processedCount,
  });

  const UploadDrainResult.noWork()
      : hadWork = false,
        shouldRetry = false,
        busy = false,
        processedCount = 0;

  const UploadDrainResult.locked()
      : hadWork = false,
        shouldRetry = false,
        busy = true,
        processedCount = 0;
}

class UploadQueueDrainer {
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const Duration _staleSendingAfter = Duration(minutes: 2);
  static const Duration _drainLease = Duration(minutes: 2);

  final UploadQueueDao _dao;
  final int _batchSize;

  bool _running = false;

  UploadQueueDrainer(
    this._dao, {
    int batchSize = 100,
  }) : _batchSize = batchSize;

  Future<UploadDrainResult> drainAvailable({int maxBatches = 5}) async {
    trackingConsoleLog(
      'UploadQueueDrainer',
      'Drain started: maxBatches=$maxBatches, batchSize=$_batchSize.',
    );
    var totalProcessed = 0;
    var hadWork = false;

    for (var batch = 0; batch < maxBatches; batch++) {
      final result = await drainOnce();
      trackingConsoleLog(
        'UploadQueueDrainer',
        'Batch ${batch + 1}: hadWork=${result.hadWork}, '
            'processed=${result.processedCount}, retry=${result.shouldRetry}, '
            'busy=${result.busy}.',
      );
      totalProcessed += result.processedCount;
      hadWork = hadWork || result.hadWork;

      if (result.busy || result.shouldRetry || !result.hadWork) {
        return UploadDrainResult(
          hadWork: hadWork,
          shouldRetry: result.shouldRetry,
          busy: result.busy,
          processedCount: totalProcessed,
        );
      }

      if (result.processedCount < _batchSize) {
        break;
      }
    }

    return UploadDrainResult(
      hadWork: hadWork,
      shouldRetry: false,
      busy: false,
      processedCount: totalProcessed,
    );
  }

  Future<UploadDrainResult> drainOnce() async {
    if (_running) {
      trackingConsoleLog(
        'UploadQueueDrainer',
        'Drain skipped because this isolate is already uploading.',
      );
      return const UploadDrainResult.locked();
    }

    _running = true;
    final ownerId = const Uuid().v4();
    var lockAcquired = false;
    var rows = <Map<String, dynamic>>[];
    http.Client? client;

    try {
      lockAcquired = await _dao.tryAcquireDrainLock(ownerId, _drainLease);
      if (!lockAcquired) {
        trackingConsoleLog(
          'UploadQueueDrainer',
          'Another uploader owns the queue lease.',
        );
        return const UploadDrainResult.locked();
      }
      trackingConsoleLog('UploadQueueDrainer', 'Queue lease acquired.');

      final recovered = await _dao.recoverStaleSending(_staleSendingAfter);
      if (recovered > 0) {
        trackingConsoleLog(
          'UploadQueueDrainer',
          'Recovered $recovered interrupted uploads.',
        );
      }

      final deviceId = await AppStateDao().get('device_id');
      if (deviceId == null || deviceId.trim().isEmpty) {
        trackingConsoleLog(
          'UploadQueueDrainer',
          'Device ID missing; queued rows remain pending.',
        );
        return const UploadDrainResult(
          hadWork: true,
          shouldRetry: true,
          busy: false,
          processedCount: 0,
        );
      }

      rows = await _dao.claimPending(_batchSize);
      if (rows.isEmpty) {
        trackingConsoleLog('UploadQueueDrainer', 'No eligible PENDING rows.');
        return const UploadDrainResult.noWork();
      }
      trackingConsoleLog(
        'UploadQueueDrainer',
        'Claimed ${rows.length} PENDING rows for upload.',
      );

      final events = rows.map((row) {
        return {
          'entity_type': row['entity_type'],
          'entity_id': row['entity_id'],
          'payload': jsonDecode(row['payload'] as String),
        };
      }).toList();

      final body = jsonEncode({
        'device_id': deviceId,
        'data': events,
      });

      client = http.Client();
      const endpoint = '${THttpHelper.baseUrl}/offline-bg-tracking';
      trackingConsoleLog(
        'UploadQueueDrainer',
        'POST $endpoint started for ${rows.length} rows.',
      );
      final response = await client
          .post(
            Uri.parse(endpoint),
            headers: const {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_requestTimeout);

      trackingConsoleLog(
        'UploadQueueDrainer',
        'API response: status=${response.statusCode}, '
            'rows=${rows.length}, '
            'body=${trackingConsolePreview(response.body)}.',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['success'] == true) {
          await _dao.markSentBatch(
            rows.map((row) => row['id'] as int),
          );
          await _dao.deleteSentOlderThanDays(3);
          trackingConsoleLog(
            'UploadQueueDrainer',
            'Upload accepted; ${rows.length} rows marked SENT.',
          );

          return UploadDrainResult(
            hadWork: true,
            shouldRetry: false,
            busy: false,
            processedCount: rows.length,
          );
        }

        await _dao.markServerFailureBatch(
          rows,
          reason: _reason('Server returned success=false', response.body),
        );
        trackingConsoleLog(
          'UploadQueueDrainer',
          'HTTP success contained success=false; rows scheduled for retry.',
        );

        return UploadDrainResult(
          hadWork: true,
          shouldRetry: true,
          busy: false,
          processedCount: rows.length,
        );
      }

      if (_isTransientStatus(response.statusCode)) {
        await _dao.markRetryBatch(
          rows,
          reason: 'HTTP ${response.statusCode}',
        );
        trackingConsoleLog(
          'UploadQueueDrainer',
          'Transient HTTP ${response.statusCode}; rows remain PENDING.',
        );

        return UploadDrainResult(
          hadWork: true,
          shouldRetry: true,
          busy: false,
          processedCount: rows.length,
        );
      }

      await _dao.markServerFailureBatch(
        rows,
        reason: _reason('HTTP ${response.statusCode}', response.body),
      );
      trackingConsoleLog(
        'UploadQueueDrainer',
        'Non-transient HTTP ${response.statusCode}; server-failure policy applied.',
      );

      return UploadDrainResult(
        hadWork: true,
        shouldRetry: true,
        busy: false,
        processedCount: rows.length,
      );
    } on FormatException catch (error, stackTrace) {
      trackingConsoleError(
        'UploadQueueDrainer',
        'Invalid upload JSON.',
        error,
        stackTrace,
      );
      await _dao.markServerFailureBatch(
        rows,
        reason: _reason('Invalid JSON', error.message),
      );

      return UploadDrainResult(
        hadWork: rows.isNotEmpty,
        shouldRetry: rows.isNotEmpty,
        busy: false,
        processedCount: rows.length,
      );
    } on TimeoutException {
      trackingConsoleLog(
        'UploadQueueDrainer',
        'Upload timed out; queued rows remain pending.',
      );
      await _dao.markRetryBatch(rows, reason: 'Network timeout');

      return UploadDrainResult(
        hadWork: rows.isNotEmpty,
        shouldRetry: true,
        busy: false,
        processedCount: rows.length,
      );
    } on SocketException {
      trackingConsoleLog(
        'UploadQueueDrainer',
        'Network unavailable; queued rows remain pending.',
      );
      await _dao.markRetryBatch(rows, reason: 'Network unavailable');

      return UploadDrainResult(
        hadWork: rows.isNotEmpty,
        shouldRetry: true,
        busy: false,
        processedCount: rows.length,
      );
    } on http.ClientException {
      trackingConsoleLog(
        'UploadQueueDrainer',
        'HTTP client is offline; queued rows remain pending.',
      );
      await _dao.markRetryBatch(rows, reason: 'HTTP client unavailable');

      return UploadDrainResult(
        hadWork: rows.isNotEmpty,
        shouldRetry: true,
        busy: false,
        processedCount: rows.length,
      );
    } catch (error, stackTrace) {
      trackingConsoleError(
        'UploadQueueDrainer',
        'Unexpected upload failure.',
        error,
        stackTrace,
      );
      await _dao.markRetryBatch(rows, reason: 'Unexpected upload failure');

      return UploadDrainResult(
        hadWork: rows.isNotEmpty,
        shouldRetry: true,
        busy: false,
        processedCount: rows.length,
      );
    } finally {
      client?.close();

      if (lockAcquired) {
        try {
          await _dao.releaseDrainLock(ownerId);
          trackingConsoleLog('UploadQueueDrainer', 'Queue lease released.');
        } catch (error, stackTrace) {
          trackingConsoleError(
            'UploadQueueDrainer',
            'Could not release upload lease.',
            error,
            stackTrace,
          );
        }
      }

      _running = false;
    }
  }

  static bool _isTransientStatus(int statusCode) {
    return statusCode == 408 ||
        statusCode == 425 ||
        statusCode == 429 ||
        statusCode >= 500;
  }

  static String _reason(String prefix, String details) {
    final normalized = details.replaceAll(RegExp(r'\s+'), ' ').trim();
    final shortened =
        normalized.length > 300 ? normalized.substring(0, 300) : normalized;
    return shortened.isEmpty ? prefix : '$prefix: $shortened';
  }
}
