import 'dart:convert';
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

      for (final row in rows) {
        if (!_canRetry(row)) continue;

        final id = row['id'] as int;

        try {
          await _dao.markSending(id);

          // Phase-3 will POST this
          jsonDecode(row['payload']);

          await _dao.markSent(id);
        } catch (_) {
          await _dao.markFailedSafe(
            id,
            row['retry_count'] as int,
          );
        }
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
    final wait = delays[retryCount];

    return now.difference(last).inSeconds >= wait;
  }
}
