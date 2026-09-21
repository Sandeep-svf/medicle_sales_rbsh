import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PendingDoctorLocationDatabase {
  static final PendingDoctorLocationDatabase instance =
      PendingDoctorLocationDatabase._();

  PendingDoctorLocationDatabase._();

  Database? _database;

  Future<Database> get database async {
    return _database ??= await openDatabase(
      join(await getDatabasesPath(), 'Gluckscare_pending_doctor_location.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE pending_doctor_location_requests(
            requestKey TEXT PRIMARY KEY,
            accountId TEXT NOT NULL,
            localDoctorId TEXT NOT NULL,
            requestedDoctorId TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE INDEX pending_doctor_location_account_idx
          ON pending_doctor_location_requests(accountId)
        ''');
      },
    );
  }
}
