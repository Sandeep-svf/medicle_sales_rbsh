import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/models/pending_schedule_model.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/repository/pending_schedule_repository.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/services/doctor_schedule_service.dart';

void main() {
  test('queues separate per-doctor schedule data before one sync trigger',
      () async {
    final repository = FakePendingScheduleRepository();
    var syncTriggerCount = 0;
    final service = DoctorScheduleService(repository: repository);

    await service.queueSchedule(
      doctorLocalId: 'local-doctor-1',
      serverDoctorId: 'server-doctor-1',
      userId: 'user-1',
      date: '22-09-2026',
      notes: 'Morning discussion',
      remark: 'Bring samples',
      doctorName: 'Dr. Anil Sharma',
      syncTrigger: () async {},
    );
    await service.queueSchedule(
      doctorLocalId: 'local-doctor-2',
      serverDoctorId: null,
      userId: 'user-1',
      date: '23-09-2026',
      notes: 'Evening follow-up',
      remark: 'Call before visit',
      doctorName: 'Dr. Beena Kapoor',
      syncTrigger: () async {
        syncTriggerCount++;
      },
    );

    expect(repository.schedules, hasLength(2));
    expect(repository.schedules[0].doctorLocalId, 'local-doctor-1');
    expect(repository.schedules[0].serverDoctorId, 'server-doctor-1');
    expect(repository.schedules[0].date, '2026-09-22');
    expect(repository.schedules[0].notes, 'Morning discussion');
    expect(repository.schedules[0].remark, 'Bring samples');
    expect(repository.schedules[1].doctorLocalId, 'local-doctor-2');
    expect(repository.schedules[1].serverDoctorId, isNull);
    expect(repository.schedules[1].date, '2026-09-23');
    expect(repository.schedules[1].notes, 'Evening follow-up');
    expect(repository.schedules[1].remark, 'Call before visit');

    await Future<void>.delayed(Duration.zero);
    expect(syncTriggerCount, 1);
  });

  test('rejects malformed schedule dates before writing to the outbox',
      () async {
    final repository = FakePendingScheduleRepository();
    final service = DoctorScheduleService(repository: repository);

    await expectLater(
      service.queueSchedule(
        doctorLocalId: 'doctor-1',
        serverDoctorId: 'server-doctor-1',
        userId: 'user-1',
        date: '31-02-2026',
        notes: 'Invalid date',
        doctorName: 'Dr. Offline',
        syncTrigger: () async {},
      ),
      throwsFormatException,
    );

    expect(repository.schedules, isEmpty);
  });
}

class FakePendingScheduleRepository extends PendingScheduleRepository {
  final List<PendingScheduleModel> schedules = <PendingScheduleModel>[];

  @override
  Future<void> insert(PendingScheduleModel schedule) async {
    schedules.add(schedule);
  }
}
