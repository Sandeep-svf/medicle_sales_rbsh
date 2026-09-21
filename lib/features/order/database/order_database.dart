import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class OrderDatabase {
  OrderDatabase._(this._database);

  final Database _database;
  static const databaseName = 'offline_orders.sqlite';

  static Future<OrderDatabase> open({String? databasePath}) async {
    final root =
        databasePath ?? path.join(await getDatabasesPath(), databaseName);
    final db = await openDatabase(
      root,
      version: 2,
      onCreate: (database, _) async {
        await database.execute('''
          CREATE TABLE orders(
            local_id TEXT PRIMARY KEY,
            client_generated_id TEXT NOT NULL UNIQUE,
            doctor_name TEXT NOT NULL,
            doctor_id TEXT,
            clinic_name TEXT,
            specialization TEXT,
            area TEXT,
            head_office TEXT,
            delivery_address TEXT,
            notes TEXT,
            order_date TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            sync_state TEXT NOT NULL,
            last_error TEXT,
            attachment_name TEXT NOT NULL,
            attachment_mime TEXT NOT NULL,
            attachment_path TEXT NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE order_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_local_id TEXT NOT NULL,
            product_id TEXT NOT NULL,
            product_name TEXT NOT NULL,
            salt TEXT,
            dosage TEXT,
            quantity INTEGER NOT NULL,
            unit TEXT NOT NULL,
            free_sample INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(order_local_id) REFERENCES orders(local_id)
              ON DELETE CASCADE
          )
        ''');
        await database.execute(
          'CREATE INDEX orders_created_at_idx ON orders(created_at)',
        );
        await database.execute(
          'CREATE INDEX order_items_order_idx ON order_items(order_local_id)',
        );
        await _addOrderDetails(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) await _addOrderDetails(database);
      },
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
    );
    return OrderDatabase._(db);
  }

  OrderDatabase.fromDatabase(Database database) : _database = database;

  Database get raw => _database;

  Future<void> close() => _database.close();
}

Future<void> _addOrderDetails(Database db) async {
  for (final column in [
    "customer_type TEXT NOT NULL DEFAULT 'Doctor'",
    'contact_phone TEXT',
    'stockist_name TEXT',
    'purchase_order_reference TEXT',
    'requested_delivery_date TEXT',
    "priority TEXT NOT NULL DEFAULT 'Normal'",
    "payment_terms TEXT NOT NULL DEFAULT 'To be agreed'",
    'credit_days INTEGER',
  ]) {
    await db.execute('ALTER TABLE orders ADD COLUMN $column');
  }
  for (final column in [
    'free_quantity INTEGER NOT NULL DEFAULT 0',
    'pack_description TEXT',
    'unit_rate_paise INTEGER',
    'discount_basis_points INTEGER NOT NULL DEFAULT 0',
    'tax_basis_points INTEGER NOT NULL DEFAULT 0',
  ]) {
    await db.execute('ALTER TABLE order_items ADD COLUMN $column');
  }
}
