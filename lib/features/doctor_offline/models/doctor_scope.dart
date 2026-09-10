import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class DoctorOfflineScope {
  const DoctorOfflineScope({
    required this.environment,
    required this.accountId,
    this.authorizedScopeId,
  });

  final String environment;
  final String accountId;
  final String? authorizedScopeId;

  void validate() {
    if (environment.trim().isEmpty) {
      throw ArgumentError.value(environment, 'environment');
    }
    if (accountId.trim().isEmpty) {
      throw ArgumentError.value(accountId, 'accountId');
    }
    if (authorizedScopeId != null && authorizedScopeId!.trim().isEmpty) {
      throw ArgumentError.value(authorizedScopeId, 'authorizedScopeId');
    }
  }

  Future<String> storageNamespace() async {
    validate();
    final canonical = [
      environment.trim().toLowerCase(),
      accountId.trim(),
      authorizedScopeId?.trim() ?? 'all-authorized',
    ].join('|');
    final digest = await Sha256().hash(utf8.encode(canonical));
    return digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
