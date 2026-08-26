import 'package:sqflite/sqflite.dart';

import '../core/buffer/buffer_event.dart';
import '../core/model/location_point.dart';
import 'app_database.dart';

class TrackingPointPersistenceDao {
  Future<bool> save(
    LocationPoint point, {
    BufferEvent? uploadEvent,
  }) async {
    final db = await AppDatabase().database;

    return db.transaction((transaction) async {
      await transaction.insert(
        'last_location',
        {
          'id': 1,
          'latitude': point.latitude,
          'longitude': point.longitude,
          'accuracy': point.accuracy,
          'speed': point.speed,
          'timestamp_utc': point.timestampUtc.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (uploadEvent == null) {
        return false;
      }

      final rowId = await transaction.insert(
        'upload_queue',
        {
          'entity_type': uploadEvent.type.name,
          'entity_id': uploadEvent.entityId,
          'payload': uploadEvent.payload,
          'status': 'PENDING',
          'retry_count': 0,
          'created_at_utc': uploadEvent.createdAtUtc.toIso8601String(),
          'last_attempt_utc': null,
          'next_attempt_utc': null,
          'failure_reason': null,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      return rowId > 0;
    });
  }
}
