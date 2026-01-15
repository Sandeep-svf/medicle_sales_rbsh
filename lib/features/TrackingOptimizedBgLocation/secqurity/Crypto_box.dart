import 'dart:convert';

import 'package:cryptography/cryptography.dart';


class CryptoBox {
  static final _algo = AesGcm.with256bits();

  // 🔐 HARD RULE: store this securely later (Keystore)
  static final SecretKey _key = SecretKey(
    base64Decode('uQx6Jm1zY3JldF9rZXlfMzJfYnl0ZXM='), // 32 bytes
  );

  static Future<String> encrypt(String plain) async {
    final nonce = _algo.newNonce();
    final secretBox = await _algo.encrypt(
      utf8.encode(plain),
      secretKey: _key,
      nonce: nonce,
    );

    return base64Encode(
      nonce +
          secretBox.cipherText +
          secretBox.mac.bytes,
    );
  }

  static Future<String> decrypt(String encoded) async {
    final data = base64Decode(encoded);

    final nonce = data.sublist(0, 12);
    final mac = Mac(data.sublist(data.length - 16));
    final cipherText = data.sublist(12, data.length - 16);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: mac,
    );

    final clear = await _algo.decrypt(
      secretBox,
      secretKey: _key,
    );

    return utf8.decode(clear);
  }
}
