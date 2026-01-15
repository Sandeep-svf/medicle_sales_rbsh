import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class AppStateDao {
  static const _table = 'app_state';

  Future<void> set(String key, String value) async {
    final db = await AppDatabase().database;
    await db.insert(
      _table,
      {
        'key': key,
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> get(String key) async {
    final db = await AppDatabase().database;
    final rows = await db.query(
      _table,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }
}
