import 'package:sqflite/sqflite.dart';
import '../core/state/tracking_state.dart';
import 'app_database.dart';

class TrackingStateDao {
  final _db = AppDatabase();

  Future<void> save(TrackingState state) async {
    final db = await _db.database;

    await db.insert(
      'tracking_state',
      state.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TrackingState?> load() async {
    final db = await _db.database;

    final rows = await db.query(
      'tracking_state',
      where: 'id = 1',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return TrackingState.fromMap(rows.first);
  }

  Future<void> clear() async {
    final db = await _db.database;
    await db.delete('tracking_state');
  }
}
