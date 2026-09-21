import 'package:sqflite/sqflite.dart';

import '../database/pending_doctor_location_database.dart';
import '../models/pending_doctor_location_request.dart';

class PendingDoctorLocationRepository {
  final PendingDoctorLocationDatabase _database =
      PendingDoctorLocationDatabase.instance;

  Future<void> upsert(PendingDoctorLocationRequest request) async {
    final db = await _database.database;
    await db.insert(
      'pending_doctor_location_requests',
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PendingDoctorLocationRequest>> getForAccount(
    String accountId,
  ) async {
    final db = await _database.database;
    final rows = await db.query(
      'pending_doctor_location_requests',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'createdAt ASC',
    );
    return rows
        .map((row) => PendingDoctorLocationRequest.fromMap(row))
        .toList(growable: false);
  }

  Future<void> delete(String requestKey) async {
    final db = await _database.database;
    await db.delete(
      'pending_doctor_location_requests',
      where: 'requestKey = ?',
      whereArgs: [requestKey],
    );
  }
}
