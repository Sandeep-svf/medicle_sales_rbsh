/*
import 'package:sqflite/sqflite.dart';
import '../core/buffer/buffer_event.dart';
import 'app_database.dart';


class UploadQueueDao {
  static const _table = 'upload_queue';

  // ==================================================
  // INSERT (PHASE-2 WRITE-AHEAD LOG)
  // ==================================================
  Future<void> enqueue(BufferEvent event) async {
    final db = await AppDatabase().database;

    await db.insert(
      _table,
      {
        'entity_type': event.type.name,
        'entity_id': event.entityId,
        'payload': event.payload,
        'status': 'PENDING',
        'retry_count': 0,
        'created_at_utc': event.createdAtUtc.toIso8601String(),
        'last_attempt_utc': null,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // ==================================================
  // FETCH PENDING (USED BY DRAINER)
  // ==================================================
  Future<List<Map<String, dynamic>>> fetchPending(int limit) async {
    final db = await AppDatabase().database;

    return db.query(
      _table,
      where: 'status = ? AND retry_count < ?',
      whereArgs: ['PENDING', 5], // MAX 5 retries
      orderBy: 'created_at_utc ASC',
      limit: limit,
    );
  }

  // ==================================================
  // STATE TRANSITIONS
  // ==================================================
  Future<void> markSending(int id) async {
    final db = await AppDatabase().database;

    await db.update(
      _table,
      {
        'status': 'SENDING',
        'last_attempt_utc': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSent(int id) async {
    final db = await AppDatabase().database;

    await db.update(
      _table,
      {'status': 'SENT'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markFailedSafe(int id, int retryCount) async {
    final db = await AppDatabase().database;

    await db.update(
      _table,
      {
        'status': 'FAILED',
        'retry_count': retryCount + 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
*/

// added feature for delete db after 3 days data send date

import 'dart:math' as math;

import 'package:sqflite/sqflite.dart';

import '../core/buffer/buffer_event.dart';
import 'app_database.dart';

class UploadQueueDao {
  static const _table = 'upload_queue';
  static const _lockTable = 'upload_drain_lock';

  Future<bool> enqueue(BufferEvent event) async {
    final db = await AppDatabase().database;
    final rowId = await db.insert(
      _table,
      {
        'entity_type': event.type.name,
        'entity_id': event.entityId,
        'payload': event.payload,
        'status': 'PENDING',
        'retry_count': 0,
        'created_at_utc': event.createdAtUtc.toIso8601String(),
        'last_attempt_utc': null,
        'next_attempt_utc': null,
        'failure_reason': null,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return rowId > 0;
  }

  Future<List<Map<String, dynamic>>> fetchPending(int limit) async {
    final db = await AppDatabase().database;
    final nowUtc = DateTime.now().toUtc().toIso8601String();

    return db.query(
      _table,
      where: 'status = ? AND '
          '(next_attempt_utc IS NULL OR next_attempt_utc <= ?)',
      whereArgs: ['PENDING', nowUtc],
      orderBy: 'created_at_utc ASC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> claimPending(int limit) async {
    final db = await AppDatabase().database;
    final nowUtc = DateTime.now().toUtc().toIso8601String();

    final rows = await db.query(
      _table,
      where: 'status = ? AND '
          '(next_attempt_utc IS NULL OR next_attempt_utc <= ?)',
      whereArgs: ['PENDING', nowUtc],
      orderBy: 'created_at_utc ASC',
      limit: limit,
    );

    if (rows.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final ids = rows.map((row) => row['id'] as int).toList();
    await db.update(
      _table,
      {
        'status': 'SENDING',
        'last_attempt_utc': nowUtc,
        'failure_reason': null,
      },
      where: _idsWhere(ids),
      whereArgs: ids,
    );

    return rows;
  }

  Future<int> recoverStaleSending(Duration staleAfter) async {
    final db = await AppDatabase().database;
    final cutoffUtc =
        DateTime.now().toUtc().subtract(staleAfter).toIso8601String();

    return db.update(
      _table,
      {
        'status': 'PENDING',
        'next_attempt_utc': null,
        'failure_reason': 'Recovered interrupted upload',
      },
      where: 'status = ? AND '
          '(last_attempt_utc IS NULL OR last_attempt_utc <= ?)',
      whereArgs: ['SENDING', cutoffUtc],
    );
  }

  Future<bool> tryAcquireDrainLock(
    String ownerId,
    Duration leaseDuration,
  ) async {
    final db = await AppDatabase().database;
    final now = DateTime.now().toUtc();
    final nowUtc = now.toIso8601String();
    final expiresAtUtc = now.add(leaseDuration).toIso8601String();

    await db.insert(
      _lockTable,
      {'id': 1, 'owner_id': null, 'expires_at_utc': null},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    final updated = await db.rawUpdate(
      '''
        UPDATE $_lockTable
        SET owner_id = ?, expires_at_utc = ?
        WHERE id = 1 AND (
          owner_id IS NULL OR
          expires_at_utc IS NULL OR
          expires_at_utc <= ? OR
          owner_id = ?
        )
        ''',
      [ownerId, expiresAtUtc, nowUtc, ownerId],
    );

    return updated == 1;
  }

  Future<void> releaseDrainLock(String ownerId) async {
    final db = await AppDatabase().database;
    await db.update(
      _lockTable,
      {'owner_id': null, 'expires_at_utc': null},
      where: 'id = ? AND owner_id = ?',
      whereArgs: [1, ownerId],
    );
  }

  Future<void> markSending(int id) async {
    final db = await AppDatabase().database;
    await db.update(
      _table,
      {
        'status': 'SENDING',
        'last_attempt_utc': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSent(int id) async {
    await markSentBatch([id]);
  }

  Future<void> markSentBatch(Iterable<int> rowIds) async {
    final ids = rowIds.toList();
    if (ids.isEmpty) {
      return;
    }

    final db = await AppDatabase().database;
    await db.update(
      _table,
      {
        'status': 'SENT',
        'next_attempt_utc': null,
        'failure_reason': null,
      },
      where: _idsWhere(ids),
      whereArgs: ids,
    );
  }

  Future<void> markRetryBatch(
    Iterable<Map<String, dynamic>> rows, {
    required String reason,
  }) async {
    final db = await AppDatabase().database;
    final now = DateTime.now().toUtc();

    for (final row in rows) {
      final retryCount = (row['retry_count'] as num?)?.toInt() ?? 0;
      final nextRetryCount = retryCount + 1;
      final nextAttemptUtc =
          now.add(_retryDelay(nextRetryCount)).toIso8601String();

      await db.update(
        _table,
        {
          'status': 'PENDING',
          'retry_count': nextRetryCount,
          'last_attempt_utc': now.toIso8601String(),
          'next_attempt_utc': nextAttemptUtc,
          'failure_reason': reason,
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  Future<void> markServerFailureBatch(
    Iterable<Map<String, dynamic>> rows, {
    required String reason,
    int maxAttempts = 3,
  }) async {
    final db = await AppDatabase().database;
    final now = DateTime.now().toUtc();

    for (final row in rows) {
      final retryCount = (row['retry_count'] as num?)?.toInt() ?? 0;
      final nextRetryCount = retryCount + 1;
      final exhausted = nextRetryCount >= maxAttempts;

      await db.update(
        _table,
        {
          'status': exhausted ? 'FAILED' : 'PENDING',
          'retry_count': nextRetryCount,
          'last_attempt_utc': now.toIso8601String(),
          'next_attempt_utc': exhausted
              ? null
              : now.add(_retryDelay(nextRetryCount)).toIso8601String(),
          'failure_reason': reason,
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  Future<void> markFailedSafe(int id, int retryCount) async {
    await markRetryBatch(
      [
        {'id': id, 'retry_count': retryCount},
      ],
      reason: 'Upload failed',
    );
  }

  Future<int> deleteSentOlderThanDays(int days) async {
    final db = await AppDatabase().database;
    final cutoff =
        DateTime.now().toUtc().subtract(Duration(days: days)).toIso8601String();

    return db.delete(
      _table,
      where: 'status = ? AND created_at_utc < ?',
      whereArgs: ['SENT', cutoff],
    );
  }

  Future<void> markPending(int id) async {
    final db = await AppDatabase().database;
    await db.update(
      _table,
      {
        'status': 'PENDING',
        'last_attempt_utc': DateTime.now().toUtc().toIso8601String(),
        'next_attempt_utc': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static String _idsWhere(List<int> ids) {
    final placeholders = List.filled(ids.length, '?').join(',');
    return 'id IN ($placeholders)';
  }

  static Duration _retryDelay(int retryCount) {
    final exponent = math.min(math.max(retryCount - 1, 0), 5);
    final seconds = math.min(30 * (1 << exponent), 15 * 60);
    return Duration(seconds: seconds);
  }
}
