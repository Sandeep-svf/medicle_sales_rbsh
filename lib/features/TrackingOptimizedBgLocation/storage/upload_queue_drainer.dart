/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'upload_queue_dao.dart';

class UploadQueueDrainer {
  final UploadQueueDao _dao;
  final int _batchSize;
  bool _running = false;

  UploadQueueDrainer(this._dao, {int batchSize = 20})
      : _batchSize = batchSize;

  // ===============================
  // PUBLIC ENTRY
  // ===============================
  Future<void> drainOnce() async {
    if (_running) return;
    _running = true;

    try {
      final rows = await _dao.fetchPending(_batchSize);
      if (rows.isEmpty) return;

      //  Build EVENTS payload
      final events = rows.map((row) => {
        'type': row['entity_type'],
        'event_id': row['entity_id'],
        'payload': jsonDecode(row['payload']),
      }).toList();

      //  SEND TO SERVER (ONE CALL)
      final response = await http.post(
        Uri.parse('https://YOUR_API_URL/events/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: jsonEncode({
          'device_id': 'android-device-id',
          'user_id': 'sales-user-id',
          'sent_at_utc': DateTime.now().toUtc().toIso8601String(),
          'events': events,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        //  MARK ALL AS SENT
        for (final row in rows) {
          await _dao.markSent(row['id'] as int);
        }
      } else {
        //  SERVER ERROR → retry later
        for (final row in rows) {
          await _dao.markFailedSafe(
            row['id'] as int,
            row['retry_count'] as int,
          );
        }
      }
    } catch (e) {
      //  NETWORK / CRASH → retry later
      for (final row in await _dao.fetchPending(_batchSize)) {
        await _dao.markFailedSafe(
          row['id'] as int,
          row['retry_count'] as int,
        );
      }
    } finally {
      _running = false;
    }
  }

  // ===============================
  // BACKOFF RULES
  // ===============================
  bool _canRetry(Map<String, dynamic> row) {
    final retryCount = row['retry_count'] as int;
    final lastAttempt = row['last_attempt_utc'];

    if (retryCount == 0 || lastAttempt == null) return true;

    final last = DateTime.parse(lastAttempt);
    final now = DateTime.now().toUtc();

    const delays = [0, 10, 30, 120, 300]; // seconds
    return now.difference(last).inSeconds >= delays[retryCount];
  }
}
*/

// for delete data 3 days later after send date fetures implemented

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'upload_queue_dao.dart';

class UploadQueueDrainer {
  final UploadQueueDao _dao;
  final int _batchSize;
  bool _running = false;

  UploadQueueDrainer(this._dao, {int batchSize = 20})
      : _batchSize = batchSize;

  Future<void> drainOnce() async {
    if (_running) return;
    _running = true;

    try {
      final rows = await _dao.fetchPending(_batchSize);
      if (rows.isEmpty) return;

      final events = rows.map((row) => {
        'type': row['entity_type'],
        'event_id': row['entity_id'],
        'payload': jsonDecode(row['payload']),
      }).toList();

      final response = await http.post(
        Uri.parse('https://YOUR_API_URL/events/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: jsonEncode({
          'device_id': 'android-device-id',
          'user_id': 'sales-user-id',
          'sent_at_utc': DateTime.now().toUtc().toIso8601String(),
          'events': events,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        //  MARK AS SENT
        for (final row in rows) {
          await _dao.markSent(row['id'] as int);
        }

        // 🧹 DELETE OLD SENT DATA (OLDER THAN 3 DAYS)
        await _dao.deleteSentOlderThanDays(3);
      } else {
        for (final row in rows) {
          await _dao.markFailedSafe(
            row['id'] as int,
            row['retry_count'] as int,
          );
        }
      }
    } catch (e) {
      for (final row in await _dao.fetchPending(_batchSize)) {
        await _dao.markFailedSafe(
          row['id'] as int,
          row['retry_count'] as int,
        );
      }
    } finally {
      _running = false;
    }
  }
}
