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
