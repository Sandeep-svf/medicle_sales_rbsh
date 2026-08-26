import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  // =========================
  // SINGLETON
  // =========================
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  // =========================
  // DB CONFIG
  // =========================
  static const String _dbName = 'tracking.db';

  //  IMPORTANT: bump when schema changes
  static const int _dbVersion = 3;

  Database? _db;
  Future<Database>? _opening;

  // =========================
  // PUBLIC ACCESS
  // =========================
  Future<Database> get database {
    final current = _db;
    if (current != null && current.isOpen) {
      return Future.value(current);
    }

    return _opening ??= _openAndCache();
  }

  Future<Database> _openAndCache() async {
    try {
      final database = await _open();
      _db = database;
      return database;
    } finally {
      _opening = null;
    }
  }

  // =========================
  // OPEN DATABASE
  // =========================
  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      singleInstance: false,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,

      //  DO NOT USE onOpen
      //  DO NOT CREATE TABLES HERE
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.rawQuery('PRAGMA busy_timeout = 5000');
  }

  // =========================
  // CREATE (Fresh install)
  // =========================
  Future<void> _onCreate(Database db, int version) async {
    print('[DB] onCreate v$version');
    await _createAllTables(db);
    await _createIndexes(db);
  }

  // =========================
  // UPGRADE (Existing users)
  // =========================
  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    print('[DB] onUpgrade $oldVersion → $newVersion');

    await _createAllTables(db);

    if (oldVersion < 3) {
      await _migrateToVersion3(db);
    }

    await _createIndexes(db);
  }

  // =========================
  // TABLE DEFINITIONS
  // =========================
  Future<void> _createAllTables(Database db) async {
    // -------- LOCATION POINTS --------
    await db.execute('''
      CREATE TABLE IF NOT EXISTS location_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL,
        speed REAL,
        timestamp_utc TEXT NOT NULL
      )
    ''');

    // -------- UPLOAD QUEUE (PHASE 2) --------
    await db.execute('''
      CREATE TABLE IF NOT EXISTS upload_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        entity_type TEXT NOT NULL,   -- location | stop | trip
        entity_id TEXT NOT NULL,

        payload TEXT NOT NULL,       -- JSON snapshot
        status TEXT NOT NULL,        -- PENDING | SENDING | SENT | FAILED

        retry_count INTEGER NOT NULL DEFAULT 0,

        created_at_utc TEXT NOT NULL,
        last_attempt_utc TEXT,
        next_attempt_utc TEXT,
        failure_reason TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS upload_drain_lock (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        owner_id TEXT,
        expires_at_utc TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tracking_state (
        id INTEGER PRIMARY KEY CHECK (id = 1),

    last_lat REAL NOT NULL,
    last_lng REAL NOT NULL,
    last_timestamp_utc TEXT NOT NULL,

    active_stop_id TEXT,
    active_trip_id TEXT
    )
    ''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS app_state (
  key TEXT PRIMARY KEY,
  value TEXT
)
''');

    // -------- STOPS --------
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stops (
        stop_id TEXT PRIMARY KEY,
        local_date TEXT NOT NULL,
        stop_index INTEGER,
        latitude REAL,
        longitude REAL,
        radius_meters REAL,
        start_time_utc TEXT,
        end_time_utc TEXT,
        duration_seconds INTEGER,
        status TEXT
      )
    ''');

    // -------- TRIPS --------
    await db.execute('''
      CREATE TABLE IF NOT EXISTS trips (
        trip_id TEXT PRIMARY KEY,
        local_date TEXT,
        start_time_utc TEXT,
        end_time_utc TEXT,
        from_stop_id TEXT,
        to_stop_id TEXT,
        total_distance_meters REAL,
        status TEXT
      )
    ''');

    // -------- LAST LOCATION (RECOVERY) --------
    await db.execute('''
      CREATE TABLE IF NOT EXISTS last_location (
        id INTEGER PRIMARY KEY,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL,
        speed REAL,
        timestamp_utc TEXT NOT NULL
      )
    ''');

    print('[DB] Tables created / verified');
  }

  Future<void> _migrateToVersion3(Database db) async {
    await _addColumnIfMissing(
      db,
      table: 'upload_queue',
      column: 'next_attempt_utc',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      db,
      table: 'upload_queue',
      column: 'failure_reason',
      definition: 'TEXT',
    );
  }

  Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((entry) => entry['name'] == column);

    if (!exists) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $column $definition',
      );
    }
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('''
      DELETE FROM upload_queue
      WHERE id NOT IN (
        SELECT MIN(id)
        FROM upload_queue
        GROUP BY entity_type, entity_id
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS
      idx_upload_queue_entity
      ON upload_queue(entity_type, entity_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_upload_queue_delivery
      ON upload_queue(status, next_attempt_utc, created_at_utc)
    ''');
  }

  // =========================
  // OPTIONAL CLEAN SHUTDOWN
  // =========================
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
      print('[DB] closed');
    }
  }
}
