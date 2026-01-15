import 'package:sqflite/sqflite.dart';
import '../core/model/location_point.dart';
import 'app_database.dart';

class LastLocationDao {
  final _dbProvider = AppDatabase();

  Future<void> save(LocationPoint p) async {
    final db = await _dbProvider.database;

    await db.insert(
      'last_location',
      {
        'id': 1,
        'latitude': p.latitude,
        'longitude': p.longitude,
        'accuracy': p.accuracy,
        'speed': p.speed,
        'timestamp_utc': p.timestampUtc.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<LocationPoint?> load() async {
    final db = await _dbProvider.database;

    final rows = await db.query(
      'last_location',
      where: 'id = 1',
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final r = rows.first;

    return LocationPoint(
      latitude: r['latitude'] as double,
      longitude: r['longitude'] as double,
      accuracy: r['accuracy'] as double,
      speed: r['speed'] as double,
      timestampUtc: DateTime.parse(r['timestamp_utc'] as String),
    );
  }
}
