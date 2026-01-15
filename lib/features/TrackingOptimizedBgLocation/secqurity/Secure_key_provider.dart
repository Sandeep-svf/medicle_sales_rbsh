import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyProvider {
  static const _keyName = 'tracking_aes_key';

  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // Uses Keystore
    ),
  );

  static Future<String> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) {
      return existing;
    }

    // Generate 32 bytes = 256 bit key
    final rand = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => rand.nextInt(256));
    final key = base64Encode(keyBytes);

    await _storage.write(key: _keyName, value: key);
    return key;
  }
}
