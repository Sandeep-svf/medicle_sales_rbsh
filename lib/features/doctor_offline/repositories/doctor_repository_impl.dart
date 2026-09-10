import 'dart:async';

import 'package:uuid/uuid.dart';

import '../data/local/doctor_local_data_source.dart';
import '../data/remote/doctor_remote_data_source.dart';
import '../doctor_offline_exception.dart';
import '../models/doctor.dart';
import '../models/doctor_dto.dart';
import '../models/doctor_record.dart';
import '../models/doctor_sync_models.dart';
import 'doctor_repository.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl({
    required DoctorLocalDataSource localDataSource,
    required DoctorRemoteDataSource remoteDataSource,
    Uuid uuid = const Uuid(),
  })  : _local = localDataSource,
        _remote = remoteDataSource,
        _uuid = uuid;

  final DoctorLocalDataSource _local;
  final DoctorRemoteDataSource _remote;
  final Uuid _uuid;

  bool _closed = false;

  @override
  Stream<List<Doctor>> watchDoctors() {
    _ensureOpen();
    return _local.watchRecords().map(
          (records) => List<Doctor>.unmodifiable(
            records.map((record) => record.toDomain()),
          ),
        );
  }

  @override
  Future<List<Doctor>> readDoctors() async {
    _ensureOpen();
    final records = await _local.readRecords();
    return List<Doctor>.unmodifiable(
      records.map((record) => record.toDomain()),
    );
  }

  @override
  Future<Doctor?> findByLocalId(String localId) async {
    final doctors = await readDoctors();
    for (final doctor in doctors) {
      if (doctor.localId == localId) return doctor;
    }
    return null;
  }

  @override
  Future<DoctorSyncCheckpoint> readCheckpoint() {
    _ensureOpen();
    return _local.readCheckpoint();
  }

  @override
  Future<BootstrapPage> fetchBootstrap({
    String? cursor,
    int limit = 500,
  }) {
    _ensureOpen();
    return _remote.fetchBootstrap(cursor: cursor, limit: limit);
  }

  @override
  Future<DeltaPage> fetchDelta({
    required BigInt afterVersion,
    int limit = 500,
    String? headOfficeId,
  }) {
    _ensureOpen();
    return _remote.fetchDelta(
      afterVersion: afterVersion,
      limit: limit,
      headOfficeId: headOfficeId,
    );
  }

  @override
  Future<DoctorSyncCheckpoint> beginBootstrap({bool restart = false}) {
    _ensureOpen();
    return _local.beginBootstrap(restart: restart);
  }

  @override
  Future<DoctorSyncCheckpoint> stageBootstrapPage({
    required String generation,
    required BootstrapPage page,
  }) async {
    _ensureOpen();
    final records = await _mapDtos(
      page.doctors,
      includeBootstrapStaging: true,
    );
    return _local.stageBootstrapPage(
      generation: generation,
      records: records,
      snapshotVersion: page.snapshotVersion,
      nextCursor: page.nextCursor,
    );
  }

  @override
  Future<DoctorSyncCheckpoint> promoteBootstrap({
    required String generation,
    required BigInt snapshotVersion,
    required DateTime completedAtUtc,
  }) {
    _ensureOpen();
    return _local.promoteBootstrap(
      generation: generation,
      snapshotVersion: snapshotVersion,
      completedAtUtc: completedAtUtc,
    );
  }

  @override
  Future<DoctorSyncCheckpoint> applyDeltaPage({
    required DeltaPage page,
    required BigInt nextVersion,
    required bool isFinalPage,
    required DateTime appliedAtUtc,
  }) async {
    _ensureOpen();
    final records = await _mapDtos(
      page.upserts,
      includeBootstrapStaging: false,
    );
    return _local.applyDeltaPage(
      upserts: records,
      deletes: page.deletes,
      nextVersion: nextVersion,
      isFinalPage: isFinalPage,
      appliedAtUtc: appliedAtUtc,
    );
  }

  Future<List<DoctorRecord>> _mapDtos(
    List<DoctorDto> doctors, {
    required bool includeBootstrapStaging,
  }) async {
    final serverIds = <String>{};
    final clientIds = <String>{};
    final records = <DoctorRecord>[];

    for (final dto in doctors) {
      if (!serverIds.add(dto.id)) {
        throw const DoctorSyncProtocolException(
          'A doctor page contains a duplicate server identity.',
        );
      }
      final dtoClientId = dto.clientGeneratedId;
      if (dtoClientId != null && !clientIds.add(dtoClientId)) {
        throw const DoctorSyncProtocolException(
          'A doctor page contains a duplicate client identity.',
        );
      }

      final byServer = await _local.findByServerId(
        dto.id,
        includeBootstrapStaging: includeBootstrapStaging,
      );
      final byClient = dtoClientId == null
          ? null
          : await _local.findByClientGeneratedId(
              dtoClientId,
              includeBootstrapStaging: includeBootstrapStaging,
            );

      if (byServer != null &&
          byClient != null &&
          byServer.localId != byClient.localId) {
        throw const DoctorStorageException(
          'Server and client doctor identities resolve to different records.',
        );
      }
      if (byClient?.serverId != null && byClient!.serverId != dto.id) {
        throw const DoctorStorageException(
          'A client doctor identity is linked to a different server record.',
        );
      }
      if (byServer?.clientGeneratedId != null &&
          dtoClientId != null &&
          byServer!.clientGeneratedId != dtoClientId) {
        throw const DoctorStorageException(
          'A server doctor identity is linked to a different client record.',
        );
      }

      final existing = byServer ?? byClient;
      records.add(
        DoctorRecord.fromDto(
          dto: dto,
          localId: existing?.localId ?? _uuid.v4(),
          existingClientGeneratedId: existing?.clientGeneratedId,
        ),
      );
    }
    return List<DoctorRecord>.unmodifiable(records);
  }

  void _ensureOpen() {
    if (_closed) {
      throw const DoctorStorageException('The doctor repository is closed.');
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    Object? firstError;
    StackTrace? firstStackTrace;
    try {
      await _remote.close();
    } catch (error, stackTrace) {
      firstError = error;
      firstStackTrace = stackTrace;
    }
    try {
      await _local.close();
    } catch (error, stackTrace) {
      firstError ??= error;
      firstStackTrace ??= stackTrace;
    }
    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStackTrace!);
    }
  }
}
