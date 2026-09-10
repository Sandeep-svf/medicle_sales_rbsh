import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/data/local/hive_encrypted_doctor_local_data_source.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/doctor_offline_exception.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor_record.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/models/doctor_sync_models.dart';

import 'doctor_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HiveEncryptedDoctorLocalDataSource', () {
    late Directory root;
    late Uint8List key;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('doctor_offline_store_');
      key = Uint8List.fromList(List<int>.generate(32, (index) => index + 1));
    });

    tearDown(() async {
      if (root.existsSync()) await root.delete(recursive: true);
    });

    test('persists identity and exact version across close and reopen',
        () async {
      final storagePath = '${root.path}/scope_a';
      var source = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: storagePath,
        encryptionKey: key,
      );
      final checkpoint = await source.beginBootstrap();
      final original = fixtureDoctorRecord(
        localId: 'stable-local-id',
        clientGeneratedId: 'server-returned-client-id',
      );
      await source.stageBootstrapPage(
        generation: checkpoint.bootstrapGeneration!,
        records: [original],
        snapshotVersion: BigInt.one,
        nextCursor: null,
      );
      await source.promoteBootstrap(
        generation: checkpoint.bootstrapGeneration!,
        snapshotVersion: BigInt.one,
        completedAtUtc: DateTime.utc(2026, 9, 10),
      );
      await source.close();

      source = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: storagePath,
        encryptionKey: key,
      );
      final restored = (await source.readRecords()).single;
      expect(restored.localId, 'stable-local-id');
      expect(restored.clientGeneratedId, 'server-returned-client-id');
      expect(restored.syncVersion, BigInt.one);

      final updated = DoctorRecord.fromDto(
        dto: fixtureDoctorDto(
          id: original.serverId!,
          syncVersion: 2,
          name: 'Dr. Updated Offline',
        ),
        localId: restored.localId,
        existingClientGeneratedId: restored.clientGeneratedId,
      );
      await source.applyDeltaPage(
        upserts: [updated],
        deletes: const [],
        nextVersion: BigInt.two,
        isFinalPage: true,
        appliedAtUtc: DateTime.utc(2026, 9, 10, 1),
      );
      await source.close();

      source = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: storagePath,
        encryptionKey: key,
      );
      final afterUpdate = (await source.readRecords()).single;
      expect(afterUpdate.localId, 'stable-local-id');
      expect(afterUpdate.clientGeneratedId, 'server-returned-client-id');
      expect(afterUpdate.name, 'Dr. Updated Offline');
      expect(afterUpdate.syncVersion, BigInt.two);
      await source.close();
    });

    test('keeps downloaded null client identity null', () async {
      final source = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: '${root.path}/scope_null_client',
        encryptionKey: key,
      );
      final checkpoint = await source.beginBootstrap();
      await source.stageBootstrapPage(
        generation: checkpoint.bootstrapGeneration!,
        records: [fixtureDoctorRecord(clientGeneratedId: null)],
        snapshotVersion: BigInt.one,
        nextCursor: null,
      );
      await source.promoteBootstrap(
        generation: checkpoint.bootstrapGeneration!,
        snapshotVersion: BigInt.one,
        completedAtUtc: DateTime.utc(2026, 9, 10),
      );

      expect((await source.readRecords()).single.clientGeneratedId, isNull);
      await source.close();
    });

    test('failed metadata commit preserves records and checkpoint', () async {
      var failStateWrite = false;
      final source = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: '${root.path}/scope_commit_failure',
        encryptionKey: key,
        commitHook: (point) async {
          if (failStateWrite &&
              point == DoctorStoreCommitPoint.beforeStateWrite) {
            throw StateError('simulated metadata failure');
          }
        },
      );
      final checkpoint = await source.beginBootstrap();
      failStateWrite = true;

      await expectLater(
        source.stageBootstrapPage(
          generation: checkpoint.bootstrapGeneration!,
          records: [fixtureDoctorRecord()],
          snapshotVersion: BigInt.one,
          nextCursor: 'cursor-1',
        ),
        throwsStateError,
      );

      final unchanged = await source.readCheckpoint();
      expect(unchanged.downloadedCount, 0);
      expect(unchanged.bootstrapCursor, isNull);
      expect(await source.readRecords(), isEmpty);
      failStateWrite = false;
      await source.close();
    });

    test('enforces unique nonnull server and client identities', () async {
      final source = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: '${root.path}/scope_unique',
        encryptionKey: key,
      );
      final checkpoint = await source.beginBootstrap();
      final first = fixtureDoctorRecord(
        id: 'doctor-1',
        localId: 'local-1',
        clientGeneratedId: 'same-client-id',
      );
      final second = fixtureDoctorRecord(
        id: 'doctor-2',
        localId: 'local-2',
        clientGeneratedId: 'same-client-id',
      );

      await expectLater(
        source.stageBootstrapPage(
          generation: checkpoint.bootstrapGeneration!,
          records: [first, second],
          snapshotVersion: BigInt.one,
          nextCursor: null,
        ),
        throwsA(isA<DoctorStorageException>()),
      );
      expect((await source.readCheckpoint()).downloadedCount, 0);
      await source.close();
    });

    test('persists tombstones and blocks stale resurrection after reopen',
        () async {
      final storagePath = '${root.path}/scope_tombstone';
      var source = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: storagePath,
        encryptionKey: key,
      );
      final checkpoint = await source.beginBootstrap();
      await source.stageBootstrapPage(
        generation: checkpoint.bootstrapGeneration!,
        records: [fixtureDoctorRecord(syncVersion: 5)],
        snapshotVersion: BigInt.from(5),
        nextCursor: null,
      );
      await source.promoteBootstrap(
        generation: checkpoint.bootstrapGeneration!,
        snapshotVersion: BigInt.from(5),
        completedAtUtc: DateTime.utc(2026, 9, 10),
      );
      await source.applyDeltaPage(
        upserts: const [],
        deletes: [
          DoctorDeletion(id: 'doctor-1', syncVersion: BigInt.from(6)),
        ],
        nextVersion: BigInt.from(6),
        isFinalPage: true,
        appliedAtUtc: DateTime.utc(2026, 9, 10, 1),
      );
      expect(await source.readRecords(), isEmpty);
      await source.close();

      source = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: storagePath,
        encryptionKey: key,
      );
      await source.applyDeltaPage(
        upserts: [fixtureDoctorRecord(syncVersion: 5)],
        deletes: const [],
        nextVersion: BigInt.from(7),
        isFinalPage: true,
        appliedAtUtc: DateTime.utc(2026, 9, 10, 2),
      );
      expect(await source.readRecords(), isEmpty);
      await source.close();
    });

    test('encrypts record values and refuses a wrong key', () async {
      const uniqueName = 'SENSITIVE_DOCTOR_PLAINTEXT_SENTINEL';
      final storagePath = '${root.path}/scope_encryption';
      var source = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: storagePath,
        encryptionKey: key,
      );
      final checkpoint = await source.beginBootstrap();
      await source.stageBootstrapPage(
        generation: checkpoint.bootstrapGeneration!,
        records: [fixtureDoctorRecord(name: uniqueName)],
        snapshotVersion: BigInt.one,
        nextCursor: null,
      );
      await source.promoteBootstrap(
        generation: checkpoint.bootstrapGeneration!,
        snapshotVersion: BigInt.one,
        completedAtUtc: DateTime.utc(2026, 9, 10),
      );
      await source.close();

      final files = Directory(storagePath)
          .listSync(recursive: true)
          .whereType<File>()
          .toList();
      expect(files, isNotEmpty);
      final diskText =
          files.map((file) => latin1.decode(file.readAsBytesSync())).join();
      expect(diskText, isNot(contains(uniqueName)));

      final wrongKey = Uint8List.fromList(
        List<int>.generate(32, (index) => 255 - index),
      );
      await expectLater(
        HiveEncryptedDoctorLocalDataSource.open(
          directoryPath: storagePath,
          encryptionKey: wrongKey,
        ),
        throwsA(isA<DoctorStorageException>()),
      );

      source = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: storagePath,
        encryptionKey: key,
      );
      expect((await source.readRecords()).single.name, uniqueName);
      await source.close();
    });

    test('isolates account scopes in separate encrypted stores', () async {
      final first = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: '${root.path}/account_a',
        encryptionKey: key,
      );
      final secondKey = Uint8List.fromList(
        List<int>.generate(32, (index) => 100 + index),
      );
      final second = await HiveEncryptedDoctorLocalDataSource.open(
        directoryPath: '${root.path}/account_b',
        encryptionKey: secondKey,
      );
      final checkpoint = await first.beginBootstrap();
      await first.stageBootstrapPage(
        generation: checkpoint.bootstrapGeneration!,
        records: [fixtureDoctorRecord()],
        snapshotVersion: BigInt.one,
        nextCursor: null,
      );
      await first.promoteBootstrap(
        generation: checkpoint.bootstrapGeneration!,
        snapshotVersion: BigInt.one,
        completedAtUtc: DateTime.utc(2026, 9, 10),
      );

      expect(await first.readRecords(), hasLength(1));
      expect(await second.readRecords(), isEmpty);
      await first.close();
      await second.close();
    });
  });
}
