import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../doctor_offline_exception.dart';

abstract interface class DoctorEncryptionKeyProvider {
  Future<Uint8List> loadOrCreateKey({required bool encryptedStoreExists});
}

class SecureStorageDoctorEncryptionKeyProvider
    implements DoctorEncryptionKeyProvider {
  SecureStorageDoctorEncryptionKeyProvider({
    required String namespace,
    FlutterSecureStorage? secureStorage,
  })  : _storageKey = 'doctor_offline_aes_v1_$namespace',
        _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: false,
              ),
            );

  final String _storageKey;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<Uint8List> loadOrCreateKey({
    required bool encryptedStoreExists,
  }) async {
    try {
      final encoded = await _secureStorage.read(key: _storageKey);
      if (encoded != null) {
        return _decodeAndValidate(encoded);
      }
      if (encryptedStoreExists) {
        throw const DoctorStorageException(
          'The doctor cache exists but its encryption key is unavailable.',
        );
      }

      final random = Random.secure();
      final key = Uint8List.fromList(
        List<int>.generate(32, (_) => random.nextInt(256)),
      );
      final value = base64UrlEncode(key);
      await _secureStorage.write(key: _storageKey, value: value);
      final persisted = await _secureStorage.read(key: _storageKey);
      if (persisted == null) {
        throw const DoctorStorageException(
          'The doctor cache encryption key could not be persisted.',
        );
      }
      final verified = _decodeAndValidate(persisted);
      if (!_constantTimeEquals(key, verified)) {
        throw const DoctorStorageException(
          'The persisted doctor cache encryption key failed verification.',
        );
      }
      return verified;
    } on DoctorStorageException {
      rethrow;
    } catch (error) {
      throw DoctorStorageException(
        'Secure storage is unavailable for the doctor cache.',
        cause: error,
      );
    }
  }

  Uint8List _decodeAndValidate(String encoded) {
    try {
      final decoded = base64Url.decode(encoded);
      if (decoded.length != 32) {
        throw const FormatException('Expected a 256-bit key.');
      }
      return Uint8List.fromList(decoded);
    } catch (error) {
      throw DoctorStorageException(
        'The doctor cache encryption key is invalid.',
        cause: error,
      );
    }
  }

  bool _constantTimeEquals(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    var difference = 0;
    for (var index = 0; index < first.length; index++) {
      difference |= first[index] ^ second[index];
    }
    return difference == 0;
  }
}
