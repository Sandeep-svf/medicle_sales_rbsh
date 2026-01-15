import 'package:sqflite/sqflite.dart';

import '../core/model/trip.dart';
import 'app_database.dart';


class TripDao {
  final _db = AppDatabase();

  Future<void> upsert(Trip t) async {
    final db = await _db.database;
    await db.insert(
      'trips',
      {
        'trip_id': t.tripId,
        'local_date': t.localDate.toIso8601String(),
        'start_time_utc': t.startTimeUtc.toIso8601String(),
        'end_time_utc': t.endTimeUtc?.toIso8601String(),
        'from_stop_id': t.fromStopId,
        'to_stop_id': t.toStopId,
        'total_distance_meters': t.totalDistanceMeters,
        'status': t.status.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
