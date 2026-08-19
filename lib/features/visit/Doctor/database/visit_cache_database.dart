import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class VisitCacheDatabase {
  VisitCacheDatabase._();

  static final VisitCacheDatabase instance =
  VisitCacheDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, "visit_cache.db"),
      version: 1,
      onCreate: _create,
    );
  }

  Future<void> _create(
      Database db,
      int version,
      ) async {

    await db.execute('''
CREATE TABLE visit_cache(
cacheKey TEXT PRIMARY KEY,
jsonData TEXT NOT NULL,
updatedAt TEXT NOT NULL
)
''');
  }
}