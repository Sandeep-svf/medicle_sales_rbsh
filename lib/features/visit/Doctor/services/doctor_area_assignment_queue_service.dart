import 'package:uuid/uuid.dart';

import '../models/pending_area_assignment_model.dart';
import '../repository/pending_area_assignment_repository.dart';

class DoctorAreaAssignmentQueueService {
  DoctorAreaAssignmentQueueService(
      {PendingAreaAssignmentRepository? repository})
      : _repository = repository ?? PendingAreaAssignmentRepository();

  final PendingAreaAssignmentRepository _repository;

  Future<String> queueAssignment({
    required String doctorLocalId,
    required String? serverDoctorId,
    required String userId,
    required String areaId,
    required String areaName,
  }) async {
    final localId = const Uuid().v4();
    await _repository.upsert(
      PendingAreaAssignmentModel(
        localId: localId,
        doctorLocalId: doctorLocalId,
        serverDoctorId: serverDoctorId,
        userId: userId,
        areaId: areaId,
        areaName: areaName,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    return localId;
  }
}
