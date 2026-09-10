class DoctorOfflineException implements Exception {
  const DoctorOfflineException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class DoctorRemoteException extends DoctorOfflineException {
  const DoctorRemoteException(
    super.message, {
    super.cause,
    this.statusCode,
    this.retryAfter,
  });

  final int? statusCode;
  final Duration? retryAfter;

  bool get isTransient {
    final code = statusCode;
    return code == null || code == 408 || code == 429 || code >= 500;
  }
}

class DoctorAuthenticationException extends DoctorRemoteException {
  const DoctorAuthenticationException(super.message, {super.statusCode});
}

class DoctorSyncProtocolException extends DoctorOfflineException {
  const DoctorSyncProtocolException(super.message, {super.cause});
}

class DoctorStorageException extends DoctorOfflineException {
  const DoctorStorageException(super.message, {super.cause});
}
