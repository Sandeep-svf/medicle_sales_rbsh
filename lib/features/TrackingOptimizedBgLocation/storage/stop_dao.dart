import 'package:sqflite/sqflite.dart';

import '../core/model/stop_point.dart';
import 'app_database.dart';


class StopDao {
  final _db = AppDatabase();


  Future<List<StopPoint>> fetchRecent(int limit) async {
    final db = await _db.database;

    final rows = await db.query(
      'stops',
      orderBy: 'start_time_utc DESC',
      limit: limit,
    );

    return rows.map(StopPoint.fromMap).toList();
  }


  Future<void> upsert(StopPoint s) async {
    final db = await _db.database;
    await db.insert(
      'stops',
      {
        'stop_id': s.stopId,
        'local_date': s.localDate.toIso8601String(),
        'stop_index': s.stopIndex,
        'latitude': s.latitude,
        'longitude': s.longitude,
        'radius_meters': s.radiusMeters,
        'start_time_utc': s.startTimeUtc.toIso8601String(),
        'end_time_utc': s.endTimeUtc?.toIso8601String(),
        'duration_seconds': s.duration.inSeconds,
        'status': s.status.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
