import 'package:medicle_sales_rbsh/database/dbconstants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PendingVisitDatabase {
  static final PendingVisitDatabase instance =
  PendingVisitDatabase._();

  PendingVisitDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, DBConstants.pendingVisitDatabase),
      version: DBConstants.databaseVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE pending_visits(
        visitId TEXT PRIMARY KEY,
        userLatitude REAL,
        userLongitude REAL,
        notes TEXT,
        productIds TEXT,
        createdAt TEXT
      )
    ''');
  }
}