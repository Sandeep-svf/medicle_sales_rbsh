import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/models/pending_area_assignment_model.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/repository/pending_area_assignment_repository.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/services/doctor_area_assignment_queue_service.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/services/doctor_area_assignment_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../doctor_offline/doctor_test_fixtures.dart';

void main() {
  test('pending area assignment survives a map round trip', () {
    final assignment = PendingAreaAssignmentModel(
      localId: 'assignment-1',
      doctorLocalId: 'local-doctor-1',
      serverDoctorId: 'server-doctor-1',
      userId: 'user-1',
      areaId: 'area-1',
      areaName: 'South Delhi',
      createdAt: DateTime.utc(2026, 9, 21),
    );

    final restored = PendingAreaAssignmentModel.fromMap(assignment.toMap());

    expect(restored.localId, assignment.localId);
    expect(restored.doctorLocalId, assignment.doctorLocalId);
    expect(restored.serverDoctorId, assignment.serverDoctorId);
    expect(restored.areaId, assignment.areaId);
    expect(restored.areaName, assignment.areaName);
    expect(restored.uploaded, isFalse);
  });

  test('queue service stores the local doctor and selected cached area',
      () async {
    final repository = FakePendingAreaAssignmentRepository();
    final service = DoctorAreaAssignmentQueueService(repository: repository);

    final localId = await service.queueAssignment(
      doctorLocalId: 'local-doctor-1',
      serverDoctorId: null,
      userId: 'user-1',
      areaId: 'area-1',
      areaName: 'South Delhi',
    );

    expect(localId, isNotEmpty);
    expect(repository.assignments, hasLength(1));
    expect(repository.assignments.single.doctorLocalId, 'local-doctor-1');
    expect(repository.assignments.single.serverDoctorId, isNull);
    expect(repository.assignments.single.areaId, 'area-1');
  });

  test('area sync uses server doctor ids and continues after one failure',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{'token': 'token'});
    final repository = FakePendingAreaAssignmentRepository()
      ..assignments.addAll([
        assignment(
          localId: 'assignment-1',
          doctorLocalId: 'local-doctor-1',
          serverDoctorId: 'server-doctor-1',
          areaId: 'area-1',
        ),
        assignment(
          localId: 'assignment-2',
          doctorLocalId: 'local-doctor-2',
          serverDoctorId: 'server-doctor-2',
          areaId: 'area-2',
        ),
      ]);
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      if (request.url.path.endsWith('server-doctor-2')) {
        return http.Response('{"success":false}', 500);
      }
      return http.Response(jsonEncode({'success': true}), 200);
    });
    final service = DoctorAreaAssignmentSyncService(
      repository: repository,
      client: client,
      baseUrl: 'https://example.test',
    );

    final assigned = await service.syncPendingAssignments(
      userId: 'user-1',
      doctors: [
        fixtureDoctor(id: 'server-doctor-1', localId: 'local-doctor-1')
            .copyWith(areaId: null, areaName: null),
        fixtureDoctor(id: 'server-doctor-2', localId: 'local-doctor-2')
            .copyWith(areaId: null, areaName: null),
      ],
    );

    expect(requests, hasLength(2));
    expect(requests.first.url.path, '/doctors/server-doctor-1');
    expect(requests.first.headers['authorization'], 'Bearer token');
    expect(jsonDecode(requests.first.body)['areaId'], 'area-1');
    expect(assigned['local-doctor-1'], 'area-1');
    expect(assigned['server-doctor-1'], 'area-1');
    expect(assigned.containsKey('local-doctor-2'), isFalse);
    expect(repository.uploaded, contains('assignment-1'));
    expect(repository.errors['assignment-2'], contains('500'));
  });

  test('already assigned area is acknowledged without a duplicate PUT',
      () async {
    final repository = FakePendingAreaAssignmentRepository()
      ..assignments.add(
        assignment(
          localId: 'assignment-existing',
          doctorLocalId: 'local-doctor-1',
          serverDoctorId: 'server-doctor-1',
          areaId: 'area-1',
        ),
      );
    final requests = <http.Request>[];
    final service = DoctorAreaAssignmentSyncService(
      repository: repository,
      client: MockClient((request) async {
        requests.add(request);
        return http.Response(jsonEncode({'success': true}), 200);
      }),
      baseUrl: 'https://example.test',
    );

    final assigned = await service.syncPendingAssignments(
      userId: 'user-1',
      doctors: [
        fixtureDoctor(id: 'server-doctor-1', localId: 'local-doctor-1')
            .copyWith(areaId: 'area-1', areaName: 'South Delhi'),
      ],
    );

    expect(requests, isEmpty);
    expect(assigned['local-doctor-1'], 'area-1');
    expect(repository.uploaded, contains('assignment-existing'));
  });

  test('assignment without a server doctor identity stays pending', () async {
    final repository = FakePendingAreaAssignmentRepository()
      ..assignments.add(
        assignment(
          localId: 'assignment-waiting',
          doctorLocalId: 'local-doctor-1',
          serverDoctorId: null,
          areaId: 'area-1',
        ),
      );
    var requestCount = 0;
    final service = DoctorAreaAssignmentSyncService(
      repository: repository,
      client: MockClient((_) async {
        requestCount++;
        return http.Response(jsonEncode({'success': true}), 200);
      }),
      baseUrl: 'https://example.test',
    );

    await service.syncPendingAssignments(
      userId: 'user-1',
      doctors: [
        fixtureDoctor(id: 'server-doctor-1', localId: 'local-doctor-1')
            .copyWith(
          serverId: null,
          areaId: null,
          areaName: null,
        ),
      ],
    );

    expect(requestCount, 0);
    expect(repository.uploaded, isEmpty);
    expect(repository.errors['assignment-waiting'],
        'Waiting for doctor synchronization.');
  });
}

PendingAreaAssignmentModel assignment({
  required String localId,
  required String doctorLocalId,
  required String? serverDoctorId,
  required String areaId,
}) {
  return PendingAreaAssignmentModel(
    localId: localId,
    doctorLocalId: doctorLocalId,
    serverDoctorId: serverDoctorId,
    userId: 'user-1',
    areaId: areaId,
    areaName: areaId == 'area-1' ? 'South Delhi' : 'North Delhi',
    createdAt: DateTime.utc(2026, 9, 21),
  );
}

class FakePendingAreaAssignmentRepository
    extends PendingAreaAssignmentRepository {
  final List<PendingAreaAssignmentModel> assignments =
      <PendingAreaAssignmentModel>[];
  final Set<String> uploaded = <String>{};
  final Map<String, String> errors = <String, String>{};

  @override
  Future<void> upsert(PendingAreaAssignmentModel assignment) async {
    assignments.removeWhere((item) =>
        item.userId == assignment.userId &&
        item.doctorLocalId == assignment.doctorLocalId);
    assignments.add(assignment);
  }

  @override
  Future<List<PendingAreaAssignmentModel>> getForUser(String userId) async =>
      assignments.where((item) => item.userId == userId).toList();

  @override
  Future<List<PendingAreaAssignmentModel>> getPendingForUser(
          String userId) async =>
      assignments
          .where((item) => item.userId == userId && !item.uploaded)
          .toList();

  @override
  Future<void> markUploaded({
    required String localId,
    String? serverDoctorId,
  }) async {
    final index = assignments.indexWhere((item) => item.localId == localId);
    if (index < 0) return;
    final item = assignments[index];
    assignments[index] = PendingAreaAssignmentModel(
      localId: item.localId,
      doctorLocalId: item.doctorLocalId,
      serverDoctorId: serverDoctorId ?? item.serverDoctorId,
      userId: item.userId,
      areaId: item.areaId,
      areaName: item.areaName,
      createdAt: item.createdAt,
      uploaded: true,
    );
    uploaded.add(localId);
  }

  @override
  Future<void> markError({
    required String localId,
    required String message,
  }) async {
    errors[localId] = message;
  }
}
