import 'package:sqflite/sqflite.dart';

import '../database/visit_cache_database.dart';

class VisitCacheRepository {

  final VisitCacheDatabase _database =
      VisitCacheDatabase.instance;

  Future<void> save({
    required String cacheKey,
    required String json,
  }) async {

    final db = await _database.database;

    await db.insert(
      "visit_cache",
      {
        "cacheKey": cacheKey,
        "jsonData": json,
        "updatedAt":
        DateTime.now().toIso8601String(),
      },
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<String?> get(
      String cacheKey,
      ) async {

    final db = await _database.database;

    final result = await db.query(
      "visit_cache",
      where: "cacheKey=?",
      whereArgs: [cacheKey],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first["jsonData"] as String;
  }

  Future<void> clear() async {

    final db = await _database.database;

    await db.delete("visit_cache");
  }
}