/*
// lib/data/db/pdf_db.dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/PdfItem.dart';


class PdfDb {
  static const _dbName = 'marketing_pdfs.db';
  static const _dbVersion = 1;
  static const table = 'pdf_items';

  static Database? _instance;

  static Future<Database> open() async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, _dbName);
    _instance = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, _) async {
        await db.execute('''
        CREATE TABLE $table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          fileKey TEXT NOT NULL UNIQUE,
          finalUrl TEXT,
          updatedAt TEXT,
          localPath TEXT,
          lastSyncedAt TEXT
        )
        ''');
      },
    );
    return _instance!;
  }

  static Future<void> upsert(PdfItem item) async {
    final db = await open();
    await db.insert(
      table,
      item.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<PdfItem?> getByFileKey(String fileKey) async {
    final db = await open();
    final res = await db.query(table, where: 'fileKey = ?', whereArgs: [fileKey], limit: 1);
    if (res.isEmpty) return null;
    return PdfItem.fromDb(res.first);
  }

  static Future<List<PdfItem>> getAll() async {
    final db = await open();
    final res = await db.query(table, orderBy: 'title COLLATE NOCASE');
    return res.map(PdfItem.fromDb).toList();
  }

  static Future<int> deleteByFileKey(String fileKey) async {
    final db = await open();
    return db.delete(table, where: 'fileKey = ?', whereArgs: [fileKey]);
  }

  static Future<void> clear() async {
    final db = await open();
    await db.delete(table);
  }
}
*/

// lib/features/marketing/pdfDB/pdfDB.dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/PdfItem.dart';

class PdfDb {
  static const _dbName = 'marketing_pdfs.db';
  static const _dbVersion = 3; // <-- BUMP to trigger migration
  static const table = 'pdf_items';

  static Database? _instance;

  static Future<Database> open() async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, _dbName);
    _instance = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, _) async {
        await _createFresh(db);
      },
      onUpgrade: (db, oldV, newV) async {
        // Rebuild table into the schema we expect.
        await _migrateRebuild(db);
      },
    );
    return _instance!;
  }

  static Future<void> _createFresh(Database db) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serverId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        fileKey TEXT NOT NULL UNIQUE,
        updatedAt TEXT,
        signedUrl TEXT,
        localPath TEXT,
        lastSyncedAt TEXT
      )
    ''');
  }

  /// Robust migration: create a new table with the *desired* schema,
  /// copy over whatever columns exist (including legacy `file_key`),
  /// then swap.
  static Future<void> _migrateRebuild(Database db) async {
    await db.transaction((txn) async {
      // 1) Check if old table exists
      final tables = await txn.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [table]);
      if (tables.isEmpty) {
        await _createFresh(txn as Database);
        return;
      }

      // 2) Snapshot existing column names
      final colsRes = await txn.rawQuery('PRAGMA table_info($table)');
      final existingCols =
      colsRes.map((row) => (row['name'] as String).toLowerCase()).toSet();

      // 3) Build a temp table with the new schema
      await txn.execute('''
        CREATE TABLE ${table}_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          serverId TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          fileKey TEXT NOT NULL UNIQUE,
          updatedAt TEXT,
          signedUrl TEXT,
          localPath TEXT,
          lastSyncedAt TEXT
        )
      ''');

      // 4) Copy data, mapping legacy names if needed
      // Use COALESCE for fileKey: prefer camelCase; fallback to snake_case; else empty.
      final hasServerId = existingCols.contains('serverid') || existingCols.contains('server_id');
      final hasTitle    = existingCols.contains('title');
      final hasDesc     = existingCols.contains('description');
      final hasFileKey  = existingCols.contains('filekey');
      final hasFile_key = existingCols.contains('file_key');
      final hasUpdated  = existingCols.contains('updatedat') || existingCols.contains('updated_at');
      final hasSigned   = existingCols.contains('signedurl') || existingCols.contains('signed_url');
      final hasLocal    = existingCols.contains('localpath') || existingCols.contains('local_path');
      final hasSynced   = existingCols.contains('lastsyncedat') || existingCols.contains('last_synced_at');

      // Build a SELECT that tolerates missing columns.
      String colOrNull(String colCamel, String? legacySnake) {
        final lc = colCamel.toLowerCase();
        final ls = legacySnake?.toLowerCase();
        if (existingCols.contains(lc)) return colCamel;     // exact present
        if (ls != null && existingCols.contains(ls)) return legacySnake!; // legacy
        return "NULL";
      }

      final serverIdSel = hasServerId ? colOrNull('serverId', 'server_id') : "NULL";
      final titleSel    = hasTitle    ? 'title' : "''";
      final descSel     = colOrNull('description', null);
      final fileKeySel  = hasFileKey || hasFile_key
          ? "COALESCE(${hasFileKey ? 'fileKey' : 'NULL'}, ${hasFile_key ? 'file_key' : 'NULL'}, '')"
          : "''";
      final updatedSel  = colOrNull('updatedAt', 'updated_at');
      final signedSel   = colOrNull('signedUrl', 'signed_url');
      final localSel    = colOrNull('localPath', 'local_path');
      final syncedSel   = colOrNull('lastSyncedAt', 'last_synced_at');

      await txn.execute('''
        INSERT INTO ${table}_new (serverId, title, description, fileKey, updatedAt, signedUrl, localPath, lastSyncedAt)
        SELECT
          $serverIdSel            AS serverId,
          $titleSel               AS title,
          $descSel                AS description,
          $fileKeySel             AS fileKey,
          $updatedSel             AS updatedAt,
          $signedSel              AS signedUrl,
          $localSel               AS localPath,
          $syncedSel              AS lastSyncedAt
        FROM $table
      ''');

      // 5) Swap
      await txn.execute('DROP TABLE $table');
      await txn.execute('ALTER TABLE ${table}_new RENAME TO $table');
    });
  }

  // ----------------- DAO -----------------

  static Future<void> upsert(PdfItem item) async {
    final db = await open();
    await db.insert(
      table,
      item.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<PdfItem?> getByFileKey(String fileKey) async {
    final db = await open();
    final res = await db.query(table, where: 'fileKey = ?', whereArgs: [fileKey], limit: 1);
    if (res.isEmpty) return null;
    return PdfItem.fromDb(res.first);
  }

  static Future<PdfItem?> getByServerId(String serverId) async {
    final db = await open();
    final res = await db.query(table, where: 'serverId = ?', whereArgs: [serverId], limit: 1);
    if (res.isEmpty) return null;
    return PdfItem.fromDb(res.first);
  }

  static Future<List<PdfItem>> getAll() async {
    final db = await open();
    final res = await db.query(table, orderBy: 'title COLLATE NOCASE');
    return res.map(PdfItem.fromDb).toList();
  }

  static Future<int> deleteByFileKey(String fileKey) async {
    final db = await open();
    return db.delete(table, where: 'fileKey = ?', whereArgs: [fileKey]);
  }

  static Future<void> clear() async {
    final db = await open();
    await db.delete(table);
  }
}