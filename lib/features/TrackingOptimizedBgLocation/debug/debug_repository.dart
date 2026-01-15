import '../core/model/location_point.dart';
import '../core/model/stop_point.dart';
import '../storage/app_database.dart';
import '../storage/location_point_dao.dart';
import '../storage/stop_dao.dart';

class DebugRepository {
  final _db = AppDatabase();
  final _locationDao = LocationPointDao();
  final _stopDao = StopDao();




  Future<List<LocationPoint>> recentLocations() {
    return _locationDao.fetchRecent(10);
  }

  Future<List<StopPoint>> recentStops() {
    return _stopDao.fetchRecent(5);
  }

  Future<int> stopsToday(String localDate) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM stops WHERE local_date = ?',
      [localDate],
    );
    return result.first['cnt'] as int;
  }

  Future<int> totalStopDurationToday(String localDate) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(duration_seconds) as total FROM stops WHERE local_date = ?',
      [localDate],
    );
    return (result.first['total'] ?? 0) as int;
  }

  Future<double> totalDistanceToday(String localDate) async {
    final db = await _db.database;

    final result = await db.rawQuery(
      'SELECT SUM(total_distance_meters) as total FROM trips WHERE local_date = ?',
      [localDate],
    );

    final total = result.first['total'] as num?;
    return (total ?? 0).toDouble();
  }

}
