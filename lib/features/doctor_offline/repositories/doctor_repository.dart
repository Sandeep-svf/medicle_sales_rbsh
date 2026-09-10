import '../models/doctor.dart';
import '../models/doctor_sync_models.dart';

abstract interface class DoctorRepository {
  Stream<List<Doctor>> watchDoctors();

  Future<List<Doctor>> readDoctors();

  Future<Doctor?> findByLocalId(String localId);

  Future<DoctorSyncCheckpoint> readCheckpoint();

  Future<BootstrapPage> fetchBootstrap({
    String? cursor,
    int limit = 500,
  });

  Future<DeltaPage> fetchDelta({
    required BigInt afterVersion,
    int limit = 500,
    String? headOfficeId,
  });

  Future<DoctorSyncCheckpoint> beginBootstrap({bool restart = false});

  Future<DoctorSyncCheckpoint> stageBootstrapPage({
    required String generation,
    required BootstrapPage page,
  });

  Future<DoctorSyncCheckpoint> promoteBootstrap({
    required String generation,
    required BigInt snapshotVersion,
    required DateTime completedAtUtc,
  });

  Future<DoctorSyncCheckpoint> applyDeltaPage({
    required DeltaPage page,
    required BigInt nextVersion,
    required bool isFinalPage,
    required DateTime appliedAtUtc,
  });

  Future<void> close();
}
