import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../doctor_offline_exception.dart';
import '../models/doctor_sync_models.dart';
import '../repositories/doctor_repository.dart';

typedef DoctorScopeGuard = Future<bool> Function();
typedef DoctorSyncDelay = Future<void> Function(Duration duration);
typedef DoctorSyncLog = void Function(String message);

class DoctorSyncCoordinator {
  DoctorSyncCoordinator({
    required DoctorRepository repository,
    required DoctorScopeGuard scopeGuard,
    String? deltaHeadOfficeId,
    int pageSize = 500,
    int maxRequestAttempts = 3,
    DoctorSyncDelay delay = Future<void>.delayed,
    Random? random,
    DoctorSyncLog? log,
  })  : _repository = repository,
        _scopeGuard = scopeGuard,
        _deltaHeadOfficeId = deltaHeadOfficeId,
        _pageSize = pageSize,
        _maxRequestAttempts = maxRequestAttempts,
        _delay = delay,
        _random = random ?? Random.secure(),
        _log = log ?? _defaultLog {
    if (pageSize < 1 || pageSize > 500) {
      throw ArgumentError.value(pageSize, 'pageSize');
    }
    if (maxRequestAttempts < 1) {
      throw ArgumentError.value(maxRequestAttempts, 'maxRequestAttempts');
    }
  }

  final DoctorRepository _repository;
  final DoctorScopeGuard _scopeGuard;
  final String? _deltaHeadOfficeId;
  final int _pageSize;
  final int _maxRequestAttempts;
  final DoctorSyncDelay _delay;
  final Random _random;
  final DoctorSyncLog _log;
  final StreamController<DoctorSyncStatus> _statusChanges =
      StreamController<DoctorSyncStatus>.broadcast();

  DoctorSyncStatus _status = const DoctorSyncStatus.idle();
  Future<void>? _activeSync;
  int _generation = 0;
  bool _disposed = false;

  DoctorSyncStatus get status => _status;
  Stream<DoctorSyncStatus> get statusChanges => _statusChanges.stream;

  Future<void> synchronize({bool rebuildBootstrap = false}) {
    if (_disposed) return Future<void>.value();
    final active = _activeSync;
    if (active != null) return active;

    final operationGeneration = _generation;
    late Future<void> operation;
    operation = _runSynchronization(
      operationGeneration,
      rebuildBootstrap: rebuildBootstrap,
    ).whenComplete(() {
      if (identical(_activeSync, operation)) _activeSync = null;
    });
    _activeSync = operation;
    return operation;
  }

  Future<void> _runSynchronization(
    int operationGeneration, {
    required bool rebuildBootstrap,
  }) async {
    final startedAt = DateTime.now().toUtc();
    try {
      await _assertScopeActive(operationGeneration);
      final cached = await _repository.readDoctors();
      var checkpoint = await _repository.readCheckpoint();
      _setStatus(
        DoctorSyncStatus(
          phase: DoctorSyncPhase.initializing,
          message: cached.isEmpty
              ? 'Preparing secure doctor download'
              : 'Checking for doctor updates',
          downloadedCount: cached.length,
          hasCachedData: cached.isNotEmpty,
          lastSuccessfulSyncUtc: checkpoint.lastSuccessfulSyncUtc,
        ),
      );

      if (rebuildBootstrap || !checkpoint.bootstrapComplete) {
        checkpoint = await _runBootstrap(
          operationGeneration,
          restart: rebuildBootstrap,
        );
      }
      await _runDelta(operationGeneration, checkpoint);
      final completed = await _repository.readCheckpoint();
      final count = (await _repository.readDoctors()).length;
      _setStatus(
        DoctorSyncStatus(
          phase: DoctorSyncPhase.current,
          message: 'Doctors are available offline',
          downloadedCount: count,
          hasCachedData: count > 0,
          lastSuccessfulSyncUtc: completed.lastSuccessfulSyncUtc,
        ),
      );
      _log(
        'sync completed count=$count durationMs='
        '${DateTime.now().toUtc().difference(startedAt).inMilliseconds}',
      );
    } on _DoctorSyncCancelled {
      _log('sync cancelled because the account scope changed');
      if (!_disposed) {
        await _reportFailure(
          DoctorSyncPhase.authenticationRequired,
          'The signed-in account changed. Reopen Doctors to continue.',
          'scope_changed',
        );
      }
    } on DoctorAuthenticationException catch (error) {
      await _reportFailure(
        DoctorSyncPhase.authenticationRequired,
        error.message,
        'authentication',
      );
    } on DoctorStorageException catch (error) {
      await _reportFailure(
        DoctorSyncPhase.storageUnavailable,
        error.message,
        'storage',
      );
    } on DoctorSyncProtocolException catch (error) {
      await _reportFailure(
        DoctorSyncPhase.protocolBlocked,
        error.message,
        'protocol',
      );
    } on DoctorRemoteException catch (error) {
      await _reportFailure(
        error.statusCode == null || error.statusCode == 408
            ? DoctorSyncPhase.offline
            : DoctorSyncPhase.failed,
        error.message,
        'remote_${error.statusCode ?? 'unreachable'}',
      );
    } catch (_) {
      await _reportFailure(
        DoctorSyncPhase.failed,
        'Doctor sync could not be completed. Cached data is unchanged.',
        'unexpected',
      );
    }
  }

  Future<DoctorSyncCheckpoint> _runBootstrap(
    int operationGeneration, {
    required bool restart,
  }) async {
    var checkpoint = await _repository.beginBootstrap(restart: restart);
    final generation = checkpoint.bootstrapGeneration;
    if (generation == null) {
      throw const DoctorStorageException(
        'The bootstrap staging generation was not created.',
      );
    }

    var cursor = checkpoint.bootstrapCursor;
    final seenCursors = <String>{};
    if (cursor != null) seenCursors.add(cursor);
    _setStatus(
      _status.copyWith(
        phase: DoctorSyncPhase.downloading,
        message: checkpoint.downloadedCount == 0
            ? 'Downloading doctors for offline use'
            : 'Resuming doctor download',
        downloadedCount: checkpoint.downloadedCount,
      ),
    );

    while (true) {
      await _assertScopeActive(operationGeneration);
      final requestedCursor = cursor;
      final page = await _requestWithRetry(
        operationGeneration,
        () => _repository.fetchBootstrap(
          cursor: requestedCursor,
          limit: _pageSize,
        ),
      );
      _validateBootstrapPage(page, checkpoint, requestedCursor, seenCursors);
      await _assertScopeActive(operationGeneration);
      checkpoint = await _repository.stageBootstrapPage(
        generation: generation,
        page: page,
      );
      _setStatus(
        _status.copyWith(
          phase: DoctorSyncPhase.downloading,
          message: 'Downloaded ${checkpoint.downloadedCount} doctors',
          downloadedCount: checkpoint.downloadedCount,
          hasCachedData: _status.hasCachedData,
        ),
      );
      _log(
        'bootstrap page committed records=${page.doctors.length} '
        'downloaded=${checkpoint.downloadedCount} hasMore=${page.hasMore}',
      );

      if (!page.hasMore) {
        await _assertScopeActive(operationGeneration);
        return _repository.promoteBootstrap(
          generation: generation,
          snapshotVersion: page.snapshotVersion,
          completedAtUtc: DateTime.now().toUtc(),
        );
      }
      cursor = page.nextCursor!;
      seenCursors.add(cursor);
    }
  }

  void _validateBootstrapPage(
    BootstrapPage page,
    DoctorSyncCheckpoint checkpoint,
    String? requestedCursor,
    Set<String> seenCursors,
  ) {
    final expectedSnapshot = checkpoint.bootstrapSnapshotVersion;
    if (expectedSnapshot != null && page.snapshotVersion != expectedSnapshot) {
      throw const DoctorSyncProtocolException(
        'The bootstrap snapshot changed between pages.',
      );
    }
    if (page.currentServerVersion < page.snapshotVersion) {
      throw const DoctorSyncProtocolException(
        'The bootstrap server version is behind its snapshot version.',
      );
    }
    if (page.hasMore) {
      final nextCursor = page.nextCursor!;
      if (nextCursor == requestedCursor || seenCursors.contains(nextCursor)) {
        throw const DoctorSyncProtocolException(
          'The bootstrap cursor did not make progress.',
        );
      }
    }
  }

  Future<void> _runDelta(
    int operationGeneration,
    DoctorSyncCheckpoint checkpoint,
  ) async {
    final savedVersion = checkpoint.deltaVersion;
    if (savedVersion == null) {
      throw const DoctorStorageException(
        'The doctor delta checkpoint is missing after bootstrap.',
      );
    }
    var afterVersion = savedVersion;
    final seenVersions = <BigInt>{afterVersion};
    _setStatus(
      _status.copyWith(
        phase: DoctorSyncPhase.syncing,
        message: 'Checking for doctor updates',
        hasCachedData: true,
      ),
    );

    while (true) {
      await _assertScopeActive(operationGeneration);
      final requestedVersion = afterVersion;
      final page = await _requestWithRetry(
        operationGeneration,
        () => _repository.fetchDelta(
          afterVersion: requestedVersion,
          limit: _pageSize,
          headOfficeId: _deltaHeadOfficeId,
        ),
      );
      final nextVersion = _validateDeltaPage(
        page,
        requestedVersion,
        seenVersions,
      );
      await _assertScopeActive(operationGeneration);
      checkpoint = await _repository.applyDeltaPage(
        page: page,
        nextVersion: nextVersion,
        isFinalPage: !page.hasMore,
        appliedAtUtc: DateTime.now().toUtc(),
      );
      _log(
        'delta page committed upserts=${page.upserts.length} '
        'deletes=${page.deletes.length} hasMore=${page.hasMore}',
      );
      if (!page.hasMore) return;
      afterVersion = checkpoint.deltaVersion!;
      seenVersions.add(afterVersion);
    }
  }

  BigInt _validateDeltaPage(
    DeltaPage page,
    BigInt requestedVersion,
    Set<BigInt> seenVersions,
  ) {
    if (!page.deletionsFieldPresent) {
      throw const DoctorSyncProtocolException(
        'Delta sync is blocked until the backend supplies the deletion field.',
      );
    }
    final nextVersion = page.nextAfterVersion;
    if (nextVersion == null) {
      throw const DoctorSyncProtocolException(
        'Delta sync is blocked until the backend supplies a safe continuation version.',
      );
    }
    if (page.afterVersion != requestedVersion) {
      throw const DoctorSyncProtocolException(
        'The delta response does not match the requested checkpoint.',
      );
    }
    if (nextVersion < requestedVersion ||
        (page.hasMore && nextVersion <= requestedVersion) ||
        (page.hasMore && seenVersions.contains(nextVersion))) {
      throw const DoctorSyncProtocolException(
        'The delta continuation did not make safe progress.',
      );
    }
    if (page.currentServerVersion < nextVersion) {
      throw const DoctorSyncProtocolException(
        'The delta continuation exceeds the server watermark.',
      );
    }

    final changedIds = <String>{};
    for (final doctor in page.upserts) {
      if (!changedIds.add(doctor.id)) {
        throw const DoctorSyncProtocolException(
          'A delta page contains ambiguous repeated doctor changes.',
        );
      }
      if (doctor.syncVersion <= requestedVersion ||
          doctor.syncVersion > nextVersion) {
        throw const DoctorSyncProtocolException(
          'A doctor upsert falls outside the committed delta boundary.',
        );
      }
    }
    for (final deletion in page.deletes) {
      if (!changedIds.add(deletion.id)) {
        throw const DoctorSyncProtocolException(
          'A delta page contains an ambiguous upsert/deletion identity.',
        );
      }
      if (deletion.syncVersion <= requestedVersion ||
          deletion.syncVersion > nextVersion) {
        throw const DoctorSyncProtocolException(
          'A doctor deletion falls outside the committed delta boundary.',
        );
      }
    }
    if (changedIds.isNotEmpty && nextVersion == requestedVersion) {
      throw const DoctorSyncProtocolException(
        'A changed delta page did not advance its checkpoint.',
      );
    }
    return nextVersion;
  }

  Future<T> _requestWithRetry<T>(
    int operationGeneration,
    Future<T> Function() request,
  ) async {
    for (var attempt = 1; attempt <= _maxRequestAttempts; attempt++) {
      await _assertScopeActive(operationGeneration);
      try {
        return await request();
      } on DoctorRemoteException catch (error) {
        if (!error.isTransient || attempt == _maxRequestAttempts) rethrow;
        final delay = error.retryAfter ?? _retryDelay(attempt);
        _log(
            'transient request failure retry=$attempt delayMs=${delay.inMilliseconds}');
        await _delay(delay);
      }
    }
    throw const DoctorRemoteException('Doctor sync retry limit was reached.');
  }

  Duration _retryDelay(int attempt) {
    final exponential = 400 * (1 << (attempt - 1));
    final jitter = _random.nextInt(251);
    return Duration(milliseconds: exponential + jitter);
  }

  Future<void> _assertScopeActive(int operationGeneration) async {
    if (_disposed ||
        operationGeneration != _generation ||
        !await _scopeGuard()) {
      throw const _DoctorSyncCancelled();
    }
  }

  Future<void> _reportFailure(
    DoctorSyncPhase phase,
    String message,
    String category,
  ) async {
    var cachedCount = 0;
    DoctorSyncCheckpoint checkpoint = const DoctorSyncCheckpoint.empty();
    try {
      cachedCount = (await _repository.readDoctors()).length;
      checkpoint = await _repository.readCheckpoint();
    } catch (_) {}
    _setStatus(
      DoctorSyncStatus(
        phase: phase,
        message: message,
        downloadedCount: cachedCount,
        hasCachedData: cachedCount > 0,
        lastSuccessfulSyncUtc: checkpoint.lastSuccessfulSyncUtc,
      ),
    );
    _log('sync stopped category=$category cachedCount=$cachedCount');
  }

  void _setStatus(DoctorSyncStatus value) {
    if (_disposed) return;
    _status = value;
    if (!_statusChanges.isClosed) _statusChanges.add(value);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    final active = _activeSync;
    if (active != null) {
      try {
        await active;
      } catch (_) {}
    }
    await _statusChanges.close();
  }

  static void _defaultLog(String message) {
    if (kDebugMode) debugPrint('[DoctorOfflineSync] $message');
  }
}

class _DoctorSyncCancelled implements Exception {
  const _DoctorSyncCancelled();
}
