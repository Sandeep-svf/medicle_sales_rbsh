import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';

import '../utils/device_info_plus.dart';
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
    if (_running) {
      developer.log(
        'Already running. Skipping this cycle.',
        name: 'UploadQueueDrainer',
      );
      return;
    }

    _running = true;

    developer.log(
      '========== Upload Started ==========\n',
      name: 'UploadQueueDrainer',
    );

    try {
      final rows = await _dao.fetchPending(_batchSize);

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

      final deviceId = await getDeviceId();
      final url = "${THttpHelper.baseUrl}/offline-bg-tracking";

      developer.log(
        'Device ID : $deviceId',
        name: 'UploadQueueDrainer',
      );

      developer.log(
        'URL : $url',
        name: 'UploadQueueDrainer',
      );

      final events = rows.map((row) {
        return {
          "entity_type": row["entity_type"],
          "entity_id": row["entity_id"],
          "payload": jsonDecode(row["payload"]),
        };
      }).toList();

      final body = {
        "device_id": deviceId,
        "data": events,
      };

      developer.log(
        'Request Body:\n${const JsonEncoder.withIndent("  ").convert(body)}',
        name: 'UploadQueueDrainer',
      );

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse["success"] == true) {
          developer.log(
            'Upload successful.',
            name: 'UploadQueueDrainer',
          );

          for (final row in rows) {
            await _dao.markSent(row['id'] as int);
          }

          developer.log(
            '${rows.length} records marked as sent.',
            name: 'UploadQueueDrainer',
          );

          await _dao.deleteSentOlderThanDays(3);

          developer.log(
            'Deleted sent records older than 3 days.',
            name: 'UploadQueueDrainer',
          );
        } else {
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
        }
      } else {
        developer.log(
          'Upload failed with status ${response.statusCode}.',
          name: 'UploadQueueDrainer',
        );

        for (final row in rows) {
          await _dao.markFailedSafe(
            row['id'] as int,
            row['retry_count'] as int,
          );
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        'Exception while uploading.',
        name: 'UploadQueueDrainer',
        error: e,
        stackTrace: stackTrace,
      );

      final rows = await _dao.fetchPending(_batchSize);

      for (final row in rows) {
        await _dao.markFailedSafe(
          row['id'] as int,
          row['retry_count'] as int,
        );
      }
    } finally {
      developer.log(
        '========== Upload Finished ==========\n',
        name: 'UploadQueueDrainer',
      );

      _running = false;
    }
  }
}