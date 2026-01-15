import '../core/model/location_point.dart';
import '../secqurity/Crypto_box.dart';
import 'app_database.dart';


class LocationPointDao {
  final _db = AppDatabase();

  Future<List<LocationPoint>> fetchRecent(int limit) async {
    final db = await _db.database;

    final rows = await db.query(
      'location_points',
      orderBy: 'timestamp_utc DESC',
      limit: limit,
    );

    return Future.wait(rows.map((row) async {
      return LocationPoint(
        latitude: double.parse(
          await CryptoBox.decrypt(row['latitude'] as String),
        ),
        longitude: double.parse(
          await CryptoBox.decrypt(row['longitude'] as String),
        ),
        accuracy: double.parse(
          await CryptoBox.decrypt(row['accuracy'] as String),
        ),
        speed: double.parse(
          await CryptoBox.decrypt(row['speed'] as String),
        ),
        timestampUtc: DateTime.parse(row['timestamp_utc'] as String),
      );
    }));
  }








  Future<void> insert(LocationPoint p) async {
    final db = await _db.database;

    await db.insert('location_points', {
      'latitude': await CryptoBox.encrypt(p.latitude.toString()),
      'longitude': await CryptoBox.encrypt(p.longitude.toString()),
      'accuracy': await CryptoBox.encrypt(p.accuracy.toString()),
      'speed': await CryptoBox.encrypt(p.speed.toString()),
      'timestamp_utc': p.timestampUtc.toIso8601String(), // keep readable
    });
  }

}
