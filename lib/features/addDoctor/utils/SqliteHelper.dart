import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/DoctorOfflineModel.dart';


class DoctorDatabaseHelper {
  static final DoctorDatabaseHelper _instance = DoctorDatabaseHelper._internal();
  factory DoctorDatabaseHelper() => _instance;
  DoctorDatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'doctors_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_doctors(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            specialization TEXT,
            location TEXT,
            latitude REAL,
            longitude REAL,
            email TEXT,
            phone TEXT,
            registration_number TEXT,
            years_of_experience TEXT,
            date_of_birth TEXT,
            gender TEXT,
            anniversary TEXT,
            headOfficeId TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertDoctor(DoctorOfflineModel doctor) async {
    final db = await database;
    await db.insert('offline_doctors', doctor.toJson());
  }

  Future<List<DoctorOfflineModel>> getPendingDoctors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('offline_doctors');
    return List.generate(maps.length, (i) => DoctorOfflineModel.fromJson(maps[i]));
  }

  Future<void> clearPendingDoctors() async {
    final db = await database;
    await db.delete('offline_doctors');
  }
}
