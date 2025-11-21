import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../offline_model/BaseOfflineModel.dart';


class GenericDatabaseHelper<T extends BaseOfflineModel> {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('offline_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        specialization TEXT NOT NULL,
        location TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        email TEXT,
        phone TEXT,
        registration_number TEXT,
        years_of_experience INTEGER,
        date_of_birth TEXT,
        gender TEXT,
        anniversary TEXT,
        headOfficeId TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE cities (
      id TEXT PRIMARY KEY,
      name TEXT
    )
  ''');
  }

  Future<void> insert(T model) async {
    final db = await database;
    await db.insert(model.tableName, model.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<T>> getAll(String tableName, T Function(Map<String, dynamic>) fromJson) async {
    final db = await database;
    final result = await db.query(tableName);
    return result.map((json) => fromJson(json)).toList();
  }

  Future<void> deleteAll(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }
}
