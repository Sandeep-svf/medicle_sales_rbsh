import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../doctor_offline_exception.dart';
import '../../models/doctor.dart';
import '../../models/doctor_model_parsing.dart';
import '../../models/doctor_record.dart';
import '../../models/doctor_sync_models.dart';
import 'doctor_local_data_source.dart';

enum DoctorStoreCommitPoint {
  beforeSegmentWrite,
  beforeStateWrite,
}

typedef DoctorStoreCommitHook = Future<void> Function(
  DoctorStoreCommitPoint point,
);

class HiveEncryptedDoctorLocalDataSource implements DoctorLocalDataSource {
  HiveEncryptedDoctorLocalDataSource._({
    required Box<String> box,
    required Uuid uuid,
    DoctorStoreCommitHook? commitHook,
  })  : _box = box,
        _uuid = uuid,
        _commitHook = commitHook;

  static const int schemaVersion = 1;
  static const String boxName = 'doctor_offline_cache_v1';
  static const String _stateKey = 'store_state';
  static const String _keyVerifierFileName = '.doctor_key_check_v1';
  static const int _compactionDeltaThreshold = 24;
  static const int _snapshotChunkSize = 500;

  final Box<String> _box;
  final Uuid _uuid;
  final DoctorStoreCommitHook? _commitHook;
  final StreamController<List<DoctorRecord>> _changes =
      StreamController<List<DoctorRecord>>.broadcast();

  Future<void> _writeTail = Future<void>.value();
  late _DoctorStoreState _state;
  _MaterializedDataset? _activeCache;
  _MaterializedDataset? _stagingCache;
  bool _closed = false;

  static bool storeFilesExist(String directoryPath) {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) return false;
    return directory
        .listSync(followLinks: false)
        .whereType<File>()
        .any((file) => file.lengthSync() > 0);
  }

  static Future<HiveEncryptedDoctorLocalDataSource> open({
    required String directoryPath,
    required Uint8List encryptionKey,
    HiveInterface? hive,
    Uuid uuid = const Uuid(),
    DoctorStoreCommitHook? commitHook,
  }) async {
    if (encryptionKey.length != 32) {
      throw ArgumentError.value(
        encryptionKey.length,
        'encryptionKey',
        'Hive AES requires exactly 32 bytes.',
      );
    }
    try {
      await Directory(directoryPath).create(recursive: true);
      final scopedBoxName = _boxNameForDirectory(directoryPath);
      await _verifyEncryptionKey(
        directoryPath: directoryPath,
        boxName: scopedBoxName,
        encryptionKey: encryptionKey,
      );
      final hiveInstance = hive ?? Hive;
      final box = await hiveInstance.openBox<String>(
        scopedBoxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
        compactionStrategy: (entries, deletedEntries) {
          return deletedEntries > 100 && deletedEntries > entries ~/ 2;
        },
        crashRecovery: false,
        path: directoryPath,
      );
      final source = HiveEncryptedDoctorLocalDataSource._(
        box: box,
        uuid: uuid,
        commitHook: commitHook,
      );
      await source._loadOrInitializeState();
      return source;
    } catch (error) {
      if (error is DoctorStorageException) rethrow;
      throw DoctorStorageException(
        'The encrypted doctor cache could not be opened.',
        cause: error,
      );
    }
  }

  Future<void> _loadOrInitializeState() async {
    final encoded = _box.get(_stateKey);
    if (encoded == null) {
      _state = const _DoctorStoreState.empty();
      await _box.put(_stateKey, jsonEncode(_state.toJson()));
      await _box.flush();
      return;
    }
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) {
        throw const FormatException('Store state must be an object.');
      }
      _state = _DoctorStoreState.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      if (_state.schemaVersion != schemaVersion) {
        throw DoctorStorageException(
          'Unsupported doctor cache schema version ${_state.schemaVersion}.',
        );
      }
      await _materializeActive();
      if (_state.staging != null) await _materializeStaging();
    } on DoctorStorageException {
      rethrow;
    } catch (error) {
      throw DoctorStorageException(
        'The encrypted doctor cache metadata is invalid.',
        cause: error,
      );
    }
  }

  @override
  Stream<List<DoctorRecord>> watchRecords() async* {
    yield await readRecords();
    yield* _changes.stream;
  }

  @override
  Future<List<DoctorRecord>> readRecords() async {
    _ensureOpen();
    final dataset = await _materializeActive();
    return _sortedCopy(dataset.recordsByLocalId.values);
  }

  @override
  Future<DoctorRecord?> findByServerId(
    String serverId, {
    bool includeBootstrapStaging = false,
  }) async {
    _ensureOpen();
    if (includeBootstrapStaging && _state.staging != null) {
      final staging = await _materializeStaging();
      final localId = staging.serverToLocalId[serverId];
      if (localId != null) return staging.recordsByLocalId[localId];
    }
    final active = await _materializeActive();
    final localId = active.serverToLocalId[serverId];
    return localId == null ? null : active.recordsByLocalId[localId];
  }

  @override
  Future<DoctorRecord?> findByClientGeneratedId(
    String clientGeneratedId, {
    bool includeBootstrapStaging = false,
  }) async {
    _ensureOpen();
    if (includeBootstrapStaging && _state.staging != null) {
      final staging = await _materializeStaging();
      final localId = staging.clientToLocalId[clientGeneratedId];
      if (localId != null) return staging.recordsByLocalId[localId];
    }
    final active = await _materializeActive();
    final localId = active.clientToLocalId[clientGeneratedId];
    return localId == null ? null : active.recordsByLocalId[localId];
  }

  @override
  Future<DoctorSyncCheckpoint> readCheckpoint() async {
    _ensureOpen();
    return _state.checkpoint;
  }

  @override
  Future<DoctorSyncCheckpoint> beginBootstrap({bool restart = false}) {
    return _exclusive(() async {
      _ensureOpen();
      final existing = _state.staging;
      if (!restart && existing != null) return _state.checkpoint;

      final generation = _uuid.v4();
      final nextState = _state.copyWith(
        staging: _DatasetManifest(
          generation: generation,
          baseSegmentKeys: const [],
          deltaSegmentKeys: const [],
        ),
        checkpoint: _state.checkpoint.copyWith(
          bootstrapComplete: false,
          bootstrapGeneration: generation,
          bootstrapCursor: null,
          bootstrapSnapshotVersion: null,
          downloadedCount: 0,
        ),
      );
      final oldStagingKeys = existing?.allSegmentKeys ?? const <String>[];
      await _writeState(nextState);
      _state = nextState;
      _stagingCache = _MaterializedDataset.empty();
      await _deleteKeysBestEffort(oldStagingKeys);
      return _state.checkpoint;
    });
  }

  @override
  Future<DoctorSyncCheckpoint> stageBootstrapPage({
    required String generation,
    required List<DoctorRecord> records,
    required BigInt snapshotVersion,
    required String? nextCursor,
  }) {
    return _exclusive(() async {
      _ensureOpen();
      final staging = _state.staging;
      if (staging == null || staging.generation != generation) {
        throw const DoctorStorageException(
          'The bootstrap generation is no longer active.',
        );
      }
      final savedSnapshot = _state.checkpoint.bootstrapSnapshotVersion;
      if (savedSnapshot != null && savedSnapshot != snapshotVersion) {
        throw const DoctorSyncProtocolException(
          'The bootstrap snapshot changed between pages.',
        );
      }

      final materialized = await _materializeStaging();
      final candidate = materialized.copy();
      for (final record in records) {
        candidate.addSnapshotRecord(record);
      }

      final segmentKey = _newSegmentKey('bootstrap');
      final segment = _StoreSegment.snapshot(records);
      await _writeSegment(segmentKey, segment);
      final nextManifest = staging.copyWith(
        baseSegmentKeys: [...staging.baseSegmentKeys, segmentKey],
      );
      final nextCheckpoint = _state.checkpoint.copyWith(
        bootstrapGeneration: generation,
        bootstrapCursor: nextCursor,
        bootstrapSnapshotVersion: snapshotVersion,
        downloadedCount: candidate.recordsByLocalId.length,
      );
      final nextState = _state.copyWith(
        staging: nextManifest,
        checkpoint: nextCheckpoint,
      );
      try {
        await _writeState(nextState);
      } catch (_) {
        await _deleteKeysBestEffort([segmentKey]);
        rethrow;
      }
      _state = nextState;
      _stagingCache = candidate;
      return nextCheckpoint;
    });
  }

  @override
  Future<DoctorSyncCheckpoint> promoteBootstrap({
    required String generation,
    required BigInt snapshotVersion,
    required DateTime completedAtUtc,
  }) {
    return _exclusive(() async {
      _ensureOpen();
      final staging = _state.staging;
      if (staging == null || staging.generation != generation) {
        throw const DoctorStorageException(
          'The bootstrap generation cannot be promoted.',
        );
      }
      if (_state.checkpoint.bootstrapSnapshotVersion != snapshotVersion) {
        throw const DoctorSyncProtocolException(
          'The completed bootstrap snapshot is inconsistent.',
        );
      }

      final stagedDataset = await _materializeStaging();
      final activeDataset = await _materializeActive();
      final pendingRecords = activeDataset.recordsByLocalId.values.where(
        (record) => record.localSyncState == DoctorLocalSyncState.pendingCreate,
      );
      final retainedPending = <DoctorRecord>[];
      for (final pending in pendingRecords) {
        final matchedByServer = pending.serverId != null &&
            stagedDataset.serverToLocalId.containsKey(pending.serverId);
        final matchedByClient = pending.clientGeneratedId != null &&
            stagedDataset.clientToLocalId
                .containsKey(pending.clientGeneratedId);
        if (!matchedByServer && !matchedByClient) retainedPending.add(pending);
      }

      var promotedManifest = staging;
      var promotedDataset = stagedDataset.copy();
      String? pendingSegmentKey;
      if (retainedPending.isNotEmpty) {
        for (final record in retainedPending) {
          promotedDataset.addSnapshotRecord(record);
        }
        pendingSegmentKey = _newSegmentKey('pending');
        await _writeSegment(
          pendingSegmentKey,
          _StoreSegment.snapshot(retainedPending),
        );
        promotedManifest = promotedManifest.copyWith(
          baseSegmentKeys: [
            ...promotedManifest.baseSegmentKeys,
            pendingSegmentKey,
          ],
        );
      }

      final nextCheckpoint = DoctorSyncCheckpoint(
        bootstrapComplete: true,
        activeGeneration: generation,
        bootstrapGeneration: null,
        bootstrapCursor: null,
        bootstrapSnapshotVersion: null,
        downloadedCount: promotedDataset.recordsByLocalId.length,
        deltaVersion: snapshotVersion,
        lastSuccessfulSyncUtc: completedAtUtc.toUtc(),
      );
      final previousKeys = _state.active?.allSegmentKeys ?? const <String>[];
      final nextState = _state.copyWith(
        active: promotedManifest,
        clearStaging: true,
        checkpoint: nextCheckpoint,
      );
      try {
        await _writeState(nextState);
      } catch (_) {
        if (pendingSegmentKey != null) {
          await _deleteKeysBestEffort([pendingSegmentKey]);
        }
        rethrow;
      }
      _state = nextState;
      _activeCache = promotedDataset;
      _stagingCache = null;
      _emitActive();
      await _deleteKeysBestEffort(previousKeys);
      await _deleteOrphanSegmentsBestEffort();
      return nextCheckpoint;
    });
  }

  @override
  Future<DoctorSyncCheckpoint> applyDeltaPage({
    required List<DoctorRecord> upserts,
    required List<DoctorDeletion> deletes,
    required BigInt nextVersion,
    required bool isFinalPage,
    required DateTime appliedAtUtc,
  }) {
    return _exclusive(() async {
      _ensureOpen();
      final active = _state.active;
      if (!_state.checkpoint.bootstrapComplete || active == null) {
        throw const DoctorStorageException(
          'A complete bootstrap is required before delta sync.',
        );
      }
      final currentVersion = _state.checkpoint.deltaVersion;
      if (currentVersion == null || nextVersion < currentVersion) {
        throw const DoctorSyncProtocolException(
          'The delta checkpoint cannot move backwards.',
        );
      }

      final currentDataset = await _materializeActive();
      final candidate = currentDataset.copy();
      for (final record in upserts) {
        candidate.applyUpsert(record);
      }
      for (final deletion in deletes) {
        candidate.applyDeletion(deletion);
      }

      final hasChanges = upserts.isNotEmpty || deletes.isNotEmpty;
      String? segmentKey;
      var nextManifest = active;
      if (hasChanges) {
        segmentKey = _newSegmentKey('delta');
        await _writeSegment(
          segmentKey,
          _StoreSegment.delta(upserts: upserts, deletes: deletes),
        );
        nextManifest = active.copyWith(
          deltaSegmentKeys: [...active.deltaSegmentKeys, segmentKey],
        );
      }

      final nextCheckpoint = _state.checkpoint.copyWith(
        deltaVersion: nextVersion,
        lastSuccessfulSyncUtc: isFinalPage
            ? appliedAtUtc.toUtc()
            : _state.checkpoint.lastSuccessfulSyncUtc,
        downloadedCount: candidate.recordsByLocalId.length,
      );
      final nextState = _state.copyWith(
        active: nextManifest,
        checkpoint: nextCheckpoint,
      );
      try {
        await _writeState(nextState);
      } catch (_) {
        if (segmentKey != null) await _deleteKeysBestEffort([segmentKey]);
        rethrow;
      }
      _state = nextState;
      _activeCache = candidate;
      _emitActive();
      if (nextManifest.deltaSegmentKeys.length >= _compactionDeltaThreshold) {
        await _compactActiveDataset();
      }
      return _state.checkpoint;
    });
  }

  Future<_MaterializedDataset> _materializeActive() async {
    final cached = _activeCache;
    if (cached != null) return cached;
    final manifest = _state.active;
    if (manifest == null) {
      return _activeCache = _MaterializedDataset.empty();
    }
    return _activeCache = _materialize(manifest);
  }

  Future<_MaterializedDataset> _materializeStaging() async {
    final cached = _stagingCache;
    if (cached != null) return cached;
    final manifest = _state.staging;
    if (manifest == null) {
      return _stagingCache = _MaterializedDataset.empty();
    }
    return _stagingCache = _materialize(manifest);
  }

  _MaterializedDataset _materialize(_DatasetManifest manifest) {
    final dataset = _MaterializedDataset.empty();
    for (final key in manifest.baseSegmentKeys) {
      final segment = _readSegment(key);
      if (segment.kind != _StoreSegmentKind.snapshot) {
        throw const DoctorStorageException(
          'A doctor snapshot references an invalid segment.',
        );
      }
      for (final record in segment.records) {
        dataset.addSnapshotRecord(record);
      }
      for (final deletion in segment.deletes) {
        dataset.applyDeletion(deletion);
      }
    }
    for (final key in manifest.deltaSegmentKeys) {
      final segment = _readSegment(key);
      if (segment.kind != _StoreSegmentKind.delta) {
        throw const DoctorStorageException(
          'A doctor delta references an invalid segment.',
        );
      }
      for (final record in segment.records) {
        dataset.applyUpsert(record);
      }
      for (final deletion in segment.deletes) {
        dataset.applyDeletion(deletion);
      }
    }
    return dataset;
  }

  _StoreSegment _readSegment(String key) {
    final encoded = _box.get(key);
    if (encoded == null) {
      throw const DoctorStorageException(
        'The encrypted doctor cache is missing a committed segment.',
      );
    }
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) {
        throw const FormatException('Segment must be an object.');
      }
      return _StoreSegment.fromJson(Map<String, dynamic>.from(decoded));
    } catch (error) {
      if (error is DoctorStorageException) rethrow;
      throw DoctorStorageException(
        'A committed doctor cache segment is invalid.',
        cause: error,
      );
    }
  }

  Future<void> _compactActiveDataset() async {
    final active = _state.active;
    final dataset = _activeCache;
    if (active == null || dataset == null) return;

    final records = _sortedCopy(dataset.recordsByLocalId.values);
    final newKeys = <String>[];
    try {
      if (records.isEmpty && dataset.deletionVersions.isNotEmpty) {
        final key = _newSegmentKey('compact');
        await _writeSegment(
          key,
          _StoreSegment.snapshot(
            const <DoctorRecord>[],
            deletes: dataset.deletionVersions.entries.map(
              (entry) => DoctorDeletion(
                id: entry.key,
                syncVersion: entry.value,
              ),
            ),
          ),
        );
        newKeys.add(key);
      }
      for (var offset = 0;
          offset < records.length;
          offset += _snapshotChunkSize) {
        final end = (offset + _snapshotChunkSize).clamp(0, records.length);
        final key = _newSegmentKey('compact');
        await _writeSegment(
          key,
          _StoreSegment.snapshot(
            records.sublist(offset, end),
            deletes: offset == 0
                ? dataset.deletionVersions.entries.map(
                    (entry) => DoctorDeletion(
                      id: entry.key,
                      syncVersion: entry.value,
                    ),
                  )
                : const <DoctorDeletion>[],
          ),
        );
        newKeys.add(key);
      }
      final compacted = _DatasetManifest(
        generation: _uuid.v4(),
        baseSegmentKeys: newKeys,
        deltaSegmentKeys: const [],
      );
      final nextState = _state.copyWith(
        active: compacted,
        checkpoint: _state.checkpoint.copyWith(
          activeGeneration: compacted.generation,
        ),
      );
      await _writeState(nextState);
      final previousKeys = active.allSegmentKeys;
      _state = nextState;
      await _deleteKeysBestEffort(previousKeys);
    } catch (_) {
      await _deleteKeysBestEffort(newKeys);
    }
  }

  Future<void> _writeSegment(String key, _StoreSegment segment) async {
    await _commitHook?.call(DoctorStoreCommitPoint.beforeSegmentWrite);
    await _box.put(key, jsonEncode(segment.toJson()));
    await _box.flush();
  }

  Future<void> _writeState(_DoctorStoreState state) async {
    await _commitHook?.call(DoctorStoreCommitPoint.beforeStateWrite);
    await _box.put(_stateKey, jsonEncode(state.toJson()));
    await _box.flush();
  }

  void _emitActive() {
    if (_closed || _changes.isClosed || _activeCache == null) return;
    _changes.add(_sortedCopy(_activeCache!.recordsByLocalId.values));
  }

  List<DoctorRecord> _sortedCopy(Iterable<DoctorRecord> source) {
    final records = List<DoctorRecord>.of(source);
    records.sort((first, second) {
      final byName = (first.name ?? '').toLowerCase().compareTo(
            (second.name ?? '').toLowerCase(),
          );
      if (byName != 0) return byName;
      return first.localId.compareTo(second.localId);
    });
    return List<DoctorRecord>.unmodifiable(records);
  }

  String _newSegmentKey(String kind) => 'segment_${kind}_${_uuid.v4()}';

  Future<void> _deleteKeysBestEffort(Iterable<String> keys) async {
    try {
      await _box.deleteAll(keys);
      await _box.flush();
    } catch (_) {}
  }

  Future<void> _deleteOrphanSegmentsBestEffort() async {
    final retained = <String>{
      ...?_state.active?.allSegmentKeys,
      ...?_state.staging?.allSegmentKeys,
    };
    final orphans = _box.keys
        .whereType<String>()
        .where((key) => key.startsWith('segment_') && !retained.contains(key));
    await _deleteKeysBestEffort(orphans.toList(growable: false));
  }

  Future<T> _exclusive<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _writeTail = _writeTail.catchError((_) {}).then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  void _ensureOpen() {
    if (_closed || !_box.isOpen) {
      throw const DoctorStorageException('The doctor cache is closed.');
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    await _writeTail.catchError((_) {});
    _closed = true;
    await _changes.close();
    try {
      await _box.flush();
      await _box.close();
    } catch (error) {
      throw DoctorStorageException(
        'The doctor cache could not be closed cleanly.',
        cause: error,
      );
    }
  }

  static String _boxNameForDirectory(String directoryPath) {
    final segments = Directory(directoryPath)
        .uri
        .pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    final source = segments.isEmpty ? 'default' : segments.last;
    final safeNamespace = source.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
    final shortened = safeNamespace.length > 96
        ? safeNamespace.substring(0, 96)
        : safeNamespace;
    return '${boxName}_$shortened';
  }

  static Future<void> _verifyEncryptionKey({
    required String directoryPath,
    required String boxName,
    required Uint8List encryptionKey,
  }) async {
    final directory = Directory(directoryPath);
    final verifierFile = File('$directoryPath/$_keyVerifierFileName');
    final databaseFilesExist = directory
        .listSync(followLinks: false)
        .whereType<File>()
        .any((file) => file.path != verifierFile.path && file.lengthSync() > 0);
    final expected = await Hmac.sha256().calculateMac(
      utf8.encode('doctor-offline-key-check-v1|$boxName'),
      secretKey: SecretKey(encryptionKey),
    );
    final expectedBytes = expected.bytes;

    if (!verifierFile.existsSync()) {
      if (databaseFilesExist) {
        throw const DoctorStorageException(
          'The doctor cache key verifier is missing.',
        );
      }
      await verifierFile.writeAsString(
        base64UrlEncode(expectedBytes),
        flush: true,
      );
      return;
    }

    try {
      final savedBytes = base64Url.decode(
        (await verifierFile.readAsString()).trim(),
      );
      if (!_constantTimeEquals(expectedBytes, savedBytes)) {
        throw const DoctorStorageException(
          'The supplied key cannot unlock the doctor cache.',
        );
      }
    } on DoctorStorageException {
      rethrow;
    } catch (error) {
      throw DoctorStorageException(
        'The doctor cache key verifier is invalid.',
        cause: error,
      );
    }
  }

  static bool _constantTimeEquals(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    var difference = 0;
    for (var index = 0; index < first.length; index++) {
      difference |= first[index] ^ second[index];
    }
    return difference == 0;
  }
}

class _DoctorStoreState {
  const _DoctorStoreState({
    required this.schemaVersion,
    required this.active,
    required this.staging,
    required this.checkpoint,
  });

  const _DoctorStoreState.empty()
      : schemaVersion = HiveEncryptedDoctorLocalDataSource.schemaVersion,
        active = null,
        staging = null,
        checkpoint = const DoctorSyncCheckpoint.empty();

  final int schemaVersion;
  final _DatasetManifest? active;
  final _DatasetManifest? staging;
  final DoctorSyncCheckpoint checkpoint;

  factory _DoctorStoreState.fromJson(Map<String, dynamic> json) {
    final schemaVersion = DoctorModelParsing.nullableInteger(
      json['schemaVersion'],
      'schemaVersion',
    );
    final rawCheckpoint = json['checkpoint'];
    if (schemaVersion == null || rawCheckpoint is! Map) {
      throw const FormatException('Store state is incomplete.');
    }
    return _DoctorStoreState(
      schemaVersion: schemaVersion,
      active: _parseManifest(json['active'], 'active'),
      staging: _parseManifest(json['staging'], 'staging'),
      checkpoint: DoctorSyncCheckpoint.fromJson(
        Map<String, dynamic>.from(rawCheckpoint),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'active': active?.toJson(),
      'staging': staging?.toJson(),
      'checkpoint': checkpoint.toJson(),
    };
  }

  _DoctorStoreState copyWith({
    _DatasetManifest? active,
    _DatasetManifest? staging,
    bool clearStaging = false,
    DoctorSyncCheckpoint? checkpoint,
  }) {
    return _DoctorStoreState(
      schemaVersion: schemaVersion,
      active: active ?? this.active,
      staging: clearStaging ? null : staging ?? this.staging,
      checkpoint: checkpoint ?? this.checkpoint,
    );
  }

  static _DatasetManifest? _parseManifest(Object? value, String fieldName) {
    if (value == null) return null;
    if (value is! Map) {
      throw FormatException('$fieldName must be an object or null.');
    }
    return _DatasetManifest.fromJson(Map<String, dynamic>.from(value));
  }
}

class _DatasetManifest {
  const _DatasetManifest({
    required this.generation,
    required this.baseSegmentKeys,
    required this.deltaSegmentKeys,
  });

  final String generation;
  final List<String> baseSegmentKeys;
  final List<String> deltaSegmentKeys;

  List<String> get allSegmentKeys => [
        ...baseSegmentKeys,
        ...deltaSegmentKeys,
      ];

  factory _DatasetManifest.fromJson(Map<String, dynamic> json) {
    return _DatasetManifest(
      generation: DoctorModelParsing.requiredIdentifier(
        json['generation'],
        'manifest.generation',
      ),
      baseSegmentKeys: _parseKeys(
        json['baseSegmentKeys'],
        'manifest.baseSegmentKeys',
      ),
      deltaSegmentKeys: _parseKeys(
        json['deltaSegmentKeys'],
        'manifest.deltaSegmentKeys',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generation': generation,
      'baseSegmentKeys': baseSegmentKeys,
      'deltaSegmentKeys': deltaSegmentKeys,
    };
  }

  _DatasetManifest copyWith({
    String? generation,
    List<String>? baseSegmentKeys,
    List<String>? deltaSegmentKeys,
  }) {
    return _DatasetManifest(
      generation: generation ?? this.generation,
      baseSegmentKeys: baseSegmentKeys ?? this.baseSegmentKeys,
      deltaSegmentKeys: deltaSegmentKeys ?? this.deltaSegmentKeys,
    );
  }

  static List<String> _parseKeys(Object? value, String fieldName) {
    if (value is! List) {
      throw FormatException('$fieldName must be a list.');
    }
    return value
        .map((key) => DoctorModelParsing.requiredIdentifier(key, fieldName))
        .toList(growable: false);
  }
}

enum _StoreSegmentKind { snapshot, delta }

class _StoreSegment {
  const _StoreSegment({
    required this.kind,
    required this.records,
    required this.deletes,
  });

  factory _StoreSegment.snapshot(
    Iterable<DoctorRecord> records, {
    Iterable<DoctorDeletion> deletes = const <DoctorDeletion>[],
  }) {
    return _StoreSegment(
      kind: _StoreSegmentKind.snapshot,
      records: List<DoctorRecord>.unmodifiable(records),
      deletes: List<DoctorDeletion>.unmodifiable(deletes),
    );
  }

  factory _StoreSegment.delta({
    required Iterable<DoctorRecord> upserts,
    required Iterable<DoctorDeletion> deletes,
  }) {
    return _StoreSegment(
      kind: _StoreSegmentKind.delta,
      records: List<DoctorRecord>.unmodifiable(upserts),
      deletes: List<DoctorDeletion>.unmodifiable(deletes),
    );
  }

  final _StoreSegmentKind kind;
  final List<DoctorRecord> records;
  final List<DoctorDeletion> deletes;

  factory _StoreSegment.fromJson(Map<String, dynamic> json) {
    final kindName = DoctorModelParsing.requiredIdentifier(
      json['kind'],
      'segment.kind',
    );
    final kind = _StoreSegmentKind.values.firstWhere(
      (candidate) => candidate.name == kindName,
      orElse: () => throw FormatException('Unknown segment kind: $kindName'),
    );
    final rawRecords = json['records'];
    final rawDeletes = json['deletes'];
    if (rawRecords is! List || rawDeletes is! List) {
      throw const FormatException('Segment arrays are required.');
    }
    return _StoreSegment(
      kind: kind,
      records: rawRecords.map((value) {
        if (value is! Map) {
          throw const FormatException('Stored doctor must be an object.');
        }
        return DoctorRecord.fromJson(Map<String, dynamic>.from(value));
      }).toList(growable: false),
      deletes: rawDeletes.map((value) {
        if (value is! Map) {
          throw const FormatException('Stored deletion must be an object.');
        }
        return DoctorDeletion.fromJson(Map<String, dynamic>.from(value));
      }).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.name,
      'records': records.map((record) => record.toJson()).toList(),
      'deletes': deletes.map((deletion) => deletion.toJson()).toList(),
    };
  }
}

class _MaterializedDataset {
  _MaterializedDataset._({
    required this.recordsByLocalId,
    required this.serverToLocalId,
    required this.clientToLocalId,
    required this.deletionVersions,
  });

  factory _MaterializedDataset.empty() {
    return _MaterializedDataset._(
      recordsByLocalId: <String, DoctorRecord>{},
      serverToLocalId: <String, String>{},
      clientToLocalId: <String, String>{},
      deletionVersions: <String, BigInt>{},
    );
  }

  final Map<String, DoctorRecord> recordsByLocalId;
  final Map<String, String> serverToLocalId;
  final Map<String, String> clientToLocalId;
  final Map<String, BigInt> deletionVersions;

  _MaterializedDataset copy() {
    return _MaterializedDataset._(
      recordsByLocalId: Map<String, DoctorRecord>.of(recordsByLocalId),
      serverToLocalId: Map<String, String>.of(serverToLocalId),
      clientToLocalId: Map<String, String>.of(clientToLocalId),
      deletionVersions: Map<String, BigInt>.of(deletionVersions),
    );
  }

  void addSnapshotRecord(DoctorRecord record) {
    _validateIdentity(record);
    if (recordsByLocalId.containsKey(record.localId)) {
      throw const DoctorStorageException(
        'Duplicate local doctor identity was detected.',
      );
    }
    _insert(record);
  }

  void applyUpsert(DoctorRecord record) {
    final serverId = record.serverId;
    final syncVersion = record.syncVersion;
    if (serverId == null || syncVersion == null) {
      throw const DoctorStorageException(
        'A server delta upsert requires server identity and version.',
      );
    }
    final tombstoneVersion = deletionVersions[serverId];
    if (tombstoneVersion != null && tombstoneVersion >= syncVersion) return;

    final existingLocalId = serverToLocalId[serverId];
    if (existingLocalId != null) {
      final existing = recordsByLocalId[existingLocalId]!;
      final existingVersion = existing.syncVersion;
      if (existingVersion != null && existingVersion > syncVersion) return;
      _remove(existing);
    }
    _validateIdentity(record);
    _insert(record);
    deletionVersions.remove(serverId);
  }

  void applyDeletion(DoctorDeletion deletion) {
    final previousDeletion = deletionVersions[deletion.id];
    if (previousDeletion != null && previousDeletion > deletion.syncVersion) {
      return;
    }
    deletionVersions[deletion.id] = deletion.syncVersion;
    final localId = serverToLocalId[deletion.id];
    if (localId == null) return;
    final existing = recordsByLocalId[localId]!;
    final existingVersion = existing.syncVersion;
    if (existingVersion == null || existingVersion <= deletion.syncVersion) {
      _remove(existing);
    }
  }

  void _validateIdentity(DoctorRecord record) {
    final serverId = record.serverId;
    if (serverId != null) {
      final matched = serverToLocalId[serverId];
      if (matched != null && matched != record.localId) {
        throw const DoctorStorageException(
          'Conflicting server doctor identity was detected.',
        );
      }
    }
    final clientId = record.clientGeneratedId;
    if (clientId != null) {
      final matched = clientToLocalId[clientId];
      if (matched != null && matched != record.localId) {
        throw const DoctorStorageException(
          'Conflicting client doctor identity was detected.',
        );
      }
    }
  }

  void _insert(DoctorRecord record) {
    recordsByLocalId[record.localId] = record;
    final serverId = record.serverId;
    if (serverId != null) serverToLocalId[serverId] = record.localId;
    final clientId = record.clientGeneratedId;
    if (clientId != null) clientToLocalId[clientId] = record.localId;
  }

  void _remove(DoctorRecord record) {
    recordsByLocalId.remove(record.localId);
    final serverId = record.serverId;
    if (serverId != null && serverToLocalId[serverId] == record.localId) {
      serverToLocalId.remove(serverId);
    }
    final clientId = record.clientGeneratedId;
    if (clientId != null && clientToLocalId[clientId] == record.localId) {
      clientToLocalId.remove(clientId);
    }
  }
}
