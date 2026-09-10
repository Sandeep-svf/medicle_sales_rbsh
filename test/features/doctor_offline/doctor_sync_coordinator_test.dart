import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/data/local/hive_encrypted_doctor_local_data_source.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/data/remote/doctor_remote_data_source.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/doctor_offline_exception.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor_sync_models.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/repositories/doctor_repository_impl.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/sync/doctor_sync_coordinator.dart';

import 'doctor_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DoctorSyncCoordinator', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('doctor_sync_test_');
    });

    tearDown(() async {
      if (root.existsSync()) await root.delete(recursive: true);
    });

    test('paginates bootstrap and delta without using global watermark',
        () async {
      final remote = _ScriptedRemote(
        bootstrapResponses: [
          fixtureBootstrapPage(
            snapshotVersion: BigInt.one,
            currentServerVersion: BigInt.from(10),
            nextCursor: 'opaque-cursor-1',
            hasMore: true,
            doctors: [fixtureDoctorDto(id: 'doctor-a', name: 'Doctor A')],
          ),
          fixtureBootstrapPage(
            snapshotVersion: BigInt.one,
            currentServerVersion: BigInt.from(10),
            doctors: [fixtureDoctorDto(id: 'doctor-b', name: 'Doctor B')],
          ),
        ],
        deltaResponses: [
          fixtureDeltaPage(
            afterVersion: BigInt.one,
            nextAfterVersion: BigInt.from(3),
            currentServerVersion: BigInt.from(10),
            hasMore: true,
            upserts: [
              fixtureDoctorDto(
                id: 'doctor-a',
                name: 'Doctor A Updated',
                syncVersion: 2,
              ),
            ],
          ),
          fixtureDeltaPage(
            afterVersion: BigInt.from(3),
            nextAfterVersion: BigInt.from(4),
            currentServerVersion: BigInt.from(10),
            deletes: [
              DoctorDeletion(id: 'doctor-b', syncVersion: BigInt.from(4)),
            ],
          ),
        ],
      );
      final harness = await _Harness.create(root.path, remote);

      await harness.coordinator.synchronize();

      final doctors = await harness.repository.readDoctors();
      final checkpoint = await harness.repository.readCheckpoint();
      expect(remote.bootstrapCursors, [null, 'opaque-cursor-1']);
      expect(remote.deltaVersions, [BigInt.one, BigInt.from(3)]);
      expect(doctors, hasLength(1));
      expect(doctors.single.serverId, 'doctor-a');
      expect(doctors.single.name, 'Doctor A Updated');
      expect(checkpoint.deltaVersion, BigInt.from(4));
      expect(checkpoint.deltaVersion, isNot(BigInt.from(10)));
      expect(harness.coordinator.status.phase, DoctorSyncPhase.current);
      await harness.dispose();
    });

    test('resumes an interrupted bootstrap from the saved cursor', () async {
      final remote = _ScriptedRemote(
        bootstrapResponses: [
          fixtureBootstrapPage(
            snapshotVersion: BigInt.one,
            nextCursor: 'resume-cursor',
            hasMore: true,
            doctors: [fixtureDoctorDto(id: 'doctor-a')],
          ),
          const DoctorRemoteException('network unavailable'),
        ],
        deltaResponses: [],
      );
      final harness = await _Harness.create(root.path, remote);

      await harness.coordinator.synchronize();

      var checkpoint = await harness.repository.readCheckpoint();
      expect(checkpoint.bootstrapComplete, isFalse);
      expect(checkpoint.bootstrapCursor, 'resume-cursor');
      expect(checkpoint.downloadedCount, 1);
      expect(await harness.repository.readDoctors(), isEmpty);

      remote.bootstrapResponses.add(
        fixtureBootstrapPage(
          snapshotVersion: BigInt.one,
          doctors: [fixtureDoctorDto(id: 'doctor-b')],
        ),
      );
      remote.deltaResponses.add(
        fixtureDeltaPage(
          afterVersion: BigInt.one,
          nextAfterVersion: BigInt.one,
        ),
      );
      await harness.coordinator.synchronize();

      checkpoint = await harness.repository.readCheckpoint();
      expect(remote.bootstrapCursors, [null, 'resume-cursor', 'resume-cursor']);
      expect(checkpoint.bootstrapComplete, isTrue);
      expect(await harness.repository.readDoctors(), hasLength(2));
      expect(harness.coordinator.status.phase, DoctorSyncPhase.current);
      await harness.dispose();
    });

    test('blocks unresolved delta contract without advancing checkpoint',
        () async {
      final remote = _ScriptedRemote(
        bootstrapResponses: [
          fixtureBootstrapPage(
            snapshotVersion: BigInt.one,
            doctors: [fixtureDoctorDto()],
          ),
        ],
        deltaResponses: [
          DeltaPage(
            success: true,
            currentServerVersion: BigInt.from(5),
            afterVersion: BigInt.one,
            nextAfterVersion: null,
            hasMore: false,
            upserts: const [],
            deletes: const [],
            deletionsFieldPresent: false,
          ),
        ],
      );
      final harness = await _Harness.create(root.path, remote);

      await harness.coordinator.synchronize();

      final checkpoint = await harness.repository.readCheckpoint();
      expect(checkpoint.bootstrapComplete, isTrue);
      expect(checkpoint.deltaVersion, BigInt.one);
      expect(await harness.repository.readDoctors(), hasLength(1));
      expect(
        harness.coordinator.status.phase,
        DoctorSyncPhase.protocolBlocked,
      );
      await harness.dispose();
    });

    test('repository preserves local identity across server upserts', () async {
      final remote = _ScriptedRemote(
        bootstrapResponses: [
          fixtureBootstrapPage(
            snapshotVersion: BigInt.one,
            doctors: [fixtureDoctorDto(id: 'doctor-stable')],
          ),
        ],
        deltaResponses: [
          DeltaPage(
            success: true,
            currentServerVersion: BigInt.two,
            afterVersion: BigInt.one,
            nextAfterVersion: null,
            hasMore: false,
            upserts: const [],
            deletes: const [],
            deletionsFieldPresent: false,
          ),
        ],
      );
      final harness = await _Harness.create(root.path, remote);
      await harness.coordinator.synchronize();
      final initialLocalId =
          (await harness.repository.readDoctors()).single.localId;

      remote.deltaResponses.add(
        fixtureDeltaPage(
          afterVersion: BigInt.one,
          nextAfterVersion: BigInt.two,
          upserts: [
            fixtureDoctorDto(
              id: 'doctor-stable',
              syncVersion: 2,
              name: 'Updated stable doctor',
            ),
          ],
        ),
      );
      await harness.coordinator.synchronize();

      final updated = (await harness.repository.readDoctors()).single;
      expect(updated.localId, initialLocalId);
      expect(updated.name, 'Updated stable doctor');
      await harness.dispose();
    });

    test('rejects a repeated bootstrap cursor and keeps partial data hidden',
        () async {
      final remote = _ScriptedRemote(
        bootstrapResponses: [
          fixtureBootstrapPage(
            snapshotVersion: BigInt.one,
            nextCursor: 'same-cursor',
            hasMore: true,
            doctors: [fixtureDoctorDto(id: 'doctor-a')],
          ),
          fixtureBootstrapPage(
            snapshotVersion: BigInt.one,
            nextCursor: 'same-cursor',
            hasMore: true,
            doctors: [fixtureDoctorDto(id: 'doctor-b')],
          ),
        ],
        deltaResponses: [],
      );
      final harness = await _Harness.create(root.path, remote);

      await harness.coordinator.synchronize();

      final checkpoint = await harness.repository.readCheckpoint();
      expect(checkpoint.bootstrapComplete, isFalse);
      expect(checkpoint.bootstrapCursor, 'same-cursor');
      expect(checkpoint.downloadedCount, 1);
      expect(await harness.repository.readDoctors(), isEmpty);
      expect(
        harness.coordinator.status.phase,
        DoctorSyncPhase.protocolBlocked,
      );
      await harness.dispose();
    });

    test('coalesces concurrent synchronization triggers', () async {
      final pageCompleter = Completer<BootstrapPage>();
      final remote = _ScriptedRemote(
        bootstrapResponses: [pageCompleter.future],
        deltaResponses: [
          fixtureDeltaPage(
            afterVersion: BigInt.one,
            nextAfterVersion: BigInt.one,
          ),
        ],
      );
      final harness = await _Harness.create(root.path, remote);

      final first = harness.coordinator.synchronize();
      final second = harness.coordinator.synchronize();
      expect(identical(first, second), isTrue);
      pageCompleter.complete(
        fixtureBootstrapPage(
          snapshotVersion: BigInt.one,
          doctors: [fixtureDoctorDto()],
        ),
      );
      await Future.wait([first, second]);

      expect(remote.bootstrapCursors, [null]);
      expect(remote.deltaVersions, [BigInt.one]);
      await harness.dispose();
    });

    test('scope change during a response prevents late database writes',
        () async {
      var scopeActive = true;
      final pageCompleter = Completer<BootstrapPage>();
      final requestStarted = Completer<void>();
      final remote = _ScriptedRemote(
        bootstrapResponses: [pageCompleter.future],
        deltaResponses: [],
        onBootstrapRequest: () {
          if (!requestStarted.isCompleted) requestStarted.complete();
        },
      );
      final harness = await _Harness.create(
        root.path,
        remote,
        scopeGuard: () async => scopeActive,
      );

      final sync = harness.coordinator.synchronize();
      await requestStarted.future;
      scopeActive = false;
      pageCompleter.complete(
        fixtureBootstrapPage(
          snapshotVersion: BigInt.one,
          doctors: [fixtureDoctorDto()],
        ),
      );
      await sync;

      expect(await harness.repository.readDoctors(), isEmpty);
      expect((await harness.repository.readCheckpoint()).downloadedCount, 0);
      await harness.dispose();
    });
  });
}

class _ScriptedRemote implements DoctorRemoteDataSource {
  _ScriptedRemote({
    required Iterable<Object> bootstrapResponses,
    required Iterable<Object> deltaResponses,
    this.onBootstrapRequest,
  })  : bootstrapResponses = Queue<Object>.of(bootstrapResponses),
        deltaResponses = Queue<Object>.of(deltaResponses);

  final Queue<Object> bootstrapResponses;
  final Queue<Object> deltaResponses;
  final void Function()? onBootstrapRequest;
  final List<String?> bootstrapCursors = <String?>[];
  final List<BigInt> deltaVersions = <BigInt>[];

  @override
  Future<BootstrapPage> fetchBootstrap({
    String? cursor,
    int limit = 500,
  }) async {
    bootstrapCursors.add(cursor);
    onBootstrapRequest?.call();
    if (bootstrapResponses.isEmpty) {
      throw StateError('No scripted bootstrap response remains.');
    }
    final response = bootstrapResponses.removeFirst();
    if (response is Future<BootstrapPage>) return response;
    if (response is BootstrapPage) return response;
    if (response is Exception) throw response;
    throw StateError('Unsupported bootstrap script value.');
  }

  @override
  Future<DeltaPage> fetchDelta({
    required BigInt afterVersion,
    int limit = 500,
    String? headOfficeId,
  }) async {
    deltaVersions.add(afterVersion);
    if (deltaResponses.isEmpty) {
      throw StateError('No scripted delta response remains.');
    }
    final response = deltaResponses.removeFirst();
    if (response is Future<DeltaPage>) return response;
    if (response is DeltaPage) return response;
    if (response is Exception) throw response;
    throw StateError('Unsupported delta script value.');
  }

  @override
  Future<void> close() async {}
}

class _Harness {
  const _Harness({required this.repository, required this.coordinator});

  final DoctorRepositoryImpl repository;
  final DoctorSyncCoordinator coordinator;

  static Future<_Harness> create(
    String rootPath,
    DoctorRemoteDataSource remote, {
    DoctorScopeGuard? scopeGuard,
  }) async {
    final key = Uint8List.fromList(
      List<int>.generate(32, (index) => index + 10),
    );
    final local = await HiveEncryptedDoctorLocalDataSource.open(
      directoryPath: '$rootPath/scope',
      encryptionKey: key,
    );
    final repository = DoctorRepositoryImpl(
      localDataSource: local,
      remoteDataSource: remote,
    );
    final coordinator = DoctorSyncCoordinator(
      repository: repository,
      scopeGuard: scopeGuard ?? () async => true,
      maxRequestAttempts: 1,
      delay: (_) async {},
      log: (_) {},
    );
    return _Harness(repository: repository, coordinator: coordinator);
  }

  Future<void> dispose() async {
    await coordinator.dispose();
    await repository.close();
  }
}
