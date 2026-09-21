import 'package:sqflite/sqflite.dart';

import '../database/pending_schedule_database.dart';
import '../models/pending_area_assignment_model.dart';

class PendingAreaAssignmentRepository {
  final PendingScheduleDatabase _database = PendingScheduleDatabase.instance;

  Future<void> upsert(PendingAreaAssignmentModel assignment) async {
    final db = await _database.database;
    await db.delete(
      'pending_area_assignments',
      where: 'userId = ? AND doctorLocalId = ?',
      whereArgs: [assignment.userId, assignment.doctorLocalId],
    );
    await db.insert(
      'pending_area_assignments',
      assignment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PendingAreaAssignmentModel>> getForUser(String userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'pending_area_assignments',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt ASC',
    );
    return rows.map(PendingAreaAssignmentModel.fromMap).toList();
  }

  Future<List<PendingAreaAssignmentModel>> getPendingForUser(
      String userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'pending_area_assignments',
      where: 'userId = ? AND uploaded = 0',
      whereArgs: [userId],
      orderBy: 'createdAt ASC',
    );
    return rows.map(PendingAreaAssignmentModel.fromMap).toList();
  }

  Future<void> markUploaded({
    required String localId,
    String? serverDoctorId,
  }) async {
    final db = await _database.database;
    await db.update(
      'pending_area_assignments',
      {
        'uploaded': 1,
        if (serverDoctorId != null) 'serverDoctorId': serverDoctorId,
        'lastError': null,
      },
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
      'pending_area_assignments',
      {'lastError': message, 'uploaded': 0},
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }
}
