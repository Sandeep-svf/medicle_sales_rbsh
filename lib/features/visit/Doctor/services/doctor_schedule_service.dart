import 'dart:async';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/pending_schedule_model.dart';
import '../repository/pending_schedule_repository.dart';
import 'doctor_offline_upload_coordinator.dart';

class DoctorScheduleService {
  DoctorScheduleService({PendingScheduleRepository? repository})
      : _repository = repository ?? PendingScheduleRepository();

  final PendingScheduleRepository _repository;

  Future<String> queueSchedule({
    required String doctorLocalId,
    required String? serverDoctorId,
    required String userId,
    required String date,
    required String notes,
    String remark = '',
    required String doctorName,
    String? areaId,
    String? areaName,
    double? doctorLatitude,
    double? doctorLongitude,
    Future<void> Function()? syncTrigger,
  }) async {
    final parsed = DateFormat('dd-MM-yyyy').parseStrict(date);
    final localId = const Uuid().v4();
    await _repository.insert(
      PendingScheduleModel(
        localId: localId,
        doctorLocalId: doctorLocalId,
        serverDoctorId: serverDoctorId,
        userId: userId,
        date: DateFormat('yyyy-MM-dd').format(parsed),
        notes: notes,
        remark: remark,
        doctorName: doctorName,
        doctorLatitude: doctorLatitude,
        doctorLongitude: doctorLongitude,
        createdAt: DateTime.now().toUtc(),
        areaId: areaId,
        areaName: areaName,
      ),
    );

    if (syncTrigger != null) {
      unawaited(syncTrigger());
    } else {
      unawaited(_syncAndDisposeCoordinator());
    }
    return localId;
  }

  Future<void> _syncAndDisposeCoordinator() async {
    final coordinator = DoctorOfflineUploadCoordinator();
    try {
      await coordinator.syncAll();
    } finally {
      coordinator.dispose();
    }
  }
}
