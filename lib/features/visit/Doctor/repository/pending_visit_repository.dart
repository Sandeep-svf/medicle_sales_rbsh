import 'package:sqflite/sqflite.dart';

import '../database/pending_visit_database.dart';
import '../models/pending_visit_model.dart';

class PendingVisitRepository {
  final PendingVisitDatabase _database =
      PendingVisitDatabase.instance;

  Future<void> insertVisit(PendingVisitModel visit) async {
    final db = await _database.database;

    await db.insert(
      'pending_visits',
      visit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PendingVisitModel>> getPendingVisits() async {
    final db = await _database.database;

    final result = await db.query('pending_visits');

    return result
        .map((e) => PendingVisitModel.fromMap(e))
        .toList();
  }

  Future<void> deleteVisit(String visitId) async {
    final db = await _database.database;

    await db.delete(
      'pending_visits',
      where: 'visitId = ?',
      whereArgs: [visitId],
    );
  }

  Future<void> deleteAll() async {
    final db = await _database.database;

    await db.delete('pending_visits');
  }

  Future<bool> isVisitPending(String visitId) async {
    final db = await _database.database;

    final result = await db.query(
      'pending_visits',
      where: 'visitId = ?',
      whereArgs: [visitId],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}