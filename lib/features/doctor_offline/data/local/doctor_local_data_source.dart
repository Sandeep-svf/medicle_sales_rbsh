import '../../models/doctor_record.dart';
import '../../models/doctor_sync_models.dart';

abstract interface class DoctorLocalDataSource {
  Stream<List<DoctorRecord>> watchRecords();

  Future<List<DoctorRecord>> readRecords();

  Future<DoctorRecord?> findByServerId(
    String serverId, {
    bool includeBootstrapStaging = false,
  });

  Future<DoctorRecord?> findByClientGeneratedId(
    String clientGeneratedId, {
    bool includeBootstrapStaging = false,
  });

  Future<DoctorSyncCheckpoint> readCheckpoint();

  Future<DoctorSyncCheckpoint> beginBootstrap({bool restart = false});

  Future<DoctorSyncCheckpoint> stageBootstrapPage({
    required String generation,
    required List<DoctorRecord> records,
    required BigInt snapshotVersion,
    required String? nextCursor,
  });

  Future<DoctorSyncCheckpoint> promoteBootstrap({
    required String generation,
    required BigInt snapshotVersion,
    required DateTime completedAtUtc,
  });

  Future<DoctorSyncCheckpoint> applyDeltaPage({
    required List<DoctorRecord> upserts,
    required List<DoctorDeletion> deletes,
    required BigInt nextVersion,
    required bool isFinalPage,
    required DateTime appliedAtUtc,
  });

  Future<void> close();
}
