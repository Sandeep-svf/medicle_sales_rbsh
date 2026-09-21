import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class PendingScheduleDatabase {
  PendingScheduleDatabase._();

  static final PendingScheduleDatabase instance = PendingScheduleDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    return openDatabase(
      path.join(root, 'Gluckscare_pending_schedule_db.db'),
      version: 3,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE pending_schedules(
            localId TEXT PRIMARY KEY,
            doctorLocalId TEXT NOT NULL,
            serverDoctorId TEXT,
            userId TEXT NOT NULL,
            date TEXT NOT NULL,
            notes TEXT NOT NULL,
            remark TEXT NOT NULL,
            doctorName TEXT NOT NULL,
            doctorLatitude REAL,
            doctorLongitude REAL,
            createdAt TEXT NOT NULL,
            areaId TEXT,
            areaName TEXT,
            serverVisitId TEXT,
            lastError TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_area_assignments(
            localId TEXT PRIMARY KEY,
            doctorLocalId TEXT NOT NULL,
            serverDoctorId TEXT,
            userId TEXT NOT NULL,
            areaId TEXT NOT NULL,
            areaName TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            uploaded INTEGER NOT NULL DEFAULT 0,
            lastError TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pending_area_assignments(
              localId TEXT PRIMARY KEY,
              doctorLocalId TEXT NOT NULL,
              serverDoctorId TEXT,
              userId TEXT NOT NULL,
              areaId TEXT NOT NULL,
              areaName TEXT NOT NULL,
              createdAt TEXT NOT NULL,
              uploaded INTEGER NOT NULL DEFAULT 0,
              lastError TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          await db
              .execute('ALTER TABLE pending_schedules ADD COLUMN areaId TEXT');
          await db.execute(
              'ALTER TABLE pending_schedules ADD COLUMN areaName TEXT');
        }
      },
    );
  }
}
