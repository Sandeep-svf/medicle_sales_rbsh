import 'package:sqflite/sqflite.dart';

import '../database/pending_schedule_database.dart';
import '../models/pending_schedule_model.dart';

class PendingScheduleRepository {
  final PendingScheduleDatabase _database = PendingScheduleDatabase.instance;

  Future<void> insert(PendingScheduleModel schedule) async {
    final db = await _database.database;
    await db.insert(
      'pending_schedules',
      schedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PendingScheduleModel>> getForUser(String userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'pending_schedules',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt ASC',
    );
    return rows.map(PendingScheduleModel.fromMap).toList();
  }

  Future<List<PendingScheduleModel>> getPendingForUser(String userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'pending_schedules',
      where: 'userId = ? AND (serverVisitId IS NULL OR serverVisitId = ?)',
      whereArgs: [userId, ''],
      orderBy: 'createdAt ASC',
    );
    return rows.map(PendingScheduleModel.fromMap).toList();
  }

  Future<PendingScheduleModel?> findByLocalId(String localId) async {
    final db = await _database.database;
    final rows = await db.query(
      'pending_schedules',
      where: 'localId = ?',
      whereArgs: [localId],
      limit: 1,
    );
    return rows.isEmpty ? null : PendingScheduleModel.fromMap(rows.first);
  }

  Future<void> setServerDoctorId({
    required String localId,
    required String serverDoctorId,
  }) async {
    final db = await _database.database;
    await db.update(
      'pending_schedules',
      {'serverDoctorId': serverDoctorId, 'lastError': null},
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markUploaded({
    required String localId,
    required String serverVisitId,
  }) async {
    final db = await _database.database;
    await db.update(
      'pending_schedules',
      {'serverVisitId': serverVisitId, 'lastError': null},
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markError({
    required String localId,
    required String message,
  }) async {
    final db = await _database.database;
    await db.update(
      'pending_schedules',
      {'lastError': message},
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }

  Future<void> delete(String localId) async {
    final db = await _database.database;
    await db.delete(
      'pending_schedules',
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }
}
